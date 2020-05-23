-- dump env vars
CREATE OR REPLACE FUNCTION pflow_event(evt json) RETURNS json
AS $$
    import json
    vout = {"FOO": "bar"}
    vout['event'] = json.loads(evt)
    return json.dumps(vout)
$$ LANGUAGE plpython3u;

-- TODO: add a wrapper to convert encoded entries into events
-- apply pflow_events as they arrive
SELECT pflow_event('{"Hash": "44622b3383496410012da77d365ac62d4870805a14ad52f0f3dd464f45671530", "type": "factomdLogs", "level": "info", "ChainID": "cffce0f409ebba4ed236d49d89c70e4bd1f1367d86402a336 3366683265a242d", "Content": "eyJ2ZXJzaW9uIjoxLCJ0cmFuc2FjdGlvbnMiOlt7ImlucHV0Ijp7ImFkZHJlc3MiOiJGQTNZbWF3b1NyTFlXTVFKZms1d3p4V1NuU0NNWmRhQUdGRlo4SFFtYWZLcjZQZTRmU0NzIiwiYW1vdW50IjozMTM1 MTk1NTkyMCwidHlwZSI6InBFVEgifSwiY29udmVyc2lvbiI6InBVU0QifV19", "message": "LIVE", "@version": "1", "Version.": 0, "EventType": "EntryReveal", "Timestamp": {"nanos": 632000, "seconds": 1587847325}, "@timestamp": "2020-04-25T20:42:06Z", "EntityState": 2, "ExternalIds": ["31353837383438323237", "01c157f4868a55f8b0e1b2cab3ece2c74526386e3419a07e5dbec7fd846e810ff9", "d148f55e b2887153b880d446021d580387a1c1b50ad54b7148137a3c6add9d0af3dc6eabeebdb3b6df1f7380f8cc2893d69e4fc378462a7b50884e1eeca45000"]}'::json); 
