-----------------
-- Unsiged Int -- 
-----------------

DROP DOMAIN IF EXISTS uint cascade;
CREATE DOMAIN uint AS BIGINT CHECK(VALUE >= 0 AND VALUE < 9223372036854775807);

-----------
-- State --
-----------

DROP TABLE IF EXISTS states;
CREATE TABLE states (
  oid varchar,       -- origin ID - first entry hash where address is used
  pflow varchar,     -- name of pflow definition
  state uint[],      -- current state vector
  previous uint[],   -- previous state
  created_at timestamp, -- create time
  modified_at timestamp -- modified time
);

ALTER TABLE states ADD CONSTRAINT oid_pflow_pkey PRIMARY KEY (oid, pflow);

------------
-- Events --
------------

DROP TABLE IF EXISTS events;
CREATE TABLE events (
  pflow varchar,        -- name of pflow definition
  oid varchar,          -- origin id (genesis event)
  entryhash varchar,    -- entry hash of this event
  seq uint,             -- order sub-actions contained in a single entry
  action varchar,       -- action name of triggered transition
  multiple uint,        -- x times execution of an action
  input uint[],         -- snapshot state input
  output uint[],        -- snapshot of state output (becomes current state)
  created_at timestamp, -- time event is added to DB
  payload jsonb         -- event json data
);

ALTER TABLE events ADD CONSTRAINT oid_pflow_seq_pkey PRIMARY KEY (oid, entryhash, seq, pflow);
