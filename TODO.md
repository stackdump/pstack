WIP
---

- [ ] migrate pgsql storage from pstack into finite

consider storing state machine data https://www.postgresql.org/docs/12/plpython-sharing.html

BACKLOG
-------
- [ ] integrate live feed API

- [ ] clean up this deployment
- [ ] integrate latest python clients
      factom/fct-wallet/PegNet/FAT
- [ ] swap out PNML/PFLOW
      adapt: https://github.com/stackdump/ptflow
      for this purpose

- [ ] add Libs: https://github.com/factomatic/py-factom-did
- [ ] others?

- [ ] redesign to keep pflows only as python module

* API
- [ ]: try out using postgraphile as an express app
- [ ]: try out graphql subscriptions / websocket 

DONE
----

ICEBOX
----
- [ ]: add custom mutation for inserting pflow events via graphql
       or add instead-of-insert trigger to public.events
       idea is to always insert into child table

- [ ]: POC: build an exchange to allow FAT <-> PEG trading
