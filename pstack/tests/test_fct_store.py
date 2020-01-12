import time
import unittest
from finite.storage import new_uuid
from finite.storage.factom import keyval as kv
from factom_sim import Factomd, FactomWalletd

CHAIN = 'foo'  # fiendly name for chain
SCHEMA = 'bar'
OID = b'NTk0ZjBhZDctY2U0NS00NzhmLWIyN2ItODhhNDEzMGFjZGYy'
BLKTIME = 15  # sec
# toggle to run tests against external services

fnode = Factomd()
wallet = FactomWalletd()
stor = None  # datastore


def setUpModule():
    fnode.start()
    wallet.start()
    wait_blocks(2)
    stor = kv.initialize(CHAIN, SCHEMA)
    stor.wait_for_chain()


def tearDownModule():
    fnode.join()
    wallet.join()


def wait_blocks(i):
    time.sleep(i * BLKTIME)


class TestFactomStorage(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_events(self):
        """ test get/set event """
        wait_blocks(2)
        parent = "__PARENT__"
        event_id = b'eTk0ZjBhZDctY2U0NS00NzhmLWIyN2ItODhhNDEzMGFjZGYy'

        new_state = [0, 0, 0]

        commands = (('foo', 1), ('bar', 2))
        r = kv.append_event(CHAIN,
                            SCHEMA,
                            OID,
                            parent,
                            event_id,
                            commands,
                            new_state,
                            {"hello": "world"})
        self.assertIsNotNone(r)

        wait_blocks(1)

        e = kv.get_event(CHAIN, SCHEMA, OID, event_id)
        self.assertIsNotNone(e)
        self.assertEqual(e[2], new_state)

        r = kv.find_event(CHAIN, SCHEMA, OID, event_id)
        # FIXME: assert we found the proper event
        self.assertIsNotNone(r)

    def test_state(self):
        """ test get/set state """

        r = kv.get_state(CHAIN, SCHEMA, OID)
        self.assertIsNone(kv.get_state(CHAIN, SCHEMA, OID))
        event_id = new_uuid()

        new_state = [1, 1, 1]
        r = kv.set_state(
            CHAIN,
            SCHEMA,
            OID,
            event_id,
            new_state)
        self.assertTrue(r)

        r = kv.get_state(CHAIN, SCHEMA, OID)
        self.assertIsNotNone(r)
        self.assertEqual(r[0], event_id)
        self.assertEqual(r[1], new_state)


if __name__ == '__main__':
    unittest.main()
