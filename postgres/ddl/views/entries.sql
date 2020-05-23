
-- get both commit/reveal parts

DROP MATERIALIZED VIEW IF EXISTS entries;

CREATE MATERIALIZED VIEW entries AS

SELECT
  version,
  signature,
  entryhash,
  entrycreditpublickey,
  chainid,
  content,
  externalids

FROM 

(SELECT
    event->>'Signature' as signature,
    event->>'Credits' as credits,
    event->>'Version' as version,
    event->>'EntryHash' as commithash,
    event->>'EntryCreditPublicKey' as entrycreditpublickey
  FROM
    logstash
  WHERE
    event->>'EventType' = 'EntryCommit'
  AND
    event->>'EntityState' = '1' -- 'accepted'
) as commits

JOIN

(SELECT
    event->>'ChainID' as chainid,
    event->>'Hash' as entryhash,
    event->>'Content' as content,
    (event->'ExternalIds')::text as externalids
  FROM
    logstash
  WHERE
    event->>'EventType' = 'EntryReveal'
  AND
    event->>'EntityState' = '1' -- 'accepted'
) as reveals

ON commithash = entryhash;

\x
select * from entries where entryhash  = '6f805338d7f0bd3c09ba8408b3d15c121af542244f7210cec949d6cb6054e48c';
