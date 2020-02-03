WIP
---
- [ ] improve chain intialization 
- [ ] migrate pgsql storage to work from plpython
- [ ] fix/Test Shovel to work with postgres

BACKLOG
-------
- [ ] build new wsapi on top of DB - will be enduser facing
- [ ] integrate pegnet protocol
- [ ] finish forking DID/VC operations for pythoon 3.5 - https://github.com/factomatic/py-factom-did

DONE
----
- [x] redesign to keep pflows only as python module rather than installing as tables

ICEBOX
------
- [ ] try caching state machine def in local storage
- [ ] add haproxy to this deployment
- [ ]: try out using postgraphile as an express app
- [ ]: try out graphql subscriptions / websocket 

- [ ] integrate live feed API

- [ ] integrate latest python clients
      factom/fct-wallet/PegNet/FAT

- [ ]: add custom mutation for inserting pflow events via graphql
       or add instead-of-insert trigger to public.events
       idea is to always insert into child table

- [ ]: POC: build an exchange to allow FAT <-> PEG trading


NOTES
-----

consider storing state machine data https://www.postgresql.org/docs/11/plpython-sharing.html

Cloud Deployment: https://github.com/graphile/postgraphile-lambda-example
