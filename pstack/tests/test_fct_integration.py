import time
import unittest
from pstack.storage import new_uuid
from pstack.storage.factom import keyval as kv
from factom_sim import Factomd, FactomWalletd


# TODO: precompute chainid rather than just creating every time
CHAIN = "8ccb2446cfaa7915863cf5b3fad79653dfd92ce896f424c3bd635e0c88f20503"
SCHEMA = 'bar'

BLKTIME = 15  # sec

def wait_blocks(i):
    time.sleep(i * BLKTIME)

fnode = Factomd()
wallet = FactomWalletd()

def setUpModule():
    fnode.start()
    wallet.start()
    wait_blocks(2)
    stor = kv.initialize(CHAIN, SCHEMA)
    stor.wait_for_chain()


def tearDownModule():
    fnode.join()
    wallet.join()


# NOTE: currently this test is somewhat inconsistent
# Chainhead is created during first run & subsequent runs will pass
class FactomStorageTestCase(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    # TODO: test interacting w/ walletd & factomd using included lib

    def test_entry_creation(self):
        f = kv.factomd
        w = kv.walletd

        r = f.factoid_balance()
        print(r)

        r = f.entry_credit_balance()
        print(r)

        r = f.entry_credit_rate()
        print(r)
        rate = r['rate']

        r = f.entry_credit_balance()
        print(r)

        print(f.fct_address, f.ec_address)

        r = w.fct_to_ec(f, 50 * rate, fct_address=f.fct_address,
                        ec_address=f.ec_address)
        print(r)

        r = f.entry_credit_balance()
        print(r)

        # REVIEW: Perhaps we always leave the chain hardcoded?
        try:
            key = b'test'
            r = w.new_chain(f, [b'random', b'chain', b'id', key],
                            b'chain_content', ec_address=f.ec_address)

            self.assertEqual(CHAIN, r['chainid'])
            entry0 = r['entryhash']
            print({"chain": CHAIN, "entryhash": entry0})
            sleep(2)
        except Exception as x:
            r = f.chain_head(CHAIN)

        print(r)

        key = b'NTk0ZjBhZDctY2U0NS00NzhmLWIyN2ItODhhNDEzMGFjZGYy'
        r = w.new_entry(f, CHAIN, [b'random', b'entry', key],
                        b'entry_content', ec_address=f.ec_address)

        r = f.read_chain(CHAIN)
        print("\nCHAIN: %s\n" % CHAIN)
        for e in r:
            print(e)


if __name__ == '__main__':
    unittest.main()
