import time

_STATE = "_STATE"

_EVENT = "_EVENT"

__STOR = {'_SCHEMA': {_EVENT: None, _STATE: None}}
""" simple k/v storage """

# REVIEW:
# consider refactoring to support
# https://docs.scipy.org/doc/numpy/reference/generated/numpy.memmap.html


def initialize(chain=None, schema=None, oid=None):
    global __STOR
    k = _chainid(chain, schema)

    if k not in __STOR:
        # NOTE: oid isn't used here
        # other storage mechanisms may use it for sharding
        __STOR[k] = {_EVENT: {}, _STATE: {}}


def _chainid(chain=None, schema=None):
    return schema + "::" + chain


def get_state(chain=None, schema=None, oid=None):
    global __STOR
    d = None
    try:
        d = __STOR[_chainid(chain, schema)][_STATE][oid]
    except KeyError as x:
        pass
    return d


def set_state(chain=None, schema=None, oid=None, head=None, new_state=None):
    """ set new state """
    global __STOR
    stored = False
    try:
        __STOR[_chainid(chain, schema)][_STATE][oid] = (head, new_state)
        stored = True
    except KeyError as x:
        pass
    return stored


def append_event(chain=None, schema=None, oid=None, parent=None,
                 event_id=None, commands=None, new_state=None, payload=None):
    """ store new event """

    global __STOR
    stored = False
    k = _chainid(chain, schema)

    if oid not in __STOR[k][_EVENT]:
        __STOR[k][_EVENT][oid] = {}

    try:
        __STOR[k][_EVENT][oid][event_id] = (
            parent, commands, new_state, payload, time.time())
        stored = True
    except KeyError as x:
        pass
    return stored


def get_event(chain=None, schema=None, oid=None, event_id=None):
    """ retrieve previous event """

    global __STOR
    d = None
    k = _chainid(chain, schema)

    try:
        d = __STOR[k][_EVENT][oid][event_id]
    except KeyError as x:
        pass
    return d
