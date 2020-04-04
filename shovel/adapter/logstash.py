#!/usr/bin/env python
"""
Listens to Live Feed
Forward entry event data to Logstash
"""
from shovel import listener
from shovel import log

def push_to_logstash(task_type, payload):
    """ forward data to logstash """
    log.info(task_type, extra=payload)

if __name__ == "__main__":
    print("start shovel tcp://0.0.0.0:8040")
    listener.event_loop(push_to_logstash)
