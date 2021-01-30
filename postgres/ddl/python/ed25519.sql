--DROP TYPE ed25519_keypair;
CREATE TYPE ed25519_keypair AS (sign varchar, verify varchar);

--DROP function generate_key();
CREATE OR REPLACE FUNCTION generate_key() RETURNS ed25519_keypair
AS $$
    import ed25519
    signing_key, verifying_key = ed25519.create_keypair()
    return signing_key.to_bytes().hex(), verifying_key.to_bytes().hex()
$$ LANGUAGE plpython3u STABLE;

--SELECT (generate_key()).* ;

CREATE TYPE signed_payload AS (data json, sig varchar);

--TODO can we sign json from DB & validate in python?
CREATE OR REPLACE FUNCTION sign(key varchar, data json) RETURNS signed_payload
AS $$
    return data, '<fakesig>'
$$ LANGUAGE plpython3u STABLE;

-- verify signed payload data
CREATE OR REPLACE FUNCTION verify(key varchar, payload signed_payload) RETURNS boolean
AS $$
    import json
    x = json.loads(payload['data'])
    return x != None and payload['sig'] == '<fakesig>'
$$ LANGUAGE plpython3u STABLE;

-- TODO: actually make this work
SELECT verify(k.verify, sign(k.sign, '{ "foo": "bar"}')) FROM generate_key() as k;

