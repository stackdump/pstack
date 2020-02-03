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


# install pstack
COPY . .
RUN pip3 install -e .

# install database functions
COPY dbapi ./dbapi
RUN pip3 install -e ./dbapi


ENV PYTHON_PATH /usr/local/lib/python3.5/dist-packages

WORKDIR /docker-entrypoint-initdb.d

# install python db extension
RUN echo 'CREATE EXTENSION plpython3u;' > 000_extension.sql

# python functions
COPY dbapi/ddl/python/env.sql          101_env.sql
COPY dbapi/ddl/python/statemachine.sql 102_statemachine.sql
COPY dbapi/ddl/tables/eventstore.sql   103_eventstore.sql

# generate test data

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
