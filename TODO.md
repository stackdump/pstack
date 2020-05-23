WIP
---

- [ ] Refine Postgres Schema - test w/ Postgraphile

      build a simple FAT-1 compatible chain

https://www.npmjs.com/package/@graphile/subscriptions-lds

BACKLOG
-------

- [ ] run https://webtorrent.io/faq on IPFS site
- [ ] ? add postgres notify to query factomd
- [ ] build address threshold/alerts
- [ ] use JWT auth + login with github
- [ ] add volumes for data
- [ ] add FAT daemon 

ICEBOX
------
- [ ] create custom dashboard - can you source postgres from ELK?

- [ ] experiment with EC addresses as auth
- [ ] add geth node?
- [ ] add IPFS node?

* Prototype Ideas

- [ ] IPFS DAG ipfs-ld based event prototcol?

- [ ] add UI addresss/donate badges for github
      validate highest saved signed commit - as an estimate of trust

- [ ] prototype PegNet Payments
- [ ] prototype a consensus agent - wields delegated signing authority on behalf of keyholder
- [ ] add IPFS hosted website
- [ ] integrate Golang based PKI w/ DB
- [ ] cloud-based Pub-Sub for frontend vs IPFS pub-sub?

- [ ] https://github.com/cloudevents/spec/blob/v1.0/json-format.md#31-handling-of-data
      support this standard? - mostly just seems like a wrapper - actual data is encoded
      reminds me of same relation in factomd entries w/ payload and refids


DONE
----
- [x] adjust logstash to make sense of the entire workflow
- [x] add EventLog stream from Factomd
- [x] use JDBC adapter to push from logstash to postgres
      add Jar file?

ABANDON
-------
- [ ] think about open trace integration to watch messages

since logstash is the main input stream
plugins and filters provide the best option to observe event data.

