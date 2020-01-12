import unittest
import pstack
from pstack.storage.dict import Storage


class OctoeTestCase(unittest.TestCase):

    def setUp(self):
        pstack.initialize(Storage)
        self.m = pstack.eventstore(
            schema='octoe',
            chain='mychain',
            oid="test_oid")

    def tearDown(self):
        self.m.drop()

    def test_guards(self):
        def x_fail(action):
            res = self.m(action, roles=['*'], payload={'foo': 'bar'})
            #print(action, res)
            self.assertIsNotNone(res[2])

        def x_pass(action):
            res = self.m(action, roles=['*'])
            # print(self.m.event(res[0]))
            #print(action, res)
            # print(self.m.state())
            self.assertIsNone(res[2])

        x_fail('OFF')
        x_fail('EXEC')
        x_pass('ON')
        x_pass('EXEC')
        x_pass('X11')
        x_fail('X01')
        x_pass('O01')


if __name__ == '__main__':
    unittest.main()
