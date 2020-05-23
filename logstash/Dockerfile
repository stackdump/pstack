FROM docker.elastic.co/logstash/logstash-oss:7.6.1

WORKDIR /opt/logstash/vendor/jar/jdbc/
COPY ./jars/postgresql-42.1.4.jre7.jar .

RUN logstash-plugin install logstash-output-jdbc
#RUN logstash-plugin install logstash-output-websocket

