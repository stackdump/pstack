CREATE OR REPLACE FUNCTION encodeHash(n float) RETURNS varchar
AS $$
    from dbapi import encoding
    return encoding.encode(n)
$$ LANGUAGE plpython3u STABLE;

CREATE OR REPLACE FUNCTION decodeHash(s varchar) RETURNS float
AS $$
    from dbapi import encoding
    return encoding.decode(s)
$$ LANGUAGE plpython3u STABLE;

SELECT encodeHash(decodeHash(encodeHash(v))::float), decodeHash(encodeHash(v)), encodeHash(v) FROM (SELECT -0.900123456789 as v) as s;
SELECT encodeHash(decodeHash(encodeHash(v))::float), decodeHash(encodeHash(v)), encodeHash(v) FROM (SELECT 0.900123456789 as v) as s;

SELECT encodeHash(decodeHash(encodeHash(v))::float), decodeHash(encodeHash(v)), encodeHash(v) FROM (SELECT -0.500123456789 as v) as s;
SELECT encodeHash(decodeHash(encodeHash(v))::float), decodeHash(encodeHash(v)), encodeHash(v) FROM (SELECT 0.500123456789 as v) as s;
