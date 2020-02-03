---------------------
-- PTnet Functions --
---------------------
\x

TRUNCATE events;

INSERT INTO EVENTS (pflow, oid, entryhash, seq, action, multiple, input, output, created_at, payload)
values ('octoe', 'foid', 'entryhash', 0, 'NOOP', 1, '{0, 0, 0}', '{0, 0, 0}', now(), '{ "foo": "bar"}');

SELECT * FROM EVENTS;

CREATE OR REPLACE FUNCTION transform(pflow varchar, oid varchar) RETURNS json
AS $$
    import json
    import pstack
    from pstack.storage.dict import Storage

    pstack.initialize(Storage)
    m = pstack.eventstore( schema=pflow, chain="_", oid="_") 

    # FIXME: actually execute the transformation instead
    return json.dumps({
        "schema": pflow,
        "places": m.places,
        #"transitions": m.transitions
    })
$$ LANGUAGE plpython3u;

SELECT transform('octoe', 'NOOP');
