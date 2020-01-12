import json
from pstack.storage import new_uuid


class Unimplemented(Exception):
    pass


class RoleFail(Exception):
    pass


SUPERUSER = '*'
""" role used to bypass all permission checks """

ROOT_UUID = '00000000-0000-0000-0000-000000000000'
""" parent UUID used to initialize a stream """

DEFAULT_SCHEMA = 'base'
""" event schema to use if not provided """


class Storage(object):

    SOURCE_HEADER = "from pstack.storage.factom import Storage"
    """ import line used to include this class in generated code """

    EVENT = "_EVENT"
    """ event table """

    STATE = "_STATE"
    """ state table """

    @staticmethod
    def reconnect(**kwargs):
        """ create connection pool """

    @staticmethod
    def drop():
        """ drop evenstore tables """

    @staticmethod
    def migrate():
        """ create evenstore tables if missing """

    def __init__(self, **kwargs):
        """ set object uuid for storage instance """
        # REVIEW: should chain be static?
        print(kwargs)

    def __call__(self, action, **kwargs):
        """ append a new event """
        # REVIEW: should chainid be a kwarg?

        event_id = str(uuid.uuid4())
        payload = None
        new_state = None
        err = None

        try:
            if 'multiple' in kwargs:
                multiple = int(kwargs['multiple'])
            else:
                multiple = 1

            if 'payload' in kwargs:
                if isinstance(kwargs['payload'], dict):
                    payload = json.dumps(kwargs['payload'])
                else:
                    # already json encoded string
                    payload = kwargs['payload']
            else:
                # cannot be null
                payload = "{}"

            def _txn():

                # TODO access datastore
                #cur.execute(sql.get_state, (self.oid, self.schema))

                # FIXME
                #previous = cur.fetchone()
                raise Unimplemented("FIXME")

                if not previous:
                    current_state = self.initial_vector()
                    parent = ROOT_UUID
                else:
                    current_state = previous[2]
                    parent = previous[3]

                new_state, role = self.transform(
                    current_state, action, multiple)

                if role not in kwargs['roles'] and SUPERUSER not in kwargs['roles']:
                    raise RoleFail("Missing Required Role: " + role)

                # TODO access datastore
                # cur.execute(sql.set_state,
                #    (self.oid, self.schema, new_state, event_id, new_state, event_id, self.schema, self.oid)
                # )

                # cur.execute(sql.append_event,
                #    (event_id, self.oid, self.schema, action, multiple, payload, new_state, parent)
                # )

            _txn()

        except Exception as x:
            err = x

        return event_id, new_state, err

    def events(self):
        """ list all events """

    def event(self, uuid):
        """ get a single event """

    def state(self):
        """ get state """
