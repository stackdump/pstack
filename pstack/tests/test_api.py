import unittest
import pstack
from pstack.server import TestServer
from pstack.client import TestClient, event_pb2
from pstack.storage.dict import Storage


class TestCase(unittest.TestCase):

    def setUp(self):
        pstack.initialize(Storage)
        self.server = TestServer()
        self.server.start()

    def tearDown(self):
        self.server.join()

    def test_grpc_api(self):
        stub = TestClient()
        response = stub.Status(event_pb2.Ping(nonce="foobar"))
        print("Status: \n  nonce:%s \n  code:%i" %
              (response.nonce, response.code))

        query = event_pb2.MachineQuery()
        response = stub.ListMachines(query)
        print("ListMachines: %s" % response.list)

        query = event_pb2.Query(
            schema="octoe",
            chain="foo",
            id=None,
            uuid=None)
        response = stub.GetMachine(query)
        print("GetMachine: %s" % response.schema)

        query = event_pb2.Query(
            schema="octoe",
            chain="foo",
            id=None,
            uuid=None)

        response = stub.GetPlaceMap(query)
        print("GetPlaceMap: %s" % response.schema)

        cmd = event_pb2.Command(
            id="bar",
            schema="octoe",
            chain="foo",
            action=[event_pb2.Action(action="ON", multiple=1)],
            state=[])
        response = stub.Dispatch(cmd)

        print("Dispatch: %s" % response.state.head)
        res_uuid = response.state.head

        # TODO: query with & without uuid
        query = event_pb2.Query(
            schema="octoe",
            chain="foo",
            id="bar",
            uuid=res_uuid)
        response = stub.GetEvent(query)
        print("GetEvent: %s" % response.list[0].uuid)

        # TODO: query with & without uuid
        query = event_pb2.Query(
            schema="octoe",
            chain="foo",
            id="bar",
            uuid=None)
        response = stub.GetState(query)
        print("GetState: %s" % response.list[0].state)


if __name__ == '__main__':
    unittest.main()
