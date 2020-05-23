FROM postgres:11

RUN apt-get update  && \
    apt-get -y install git python3-dev python3-pip python3 postgresql-contrib-11 postgresql-plpython3-11 postgresql-11-python3-multicorn

RUN apt-get clean && \
rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# python package dependencies and db extension
WORKDIR /opt

# provide numpy by default
RUN pip3 install cython>=0.25.1 numpy>=1.14.0 python-baseconv>=1.2.1 multicorn

# install python packages
COPY postgres/requirements.txt ./requirements.txt
RUN pip3 install -r ./requirements.txt

WORKDIR /docker-entrypoint-initdb.d

# install python db extension
RUN echo 'CREATE EXTENSION plpython3u;' > 000_extension.sql

# install stored python functions
COPY postgres/ddl/python/env.sql          101_env.sql
COPY postgres/ddl/python/ed25519.sql      102_ed25519.sql

# install tables
COPY postgres/ddl/tables/logstash.sql     103_logstash.sql

ENV PYTHON_PATH /usr/local/lib/python3.5/dist-packages

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
