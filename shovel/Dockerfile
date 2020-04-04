from python:3.7-buster
# python package dependencies and db extension
WORKDIR /opt/factom-shovel

# install shovel
COPY . .
RUN pip3 install -e /opt/factom-shovel

ENTRYPOINT ["/usr/bin/python3"]

EXPOSE 8040
CMD ["python", "-m", "shovel.run"]
