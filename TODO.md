WIP
---
working to improve factom chain init routines

- [ ] try caching state machine def in local storage

BACKLOG
-------

- [ ] improve chain intialization 
- [ ] migrate pgsql storage to work from plpython
- [ ] redesign to keep pflows only as python module rather than installing as tables

DONE
----

ICEBOX
------
- [ ] finish forking for pythoon 3.5 - https://github.com/factomatic/py-factom-did
- [ ] fix/Test Shovel to work with postgres
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
