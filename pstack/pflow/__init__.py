from pstack.pflow.xml import StateMachine, PFlowNet


def set_provider(storage):
    """ set storage provider class """

    assert storage.SOURCE_HEADER
    assert storage.reconnect
    assert storage.migrate

    StateMachine.storage_provider = storage


def load_file(path):
    p = StateMachine(PFlowNet(path))
    # FIXME
    # try:
    #    pass
    # except Exception as x:
    #    return p, x

    return p, None
