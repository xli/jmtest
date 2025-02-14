// (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

#include <glog/logging.h>

#include <folly/SocketAddress.h>
#include <folly/coro/BlockingWait.h>
#include <folly/coro/Collect.h>
#include <folly/coro/Task.h>
#include <folly/executors/GlobalExecutor.h>
#include <folly/init/Init.h>
#include <folly/io/async/AsyncSocket.h>

#include <thrift/lib/cpp2/async/PooledRequestChannel.h>
#include <thrift/lib/cpp2/async/RocketClientChannel.h>
#include "gen-cpp2/AddServiceAsyncClient.h"

int main(int argc, char* argv[]) {
  folly::init(&argc, &argv);

  auto channel = apache::thrift::PooledRequestChannel::newSyncChannel(
      folly::getIOExecutor(), [&](folly::EventBase& evb) {
        const folly::SocketAddress address("127.0.0.1", 80);

        apache::thrift::RequestSetupMetadata meta;
        auto socket =
            folly::AsyncSocket::UniquePtr(new folly::AsyncSocket(&evb));
        socket->connect(nullptr, address);
        return apache::thrift::RocketClientChannel::newChannelWithMetadata(
            std::move(socket), std::move(meta));
      });
  auto client = jmswen::AddServiceAsyncClient(std::move(channel));

  std::vector<folly::coro::Task<void>> tasks;
  // Establish up to 50 concurrent streams. Each client task will establish and
  // drive 10,000 streams to completion.
  for (size_t i = 0; i < 50; ++i) {
    tasks.push_back(folly::coro::co_invoke([&]() -> folly::coro::Task<void> {
      for (size_t reqId = 0; reqId < 10'000; ++reqId) {
        jmswen::AddRequest request;
        request.x() = 1;
        request.y() = 17;

        auto stream =
            (co_await client.co_add_stream(request)).toAsyncGenerator();
        while (auto next = co_await stream.next()) {
          LOG(INFO) << "Got: " << *next->sum();
        }
      }
    }));
  }
  folly::coro::blockingWait(folly::coro::collectAllRange(std::move(tasks)));

  return 0;
}
