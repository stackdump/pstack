--------------
-- logstash --
--------------

/*
DROP TABLE IF EXISTS logstash;
CREATE TABLE logstash(
  event jsonb -- logstash data
);
*/

-- TODO: alter logstash to call this function instead of inserting
CREATE OR REPLACE FUNCTION eventlog(evt json) RETURNS bool
AS $$
BEGIN
  raise notice '%', evt->>'EventType';
  RETURN null;
END;
$$ LANGUAGE plpgsql;


--CREATE TRIGGER append_log INSTEAD OF INSERT on logstash 
SELECT eventlog('{ "EventType": "TestEvent" }'::json);
