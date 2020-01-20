-- dump env vars
-- REVIEW: should response be cached with ?
-- https://www.postgresql.org/docs/11/plpython-sharing.html
CREATE OR REPLACE FUNCTION machine(n varchar) RETURNS json
AS $$
    import json
    import pstack
    from pstack.storage.dict import Storage

    pstack.initialize(Storage)
    m = pstack.eventstore( schema=n, chain="_", oid="_") 
    return json.dumps({
        "schema": n,
        "places": m.places,
        "transitions": m.transitions
    })
$$ LANGUAGE plpython3u;

--SELECT machine('octoe');
