---------------
-- Addition  --
---------------

-- vector addition with a multiplier
-- applies to $2 serving as a 'unit vector'
CREATE OR REPLACE FUNCTION vadd(bigint[], bigint[], uint) RETURNS bigint[]
AS $$
DECLARE
  i integer;
  state uint[]; -- assert output contains no negatives
BEGIN
  i := 1;

	WHILE i <= cardinality($1) LOOP
    state[i] := $1[i] + $3::uint * $2[i];
    i := i + 1;
  END LOOP;

  RETURN state;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vadd(uint[], bigint[]) RETURNS bigint[]
AS $$
BEGIN
  RETURN vadd($1::bigint[], $2, 1);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vadd(uint[], bigint[], bigint) RETURNS bigint[]
AS $$
BEGIN
  RETURN vadd($1::bigint[], $2, $3);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vadd(uint[], bigint[], bigint) RETURNS bigint[]
AS $$
BEGIN
  RETURN vadd($1::bigint[], $2, $3::uint);
END;
$$ LANGUAGE plpgsql;

-----------------
-- Subtraction --
-----------------

-- subtract two vectors - no multiplier
CREATE OR REPLACE FUNCTION vsub(bigint[], bigint[]) RETURNS bigint[]
AS $$
DECLARE
  i integer;
  state uint[]; -- uint domain excludes output with negative values
BEGIN
  i := 1;

	WHILE i <= cardinality($1) LOOP
    state[i] := $1[i] - $2[i];
    i := i + 1;
  END LOOP;

  RETURN state;
END;
$$ LANGUAGE plpgsql;


-- invalid output
-- SELECT vadd(ARRAY[0,-1], ARRAY[1,0]);

-- valid output
--SELECT vadd(ARRAY[1,-1], ARRAY[0,1]);
