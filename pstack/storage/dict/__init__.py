import json
import pstack.storage as stor
from pstack.storage.dict import keyval as kv

new_uuid = stor.new_uuid


class Storage(object):

    SOURCE_HEADER = "from pstack.storage.dict import Storage"
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

    def __init__(self, schema=None, chain=None, oid=None):
        """
        set identifiers for storage instance

        NOTE: OID set to None if the intention
        is to inspect the state machine attributes
        """

        self.schema = schema
        self.chain = chain

        if oid is not None:
            self.oid = oid
            kv.initialize(schema=self.schema, chain=self.chain, oid=self.oid)

    def __call__(self, action, **kwargs):
        """ append a new event """
        # REVIEW: should chainid be a kwarg?

        event_id = new_uuid()
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

            previous = kv.get_state(self.chain, self.schema, self.oid)

            if not previous:
                parent = stor.ROOT_UUID
                current_state = self.initial_vector()
            else:
                parent = previous[0]
                current_state = previous[1]

            # FIXME support multiple actions
            new_state, role = self.transform(current_state, action, multiple)

            if role not in kwargs['roles'] and stor.SUPERUSER not in kwargs['roles']:
                raise stor.RoleFail("Missing Required Role: " + role)

            kv.set_state(
                self.chain,
                self.schema,
                self.oid,
                event_id,
                new_state)

            # FIXME actually support multiple actions
            kv.append_event(
                self.chain, self.schema, self.oid, parent, event_id, [
                    (action, multiple)], new_state, payload)

        except Exception as x:
            err = x

        return event_id, new_state, err

    def events(self):
        """ list all events """
        # TODO: implement this query

    def event(self, uuid):
        """ get a single event """
        return kv.get_event(self.chain, self.schema, self.oid, uuid)

    def state(self):
        """ get state """
        return kv.get_state(self.chain, self.schema, self.oid)
