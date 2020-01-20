import os
import glob
import pstack.pflow as pflow_loader

EVENTSTORE = {}
""" loaded eventstore objects indexed by schema """


def initialize(provider, **kwargs):
    """ reload eventstorage instances """

    pflow_loader.set_provider(provider)
    provider.reconnect(**kwargs)
    provider.migrate()

    if 'dirname' not in kwargs:
        kwargs['dirname'] = os.environ.get(
            'PTFLOW_DIR',
            os.path.abspath(
                os.path.dirname(
                    os.path.abspath(__file__)) +
                "/../pflow")  # default to included pflow files
        )
        #print('DIR ->', kwargs['dirname'])

    for pf in glob.glob(kwargs['dirname'] + "/*.pflow"):
        es, _ = pflow_loader.load_file(pf)
        # load definition as a python class
        # print(es.to_source())
        EVENTSTORE[es.name] = es.to_module().Machine


def eventstore(schema=None, chain=None, oid=None):
    """ get statemachine eventstore by schema name """
    if schema is None or schema == '':
        raise Exception("Schema Cannot be Empty")

    if chain is None or chain == '':
        raise Exception("Chain Cannot be Empty")

    return EVENTSTORE[schema](schema=schema, chain=chain, oid=oid)


def schemata():
    """ list names of state machines """
    return [k for k in EVENTSTORE]
