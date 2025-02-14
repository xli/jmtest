// (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

namespace cpp2 jmswen
namespace py3 jmswen

struct AddRequest {
  1: i64 x;
  2: i64 y;
}

struct AddResponse {
  1: i64 sum;
}

service AddService {
  stream<AddResponse> add_stream(1: AddRequest request);
}
