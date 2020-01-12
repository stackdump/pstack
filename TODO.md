WIP
---

- [ ] add Libs: https://github.com/factomatic/py-factom-did

NOTE: have to port library to work w/ python 3.5

BACKLOG
-------
- [ ] migrate pgsql storage from pstack into finite

- [ ] swap out PNML/PFLOW
      adapt: https://github.com/stackdump/ptflow
      for this purpose

- [ ] redesign to keep pflows only as python module rather than installing as tables

DONE
----

ICEBOX
------
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
