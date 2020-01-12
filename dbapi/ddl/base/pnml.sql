--DROP TABLE public.pnml CASCADE;
CREATE TABLE public.pnml (id serial, name varchar, pnml xml);

--TRUNCATE public.pnml;
--DROP function pnmlPlaces(xml);

-- construct list of places FROM pnml source
CREATE OR REPLACE FUNCTION pnmlPlaces(source xml) RETURNS SETOF place
AS $$
DECLARE
  p place;
  node xml;
  marking text[];
  i bigint;
BEGIN
  i := 0;
	FOR node in
    SELECT unnest(xpath(concat('//place/name/value/text()'), $1))
  LOOP
    p := row(
      i,
      node::varchar,
      NULL,
      NULL,
      ARRAY[(0, 'Default')::token]
    )::place;

    i := i+1;

	  SELECT INTO p.capacity unnest(xpath(concat('//place[@id="', node::varchar, '"]/capacity/value/text()'), $1));

	  SELECT INTO marking string_to_array(unnest(
        xpath(concat('//place[@id="', node::varchar, '"]/initialMarking/value/text()'), $1)
    )::text, ',');

    p.initial := marking[2]::bigint;

    RETURN NEXT p;
  END LOOP;
END;
$$ LANGUAGE plpgsql STABLE;

--SELECT * FROM pnmlPlaces((SELECT pnml FROM pnml WHERE name = 'counter'));

--DROP function pnmlArcs(xml);

-- construct list of places FROM pnml source
CREATE OR REPLACE FUNCTION pnmlArcs(source xml) RETURNS SETOF arc
AS $$
DECLARE
  a arc;
  node xml;
  i bigint;
  source_is_place boolean;
  inscription text[];
BEGIN
  i := 0;

  -- construct arcs
	FOR node in
    select unnest(xpath('//arc/@id', $1))
  LOOP
    a := row(
      i,
      unnest(xpath(concat('//arc[@id="', node::varchar, '"]/@source'), $1)),
      unnest(xpath(concat('//arc[@id="', node::varchar, '"]/@target'), $1)),
      0
    )::arc;

    -- get weight
	  SELECT INTO inscription string_to_array(unnest(
        xpath(concat('//arc[@id="', node::varchar, '"]/inscription/value/text()'), $1)
    )::text, ',');

    -- query direction of arc
    SELECT INTO source_is_place xpath_exists(concat('//place[@id="', a.source, '"]'), $1);

    -- set direction
    IF source_is_place THEN
      a.weight := 0 - inscription[2]::bigint;
    ELSE
      a.weight := inscription[2]::bigint;
    END IF;

    i := i+1;

    RETURN NEXT a;
  END LOOP;
END;
$$ LANGUAGE plpgsql STABLE;

--SELECT * FROM pnmlArcs((SELECT pnml FROM pnml WHERE name = 'counter'));

--DROP function pnmlTransitions(xml);

-- construct list of places FROM pnml source
CREATE OR REPLACE FUNCTION pnmlTransitions(source xml) RETURNS SETOF transition
AS $$
DECLARE
  t transition;
  a arc;
  node xml;
  i bigint;
  vector bigint[];
  source_is_transition boolean;
  target_is_transition boolean;
  placeid integer;
  place_name varchar;
BEGIN
  i := 0;

  -- contruct empty vector
	FOR node in
    SELECT unnest(xpath(concat('//place'), $1))
  LOOP
    vector := vector || 0::bigint;
  END LOOP;

  -- construct transitions
	FOR node in
    SELECT unnest(xpath(concat('//transition/name/value/text()'), $1))
  LOOP
    t := row(
      i,
      node::varchar,
      vector
    )::transition;

    i := i+1;

    FOR a in
      SELECT * FROM pnmlArcs($1)
    LOOP
        
      place_name = NULL;

      IF a.source = t.label THEN
        place_name := a.target;
      END IF;

      IF a.target = t.label THEN
        place_name := a.source;
      END IF;

      IF place_name is not NULL THEN
        -- update transition vector with correct weighting
        SELECT INTO STRICT placeid (SELECT id+1 FROM pnmlPlaces($1) WHERE name = place_name);
        t.delta[placeid] := a.weight;
      END IF;

    END LOOP;

    RETURN NEXT t;
  END LOOP;
END;
$$ LANGUAGE plpgsql STABLE;

-- SELECT * FROM pnmlTransitions((SELECT pnml FROM pnml WHERE name = 'counter'));

--DROP function pnmlStateMachine(varchar);

-- construct state machine definitions FROM source pnml/xml

CREATE OR REPLACE FUNCTION pnmlStateMachine(net varchar) RETURNS ptnet
AS $$
DECLARE
  node xml;
  p place;
  t transition;
  net ptnet;
BEGIN
  SELECT into node (SELECT pnml FROM pnml WHERE name = $1);

  net := row(
    $1,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  )::ptnet;

  FOR p in
    SELECT * FROM pnmlPlaces(node)
  LOOP
    net.places := net.places || p;
    net.empty := net.empty || 0::bigint;
    net.capacity := net.capacity || p.capacity;
    net.initial := net.initial || p.initial;
  END LOOP;

  FOR t in
    SELECT * FROM pnmlTransitions(node)
  LOOP
    net.transitions := net.transitions || t;
  END LOOP;

  RETURN net;

END;
$$ LANGUAGE plpgsql STABLE;

--SELECT * FROM pnmlStateMachine('counter'::varchar);

-- convenience functions for querying stored pnml

CREATE OR REPLACE FUNCTION transitions(label varchar) RETURNS SETOF transition
AS $$
  SELECT * FROM pnmlTransitions((SELECT pnml FROM pnml WHERE name = $1));
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION places(net varchar) RETURNS SETOF place
AS $$
  SELECT * FROM pnmlPlaces((SELECT pnml FROM pnml WHERE name = $1));
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION arcs(net varchar) RETURNS SETOF arc
AS $$
  SELECT * FROM pnmlArcs((SELECT pnml FROM pnml WHERE name = $1));
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION pnmlCreateTables(net varchar) RETURNS void
AS $$
DECLARE
  schemaName varchar;
BEGIN
  schemaName := $1;

  -- Create db schema
  -- https://www.postgresql.org/docs/11/ddl-schemas.html#DDL-SCHEMAS-CREATE
  EXECUTE format('CREATE SCHEMA %I;', schemaName);

  -- Create tables
  EXECUTE format('CREATE TABLE %I.events () INHERITS (public.events);', schemaName);
  EXECUTE format('CREATE TABLE %I.states () INHERITS (public.states);', schemaName);
  
  -- Create trigger to enforce ptnet rules
  EXECUTE format(
    'CREATE TRIGGER %I_vclock '
    || 'BEFORE INSERT on %I.events '
    || 'FOR EACH ROW EXECUTE PROCEDURE public.vclock();'
    , schemaName, schemaName
  );

END;
$$ LANGUAGE plpgsql VOLATILE;

-- REVIEW: should we really return data here?
CREATE OR REPLACE FUNCTION pnmlInstall(net varchar, source xml) RETURNS void
AS $$
DECLARE
  schemaName varchar;
BEGIN
  schemaName := $1;

  -- Load PNML Source
  DELETE from public.pnml where name = schemaName;
  INSERT into public.pnml(name, pnml) values(schemaName, $2);

  -- Install PTNET State Machine
  DELETE FROM public.ptnet where schema = schemaName;
  INSERT INTO public.ptnet (SELECT * FROM pnmlStateMachine(schemaName));

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION pnmlDeploy(net varchar, source xml) RETURNS void
AS $$
  SELECT pnmlInstall(net, source);
  SELECT pnmlCreateTables(net);
$$ LANGUAGE sql VOLATILE;
