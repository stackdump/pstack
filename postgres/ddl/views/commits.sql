
DROP VIEW IF EXISTS commits;

CREATE OR REPLACE VIEW commits AS
SELECT
  event->>'Signature' as Signature,
  event->>'Credits' as Credits,
  event->>'Version' as Version,
  event->>'EntryHash' as EntryHash,
  event->>'EntryCreditPublicKey' as CreditPublicKey,
  event->>'EntityState' as EntityState
  -- (event->'Timestamp'->'nanos')::numeric as nanos,
  -- (event->'Timestamp'->'seconds')::numeric as seconds
FROM
 logstash where event->>'EventType' = 'EntryCommit';

-- should we partition by block height?

\x
SELECT * FROM commits limit 4;
