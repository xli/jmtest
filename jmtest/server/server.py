import asyncio
import logging
from signal import SIGINT, SIGTERM
from typing import AsyncGenerator

from thrift.python.server import ThriftServer

from jmswen.add.thrift_services import AddServiceInterface
from jmswen.add.thrift_types import AddRequest, AddResponse

logger: logging.Logger = logging.getLogger(__name__)

class AddHandler(AddServiceInterface):
    async def add_stream(self, request: AddRequest) -> AsyncGenerator[AddResponse, None]:
        x = request.x
        y = request.y

        for i in range(10):
            print(f"Iteration {i}...")
            if i == 7:
                raise Exception("BOOM!")
            yield AddResponse(sum=i * (x + y))


async def go() -> None:
    print("Starting server...")
    handler = AddHandler()
    server = ThriftServer(handler, port=80)

    server.set_max_requests(400000)
    server.set_queue_timeout(10)

    loop = asyncio.get_event_loop()
    for signal in [SIGINT, SIGTERM]:
        loop.add_signal_handler(signal, server.stop)
    print("Listening...")
    await server.serve()


def main():
    asyncio.run(go())


if __name__ == "__main__":
    main()
