import unittest
from pstack.storage import new_uuid
from pstack.storage.dict import keyval as kv


class DictStorageTestCase(unittest.TestCase):

    def setUp(self):
        self.chain = new_uuid()
        self.oid = new_uuid()
        self.schema = 'testing_schema'
        kv.initialize(self.chain, self.schema)

    def tearDown(self):
        pass

    def test_events(self):
        """ test get/set event """
        parent = "__PARENT__"
        event_id = new_uuid()
        new_state = [0, 0, 0]

        commands = (('foo', 1), ('bar', 2))
        r = kv.append_event(chain=self.chain,
                            schema=self.schema,
                            oid=self.oid,
                            parent=parent,
                            event_id=event_id,
                            commands=commands,
                            new_state=new_state,
                            payload={"hello": "world"})
        self.assertIsNotNone(r)

        e = kv.get_event(chain=self.chain, schema=self.schema,
                         oid=self.oid, event_id=event_id)
        self.assertIsNotNone(e)

        self.assertEqual(e[2], new_state)

    def test_state(self):
        """ test get/set state """

        r = kv.get_state(chain=self.chain, schema=self.schema, oid=self.oid)
        self.assertIsNone(kv.get_state(chain=self.chain,
                                       schema=self.schema, oid=self.oid))
        event_id = new_uuid()

        new_state = [1, 1, 1]
        r = kv.set_state(
            chain=self.chain,
            schema=self.schema,
            oid=self.oid,
            head=event_id,
            new_state=new_state)
        self.assertTrue(r)

        r = kv.get_state(chain=self.chain, schema=self.schema, oid=self.oid)
        self.assertIsNotNone(r)
        self.assertEqual(r[0], event_id)
        self.assertEqual(r[1], new_state)


if __name__ == '__main__':
    unittest.main()
