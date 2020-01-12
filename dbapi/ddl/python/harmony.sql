-- send data to blockchain
CREATE OR REPLACE FUNCTION public.broadcast() RETURNS TRIGGER
AS $$
DECLARE
BEGIN
  -- TODO: replace w/ plpython for dispatching to blockchain
  RAISE NOTICE 'broadcast';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- install broadcast trigger
CREATE OR REPLACE FUNCTION harmonyDeploy(varchar) RETURNS boolean
AS $$
DECLARE
  schemaName varchar;
BEGIN
  schemaName := $1;

  -- Create trigger to enforce ptnet rules
  EXECUTE format(
    'CREATE TRIGGER %I_ '
    || 'AFTER INSERT on %I.events '
    || 'FOR EACH ROW EXECUTE PROCEDURE public.broadcast();'
    , schemaName, schemaName
  );

  RETURN TRUE;

END;
$$ LANGUAGE plpgsql VOLATILE;

--SELECT harmonyDeploy('counter');

CREATE OR REPLACE FUNCTION harmonyInfo() RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.info()
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyInfo()

CREATE OR REPLACE FUNCTION harmonyCreateChain(external_ids varchar[], content json) RETURNS json
AS $$
    import json
    from dbapi import  client
    r = client.create_chain(external_ids, content)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u VOLATILE;

--SELECT harmonyCreateChain('{foobar}'::varchar[], '{ "hell0": "w0rld" }'::json) ;

CREATE OR REPLACE FUNCTION harmonyChain(chainid varchar) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.get_chain(chainid)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyChain('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23');

CREATE OR REPLACE FUNCTION harmonySearchChains(external_ids varchar[], off integer, lim integer) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.search_chains(external_ids, limit=lim, offset=off)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonySearchChains('{foo}', 0, 25) ;

--DROP FUNCTION harmonySearch(varchar[], integer, integer);
CREATE OR REPLACE FUNCTION harmonySearch(chainid varchar, external_ids varchar[], off integer, lim integer) RETURNS json
AS $$
    import json
    from dbapi import  client
    r = client.search(chainid, external_ids, limit=lim, offset=off)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonySearch('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23', '{foo,bar}', 0, 25)

CREATE OR REPLACE FUNCTION harmonyCreateEntry(chainid varchar, external_ids varchar[], content varchar) RETURNS json
AS $$
    import json
    from dbapi import  client
    r = client.put_entry(chainid, external_ids, content)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u VOLATILE;

--SELECT harmonyCreateEntry('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23', '{one,two}', 'testing')

CREATE OR REPLACE FUNCTION harmonyFirstEntry(chainid varchar) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.first_entry(chainid)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyFirstEntry('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23')

CREATE OR REPLACE FUNCTION harmonyLastEntry(chainid varchar) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.last_entry(chainid)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyLastEntry('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23')

CREATE OR REPLACE FUNCTION harmonyEntries(chainid varchar, off integer, lim integer) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.get_entries(chainid, limit=lim, offset=off)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyEntries('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23', 0, 25)

CREATE OR REPLACE FUNCTION harmonyEntry(chainid varchar, entryhash varchar) RETURNS json
AS $$
    import json
    from dbapi import client
    r = client.get_entry(chainid, entryhash)
    return json.dumps(r.to_dict())
$$ LANGUAGE plpython3u STABLE;

--SELECT harmonyEntry('19c2af8a29799bc00266adf6d9bb4e27b32dd0bd4e1cc082c2ae51bca0e67f23', '519e59f85e9b18988cbbc453f03d415cd91ea8f2755e7206bff2b71dade7ce52')
