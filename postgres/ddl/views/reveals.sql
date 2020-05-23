
DROP VIEW IF EXISTS reveals;

CREATE OR REPLACE VIEW reveals AS
SELECT
  event->>'ChainID' as ChainID,
  event->>'Hash' as EntryHash,
  event->>'Content' as Content,
  (event->'ExternalIds')::text as ExternalIds
  -- (event->'Timestamp'->'nanos')::numeric as nanos,
  -- (event->'Timestamp'->'seconds')::numeric as seconds
FROM
 logstash where event->>'EventType' = 'EntryReveal';

-- should we partition by block height?

\x
SELECT * FROM reveals limit 4;
