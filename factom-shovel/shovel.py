#!/usr/bin/env python
"""
A shovel for pushing events from factom netowork into the db
"""
import json
import logging
import os
import requests
import socket
import struct
import time
import traceback
from math import ceil

MAX_PARCEL_SIZE = 1000000

log_level = os.environ.get("LOG_LEVEL", "info")
log_levels = {
    "debug": logging.DEBUG,
    "info": logging.INFO,
    "warning": logging.WARNING,
    "error": logging.ERROR,
    "critical": logging.CRITICAL,
}
if log_level.lower() not in log_levels:
    # logging.critical(f"Invalid LOG_LEVEL set: {log_level}")
    import sys

    sys.exit(-1)
logger = logging.getLogger()
logger.setLevel(log_levels[log_level.lower()])

live_feed_host = os.environ.get("LIVE_FEED_HOST", "127.0.0.1")
live_feed_port = int(os.environ.get("LIVE_FEED_PORT", 8040))

LIVE_FEED_TYPE_DIRECTORY_BLOCK_COMMIT = "directoryBlockCommit"
LIVE_FEED_TYPE_ENTRY_COMMIT = "entryCommit"
LIVE_FEED_TYPE_ENTRY_REVEAL = "entryReveal"
LIVE_FEED_TYPE_STATE_CHANGE = "stateChange"
LIVE_FEED_TYPE_PROCESS_MESSAGE = "processMessage"
LIVE_FEED_TYPE_NODE_MESSAGE = "nodeMessage"
LIVE_FEED_TYPES_TO_SHOVEL = {
    LIVE_FEED_TYPE_DIRECTORY_BLOCK_COMMIT,
    LIVE_FEED_TYPE_ENTRY_REVEAL}


def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((live_feed_host, live_feed_port))
        s.listen(1)
        #logging.info("Listening for LiveFeed connection...")
        conn, address = s.accept()
        with conn:
            # logging.info(f"Connected to LiveFeedAPI: {address}")
            while True:
                protocol_version = conn.recv(1)
                if not protocol_version:
                    break
                conn.sendall(protocol_version)
                if protocol_version[0] == 1:
                    next_message_size_bytes = conn.recv(4)
                    next_message_size = struct.unpack(
                        "<i", next_message_size_bytes)[0]
                    if next_message_size is not None:
                        message_data = conn.recv(next_message_size)
                        shovel(message_data)


def shovel(data: bytes):
    try:
        event_data = json.loads(data.decode('utf8'))
        # print(event_data)
        if "Event" not in event_data:
            raise ValueError(
                'JSON input data must contain a root level "Event" element')
    except ValueError as e:
        # logging.error(f"Bad shovel input: {e}")
        print(e)
        return

    event = event_data["Event"]
    if len(event.keys()) != 1:
        return

    live_feed_event_type = list(event.keys())[0]
    if live_feed_event_type not in LIVE_FEED_TYPES_TO_SHOVEL:
        return
    task_payload = event.get(live_feed_event_type, {})

    if live_feed_event_type == LIVE_FEED_TYPE_DIRECTORY_BLOCK_COMMIT:
        task_type = "DirectoryBlockCommit"
    elif live_feed_event_type == LIVE_FEED_TYPE_ENTRY_COMMIT:
        task_type = "EntryCommit"
    elif live_feed_event_type == LIVE_FEED_TYPE_ENTRY_REVEAL:
        task_type = "EntryReveal"
    else:
        return

    # TODO: figure out how to route data ? do we filter by chain?
    process(task_type, payload)


def process(task_type: str, payload: dict):
    """
    """
    # Cloud Task size limit is 100K, so we store the payload in Datastore
    # and pass the entity key in the task body instead
    # TODO: figure out how to route data ? do we filter by chain?
    print(json.dumps(payload, indent=4))


if __name__ == "__main__":
    while True:
        try:
            main()
        except ConnectionResetError:
            #logging.warning("Connection reset by peer. Sleeping 5 seconds and restarting...")
            # SHOVEL_ERROR_COUNTER.labels("connection_reset").inc()
            time.sleep(5)
        except KeyboardInterrupt:
            #logging.info("KeyboardInterrupt received, shutting down...")
            break
