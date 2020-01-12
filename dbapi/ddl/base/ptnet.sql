-------------------
-- State Machine --
-------------------

-- install unsiged int datatype
CREATE DOMAIN uint AS BIGINT CHECK(VALUE >= 0 AND VALUE < 9223372036854775807);

--DROP TYPE token CASCADE;
CREATE TYPE token as (id integer, name varchar);

--DROP TABLE place CASCADE;
CREATE TABLE place (
  id integer,
  name varchar,
  capacity bigint,
  initial bigint,
  tokens token[]
);

--DROP TABLE arc CASCADE;
CREATE TABLE arc (label varchar, source varchar, target varchar, weight bigint);

--DROP TABLE transition CASCADE;
CREATE TABLE transition (id integer, label varchar, delta bigint[]);

--DROP TABLE attachment CASCADE;
-- REVIEW: digital object identifyer (DOI) for attachments
CREATE TABLE attachment (label varchar, data bytea, map jsonb, sig bytea);

--DROP TABLE IF EXISTS ptnet;
CREATE TABLE ptnet (
  schema varchar,
  places place[],
  transitions transition[],
  empty bigint[], -- all zeros / empty vector  {0,0...0}
  initial bigint[],
  capacity bigint[]
);

ALTER TABLE ptnet ADD CONSTRAINT id_schema_pkey PRIMARY KEY (schema);

-----------------
-- Event Store --
-----------------

--DROP TABLE IF EXISTS states;
CREATE TABLE states (
  oid varchar,
  seq uint,
  ptnet varchar,
  state uint[],
  previous uint[],
  created timestamp,
  modified timestamp
);

ALTER TABLE states ADD CONSTRAINT oid_ptnet_pkey PRIMARY KEY (oid, ptnet);

--DROP TABLE IF EXISTS events;
CREATE TABLE events (
  seq bigint,
  ptnet varchar,
  oid varchar,
  action varchar,
  mult uint,
  payload attachment[],
  created timestamp,
  input uint[],
  output uint[],
  broadcast boolean
);

ALTER TABLE events ADD CONSTRAINT oid_ptnet_seq_pkey PRIMARY KEY (oid, ptnet);

---------------------
-- PTnet Functions --
---------------------

CREATE OR REPLACE FUNCTION ptnetState(net varchar, id varchar) RETURNS SETOF states
AS $$
DECLARE
BEGIN
  RETURN QUERY EXECUTE format('SELECT
    oid,
    seq,
    ptnet,
    state,
    previous,
    created,
    modified
  FROM %I.states 
  WHERE
    ptnet = %L AND oid = %L
  ', $1, $1, $2);
  
END;
$$ LANGUAGE plpgsql STABLE;

--SELECT * from ptnetState('counter', 'uuid');

CREATE OR REPLACE FUNCTION ptnetEvent(net varchar, id varchar) RETURNS SETOF events
AS $$
DECLARE
BEGIN
  RETURN QUERY EXECUTE format(
  'SELECT
    seq,
    ptnet,
    oid,
    action,
    mult,
    payload,
    created,
    input,
    output,
    broadcast
  FROM %I.events 
  WHERE
    ptnet = %L AND oid = %L',
  $1, $1, $2);
  
END;
$$ LANGUAGE plpgsql STABLE;

--INSERT INTO counter.events (seq, oid, action, mult) values(1, 'uuid', 'INC_0', 1);
--SELECT * from ptnetEvent('counter', 'uuid');

CREATE OR REPLACE FUNCTION ptnetExists(net varchar) RETURNS boolean as $$
  SELECT EXISTS (SELECT schema from ptnet where schema = $1);
$$ LANGUAGE sql STABLE;

--SELECT * from ptnetExists('counter');

CREATE OR REPLACE FUNCTION ptnetStateExists(net varchar, id varchar) RETURNS boolean as $$
  SELECT EXISTS (SELECT * FROM ptnetState($1, $2));
$$ LANGUAGE sql STABLE;

--SELECT * from ptnetStateExists('counter', 'some-uuid');

-- initialize new state
CREATE OR REPLACE FUNCTION ptnetNewState(net varchar, id varchar) RETURNS boolean
AS $$
DECLARE
  m ptnet;
BEGIN
  -- state machine 
  SELECT * INTO STRICT m FROM
    public.ptnet
  WHERE
    schema = $1;

  EXECUTE format(
  'INSERT INTO
    %I.states(ptnet, oid, seq, created)
  VALUES
    (%L, %L, 0, NOW())',
  m.schema, $1, $2);

  -- NOTE: this function relies on inheritance to avoid specifying schema

  UPDATE states
  SET 
    state = m.initial,
    previous = m.empty,
    modified = now()
  WHERE
    ptnet = $1 AND oid = $2;

  RETURN true;
 -- TODO: should also initialize state?
END;
$$ LANGUAGE plpgsql VOLATILE;

-- Vector Clock function - enforces ptnet state machine rules
-- Add this trigger to any events table to apply
-- ptnet state machine verification ruleset.
--
-- NOTE: the extended events and states tables MUST extend public.events and public.states
CREATE OR REPLACE FUNCTION public.vclock() RETURNS TRIGGER
AS $$
DECLARE
  s states;
  m ptnet;
  t transition;
  delta int[];
  i integer;
BEGIN
  -- load state machine def
  SELECT * INTO STRICT m FROM
    public.ptnet
  WHERE
    schema = NEW.ptnet;

  -- check for existing state
  IF NOT EXISTS (SELECT * from ptnetState(m.schema, NEW.oid)) THEN
    PERFORM ptnetNewState(m.schema, NEW.oid);
  END IF;

  -- find state transition delta
  FOREACH t IN ARRAY m.transitions
  LOOP
    IF t.label = NEW.action THEN
      delta := t.delta;
      EXIT;
    END IF;
  END LOOP;

  -- assert input action is valid
  IF delta IS NULL THEN
    RAISE EXCEPTION 'Unknown Action(%)', NEW.action;
  END IF;

  -- assert multiplier is > 0
  IF NEW.mult <= 0 THEN
    RAISE EXCEPTION 'Multiplier must be > 0';
  END IF;

  -- apply transformation
  UPDATE states
    SET 
      seq = seq + 1,
      previous = state,
      state = vadd(state, delta, NEW.mult),
      modified = now()
  WHERE
    oid = NEW.oid AND ptnet = NEW.ptnet;

  -- fetch new state record
  SELECT * INTO STRICT s FROM
    states 
  WHERE
    oid = NEW.oid AND ptnet = NEW.ptnet;

  -- test for exceeded capacity
  FOR i IN 1..cardinality(m.capacity)
  LOOP
    if s.state[i] > m.capacity[i] THEN
      RAISE EXCEPTION 'Exceeded Capacity (%) at Offset (%)', m.capacity[i], i;
    END IF;
  END LOOP;

  -- populate the new record
  NEW.input := s.previous;
  NEW.output := s.state;
  NEW.seq := s.seq;
  NEW.created := NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
