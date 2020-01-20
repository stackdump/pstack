from stackdump/pstack-pgsql:latest
# python package dependencies and db extension
WORKDIR /opt

# install shovel
COPY factom-shovel ./factom-shovel
RUN pip3 install -e ./factom-shovel

ENTRYPOINT ["/usr/bin/python3"]

EXPOSE 8040
CMD ["/opt/factom-shovel/shovel.py"]
