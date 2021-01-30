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
  oid varchar,       -- origin id (genesis event) - entry hash where address is first used 
  head varchar,      -- latest entry affecting oid
  state uint[],      -- current state vector
  previous uint[],   -- previous state
  created_at timestamp, -- create time
  modified_at timestamp -- modified time
);

ALTER TABLE states ADD CONSTRAINT oid_pflow_pkey PRIMARY KEY (oid);

-------------
-- Command --
-------------

DROP TABLE IF EXISTS command;
CREATE TABLE command (
  action varchar,       -- action name of triggered transition
  multiple uint         -- multiple execution of an action 'x times'
);

------------
-- Events --
------------

DROP TABLE IF EXISTS events;
CREATE TABLE events (
  oid varchar,          -- origin id (genesis event)
  entryhash varchar,    -- entry hash of this event
  block uint,           -- block containing entry
  index uint,           -- order entry was confirmed in the block
  action command[],     -- array of commands
  input uint[],         -- snapshot state input
  output uint[],        -- snapshot of state output (becomes current state)
  created_at timestamp, -- time event is added to DB
  payload jsonb         -- event json data
);

ALTER TABLE events ADD CONSTRAINT oid_entry_block_pkey PRIMARY KEY (oid, entryhash, block, index);
