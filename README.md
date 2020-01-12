# pStack

App stack for developing Applications on top of Factomd/PegNet/FAT.

It's also trival to extend by adding python clients for other blockchains or services.

Though most of the backend functionaity is coded in python,
it's primarily intended to be used as blockchain middleware presenting function calls
via Postgraphile GraphQL api or any standard Postgres client.

## Motivation

While working in the Factom ecosystem - many layer2 protocols have emerged.
This is an attempt to aggregate many them into a unified framework.

### Design - Models

Applications for this framework use models developed using Pflow digrams.

related pflow projects:
* https://github.com/FactomProject/ptnet-eventstore
* https://www.blahchain.com/pflow-editor/
* https://github.com/stackdump/pfinance-primitives
* https://github.com/stackdump/ptflow

### Design - API

PostgreSQL db lives at the core of this framework and it serves a few purposes:

* Provide a basis for atomic operations accross chains
* Plpython support
  * Layers can be build on top - depending *only* on a PostgreSQL client library
  * Migration of data and code are scheduled strategically on block boundaries
* With Postgraphile + plpython it provides an API abstraction


## Developer Usage

Open a postgres console

```
docker-compose exec pstack psql -U pstack
```

Use wallet to fund an EC address

```
./factom/test.sh buyec
TxID: 1987e472253ca1ad796990207c8841296d3e82d8f48be135cbc499049f2e7165
Status: TransactionACK
./factom/test.sh  list
FA2jK2HcLnRdS94dEcU27rF3meoJfpUcZPSinpb7AwQvPRY6RL1Q 19999.97988
EC3Hu1W7uMHf7CtSva1cMyr5rXKsu7rVqQtkJCDHqEV9dgh5FjAj 2000
```
