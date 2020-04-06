-- dump env vars
CREATE OR REPLACE FUNCTION env() RETURNS json
AS $$
    import os
    import json
    out = {}
    for k, v in os.environ.items():
        out[k] = v
    return json.dumps(out)
$$ LANGUAGE plpython3u;

--SELECT env();
