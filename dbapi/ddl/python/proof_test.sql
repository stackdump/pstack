--DROP FUNCTION test_generate_proof(int);

CREATE OR REPLACE FUNCTION test_generate_proof(n int) RETURNS SETOF jsonb
AS $$
    """
    """
    import json
    import time
    import numpy as np
    from numpy.random import randint, seed
    result = []

    def v(*c):
        ''' format postgres arrays '''
        return '{' +','.join(str(x) for x in c) +'}'

    limit = v(100,100,100)

    def proof(nonce, input):
        rows = plpy.execute("""
            select * from generate_proof(%i, '%s', '%s')
        """ % (nonce, limit, v(*input)))

        for r in rows:
            p = json.loads(r['generate_proof'])
            l = {
                'matrix': p['priv']['matrix'],
                'nonce': p['priv']['nonce'],
                'nonce_pub': p['pub']['nonce'],
                'witness': p['pub']['witness'],
                'proof': p['pub']['proof']
            }
            result.append(json.dumps(l))

    def main():
        state = np.array([1,0,0])
        transitions = [
            [-1, 1, 0],
            [0, -1, 1],
            [1, 0, -1]
        ]
        
        i = 0
        nonce = randint(0,2**32-1)
        while i < n:
            txn = transitions[i%3]
            next = state + txn

            try:
                seed(nonce) # chain seeds to avoid duplication
                nonce = randint(0,2**32-1)
                proof(nonce, next.tolist())
                state = next
                i += 1
            except Exception as x:
                l = {
                    'i': i,
                    'err': "%s" % x,
                    'fail': True,
                    'txn': txn,
                    'nonce': nonce,
                    'input': state.tolist()
                }
                result.append(json.dumps(l))

        return result

    return main()
$$ LANGUAGE plpython3u;

DROP TABLE IF EXISTS counter.samples;

-- FIXME: something is wrong w/ the nonce generation method when generating large sets

-- BAD generate 1M samples
/*
(533 rows) - failed to find solution

  unique_entries
----------------
          42137
(1 row)

 groups |       ave_dup       | events_w_duplicotion
--------+---------------------+----------------------
  55338 | 17.3093172864939102 |               957863
(1 row)

*/

-- GOOD generate 100k unique samples
/*
(46 rows) - failed to find solution

 unique_entries
----------------
         100000
(1 row)

 groups | ave_dup | events_w_duplication
--------+---------+----------------------
      0 |         |
(1 row)
*/

-- default to creating 1k samples
-- returns ~3-4 failed proofs each time
CREATE TABLE counter.samples as (SELECT event.* FROM test_generate_proof(250) as event);


-- NOTE: some of our random linear systems will not have solutions
-- this query lists our parameters that could not form a proper proof
SELECT
  count(*) AS solver_failures
  --event->'i' as i,
  --event->'input' as witness,
  --event->'err' as error
FROM
  counter.samples
WHERE
  event ? 'fail';

-- count unique entries
SELECT count(*) as valid_unique_entries FROM (SELECT DISTINCT
  s.input, s.proof, s.nonce, count(*) as count
  FROM (SELECT 
      event->'matrix'->0 as input,
      event->'nonce' as nonce,
      event->'proof' as proof
    FROM
      counter.samples
    WHERE
      event ? 'matrix'
      AND
      NOT event ? 'fail') as s
  GROUP BY
    s.proof, s.input, s.nonce) as g
WHERE 
   count = 1;

-- look for duplication - this should be 0
SELECT
  count(*) AS matching_groups,
  coalesce(AVG(cnt), 0) AS average_amount_of_duplication,
  coalesce(CAST (count(*)*AVG(cnt) AS INT), 0) AS event_count_w_duplication
FROM (SELECT DISTINCT
  s.input,
  s.proof,
  s.matrix,
  --s.nonce,
  --s.nonce_pub,
  count(*) as cnt
  FROM (SELECT 
      event->'matrix'->0 as input,
      concat(event->'matrix'->1, event->'matrix'->2) as matrix,
      event->'nonce' as nonce,
      event->'nonce_pub' as nonce_pub,
      event->'proof' as proof
    FROM
      counter.samples
    WHERE
      event ? 'matrix'
      AND
      NOT event ? 'fail') as s
  GROUP BY
    s.input,
    s.proof,
    s.matrix
    --s.nonce,
    --s.nonce_pub,
  ) as g
WHERE 
   cnt > 1;

SELECT
  event->'nonce' as nonce,
  event->'matrix'->0  as data,
  event->'witness' as witness,
  event->'proof' as proof
FROM
  counter.samples
LIMIT
  25;
