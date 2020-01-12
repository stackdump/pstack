CREATE TABLE condition (
  vector bigint[]
);

CREATE TABLE guard (
  vector bigint[]
);

CREATE TABLE address (
  identity varchar
);

CREATE TABLE qty (
  addr integer, --offset in address list
  amt bigint[], -- token interfaces with state machine via contract
  token integer
);

CREATE TABLE contract (
  addresses address[],
  input qty[],
  ouput qty[],
  guards guard[],
  conditions condition[]
) INHERITS (public.ptnet);

-- REVIEW: should this just be an added after-insert trigger on events?
CREATE OR REPLACE FUNCTION contractExecute(e events) RETURNS void
AS $$
DECLARE
BEGIN
  RAISE NOTICE 'EXEC CONTRACT %', e;
  -- validate guard roles
  -- test for redeem condition
  ASSERT 1 = 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- validate contract executions
CREATE OR REPLACE FUNCTION public.xclock() RETURNS TRIGGER
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

  SELECT random()*1000000 into NEW.nonce;

  EXECUTE contractExecute(NEW);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION contractDeploy(net varchar, source xml) RETURNS SETOF transition
AS $$
DECLARE
  schemaName varchar;
BEGIN
  schemaName := $1;

  EXECUTE format('CREATE SCHEMA %I;', schemaName);
  EXECUTE pnmlInstall(net, source);

  -- Create tables
  EXECUTE format('CREATE TABLE %I.events (nonce bigint) INHERITS (public.events);', schemaName);
  EXECUTE format(
    'CREATE TABLE %I.contract ('
    || ') INHERITS (public.contract);'
    , schemaName);

  EXECUTE format(
    'CREATE TABLE %I.states '
    || '(proc contract, deadline bigint, halted bool) '
    || 'INHERITS (public.states);'
    , schemaName);

  -- Create execution-clock 'xclock' trigger to enforce contract rules
  EXECUTE format(
    'CREATE TRIGGER %I_xclock '
    || 'BEFORE INSERT on %I.events '
    || 'FOR EACH ROW EXECUTE PROCEDURE public.xclock();'
    , schemaName, schemaName
  );
END;
$$ LANGUAGE plpgsql VOLATILE;

/*
------------------------
-- Contract Functions --
------------------------


-- REVIEW: consider implenting contract state-check for halted/open/valid etc... 
CREATE OR REPLACE FUNCTION contractState(net varchar, oid varchar) RETURNS SETOF state
AS $$
DECLARE
BEGIN
  --FIXME
END;
$$ LANGUAGE plpgsql STABLE;
*/
