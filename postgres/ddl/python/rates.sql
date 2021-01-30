-- dump env vars
CREATE OR REPLACE FUNCTION get_rates_by_height(ht bigint) RETURNS json
AS $$
    import pegnet_py
    import json
    from datetime import datetime
    from factom import Factomd
    factomd = Factomd( host='http://localhost:8088' )
    pegnetd = pegnet_py.PegNetd()
    h = factomd.directory_block_by_height(ht)['dblock']['header']
    ts = h['timestamp']*60

    return json.dumps({
	"height": ht,
	"timestamp": ts,
        "datetime": datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'),
        'BTC': pegnetd.get_rates(ht)['pXBT'],
       	})
$$ LANGUAGE plpython3u;

-- apply pflow_events as they arrive
SELECT get_rates_by_height(282280); 

-- dump env vars
CREATE OR REPLACE FUNCTION get_rates() RETURNS json
AS $$
    import pegnet_py
    import json
    from datetime import datetime
    from factom import Factomd
    factomd = Factomd( host='http://localhost:8088' )
    pegnetd = pegnet_py.PegNetd()
    ht = factomd.heights()['leaderheight']
    h = factomd.directory_block_by_height(ht)['dblock']['header']
    ts = h['timestamp']*60

    return json.dumps({
	"height": ht,
	"timestamp": ts,
        "datetime": datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'),
        'BTC': pegnetd.get_rates(ht)['pXBT'],
       	})
$$ LANGUAGE plpython3u;

-- apply pflow_events as they arrive
SELECT get_rates(); 
