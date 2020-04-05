from python:3.7-buster

WORKDIR /opt/factom-shovel

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY entry.py .

ENTRYPOINT ["/usr/bin/python3"]

EXPOSE 8040
CMD ["entry.py"]
