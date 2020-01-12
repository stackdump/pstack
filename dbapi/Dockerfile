FROM postgres:11

RUN apt-get update 
RUN apt-get -y install git python3-dev python3-pip python3 postgresql-contrib-11 postgresql-plpython3-11

RUN apt-get clean && \
rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# python package dependencies and db extension
WORKDIR /opt

COPY requirements.txt ./requirements.txt

# install database api and required python packages
RUN pip3 install cython>=0.25.1 numpy>=1.14.0 python-baseconv>=1.2.1
RUN pip3 install -r ./requirements.txt

COPY dbapi ./dbapi
RUN pip3 install -e ./dbapi

# install python db extension
ENV PYTHON_PATH /usr/local/lib/python3.5/dist-packages

WORKDIR /docker-entrypoint-initdb.d
RUN echo 'CREATE EXTENSION plpython3u;' > 000_extension.sql

# base state machine tables and functions
# COPY dbapi/ddl/base/ptnet.sql        001_ptnet.sql
# COPY dbapi/ddl/base/pnml.sql         002_pnml.sql
# COPY dbapi/ddl/base/vectors.sql      003_vectors.sql
# COPY dbapi/ddl/base/contracts.sql    004_contracts.sql

# python functions
COPY dbapi/ddl/python/env.sql        101_env.sql
# COPY dbapi/ddl/python/ed25519.sql    102_ed25519.sql
# COPY dbapi/ddl/python/proof.sql      103_proof.sql
# COPY dbapi/ddl/python/harmony.sql    104_harmony.sql
# COPY dbapi/ddl/python/encoding.sql   105_encoding.sql

# schemata definitions
# COPY dbapi/ddl/counter/schema.sql    200_counter_schema.sql
# COPY dbapi/ddl/auction/schema.sql    201_auction_schema.sql

# generate test data
# COPY dbapi/ddl/python/proof_test.sql 300_proof_test.sql
# COPY dbapi/ddl/counter/test.sql      301_counter_test.sql
# COPY dbapi/ddl/auction/test.sql      302_auction_test.sql

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
