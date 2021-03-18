---
title: "How do cancellation and deadlines work in grpc-java?"
date: 2020-04-27T20:46:09-04:00
slug: "grpc-java-deadline-cancellation"
---
(I started on this post in April 2020, wrote half of it, and then forgot about it - mid-sentence - for a long time)

I have a few questions about deadlines and cancellation in grpc-java:

1. How is a request with a deadline "cancelled"? (is this the right term?)

2. When a client makes a request to a server and the client realizes the
   deadline is exceeded, does processing on the server stop?

3. When the client has a request whose deadline is exceeded, will interceptors
   attached to the call see a response that the server sends?


TODO:

- a better intro
- explain what deadlines are and define cancellation
  - quote the documentation.
- the main questions I wanted to answer are:
  - what mechanism in the client knows when a deadline has been exceeded and
    does something to throw an exception or interrupt the client blocking on a
    result?
  - is there anything similar on the server-side - like a timer?
  - does the client communicate to the server that it is considering the call
    cancelled and not waiting any more?
- are there any docs in <https://github.com/grpc/grpc> to link to on how this
  should all work according to the specification?

----

I'd been meaning to learn how deadlines and cancelled calls work a little
better, and this issue seemed like a good opportunity, so I made a small toy
service to test with: <https://github.com/mattnworb/sleep-service>.

It has a single gRPC service and RPC method where the caller can ask the server
to sleep for a certain amount of time before responding:

```proto
syntax = "proto3";

package mattnworb.sleep.v1;

message SleepRequest {
    int32 sleepTimeMillis = 1;
}
message SleepResponse {
    int32 timeSleptMillis = 1;
}
service SleepService {
    // Sleep will send back a response after sleeping the requested amount of time in the request message.
    rpc Sleep (SleepRequest) returns (SleepResponse) {}
}
```

TODO: explain the code in the repo a bit. Embed the proto definition. Walk through the interceptor that lets us log when a call is started/cancelled/etc.

This allows us to easily test things related to deadlines and cancellation since
the client is in control of how long it takes the server to send a response (via
the value the client sends in the `SleepRequest`); by having the client set a
deadline shorter than the `SleepRequest` to the server, we can reliably make the
server exceed the client's deadline when we want.

One thing I learned from this is that when the client deadline is exceeded, the
client informs the server by resetting the stream. For example, here are logs
from the client sending a `SleepRequest{millis=1100}` while setting the deadline
to 1000ms:

```
# client logs
15:36:35.980 [main] INFO com.mattnworb.sleep.v1.cli.Cli - sending request: sleepTimeMillis: 1100
15:36:36.010 [main] INFO com.mattnworb.sleep.v1.cli.LoggingClientInterceptor - starting call to mattnworb.sleep.v1.SleepService/Sleep
15:36:36.023 [main] INFO com.mattnworb.sleep.v1.cli.LoggingClientInterceptor - sending message to mattnworb.sleep.v1.SleepService/Sleep
15:36:37.000 [main] INFO com.mattnworb.sleep.v1.cli.LoggingClientInterceptor - closing call to mattnworb.sleep.v1.SleepService/Sleep
15:36:37.001 [main] INFO com.mattnworb.sleep.v1.cli.LoggingClientInterceptor - call cancelled: mattnworb.sleep.v1.SleepService/Sleep
15:36:37.005 [main] WARN com.mattnworb.sleep.v1.cli.Cli - caught StatusRuntimeException
io.grpc.StatusRuntimeException: DEADLINE_EXCEEDED: deadline exceeded after 0.971176745s. [buffered_nanos=536752367, remote_addr=localhost/127.0.0.1:5000]
```

```
# server logs
15:36:36.575 [grpc-default-executor-2] INFO com.mattnworb.sleep.v1.server.LoggingServerInterceptor - received message for method mattnworb.sleep.v1.SleepService/Sleep
15:36:37.004 [grpc-default-executor-3] INFO com.mattnworb.sleep.v1.server.LoggingServerInterceptor - call to mattnworb.sleep.v1.SleepService/Sleep cancelled
15:36:37.678 [sleep-service-scheduler-0] INFO com.mattnworb.sleep.v1.server.SleepServiceImpl - sending response: timeSleptMillis: 1100
```

Using Wireshark to view the TCP packets sent between the client and server, we
can see a [RST_STREAM](https://http2.github.io/http2-spec/#RST_STREAM) packet
sent at "No. 33" by the client to the server (we can tell it is sent by the
client to the server because the destination port is 5000, which the server in
this example was listening on):

<!-- can this be resized? https://gohugo.io/content-management/image-processing/  -->
![Wireshark screenshot](/images/2020-04-28-grpc-wireshark.png)

Notice though that in the logs above, even after the server has received the
`RST_STREAM` to cancel the call, the server continues processing the request and
attempts to send back a response. Why is that?

TODO:

- find code that receives a `RST_STREAM` and translates that into cancelling a ServerCall.
  - how does that get bubbled up to `Context.isCancelled()`?
- link to <https://grpc.io/blog/deadlines/> to show that the server should check if the context is cancelled or not

[sleep-proto]: https://github.com/mattnworb/sleep-service/blob/fd6c9eb6595238d262a31bed4da8c845ec09f101/protos/src/main/proto/mattnworb/sleep/v1/service.proto#L8-L17