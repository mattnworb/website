---
title: "Grpc Java Deadline Cancellation Questions"
date: 2020-04-27T20:46:09-04:00
draft: true
---

I have a few questions about deadlines and cancellation in grpc-java:

1. How is a request with a deadline "cancelled"? (is this the right term?)

2. When a client makes a request to a server and the client realizes the
   deadline is exceeded, does processing on the server stop?

3. When the client has a request whose deadline is exceeded, will interceptors
   attached to the call see a response that the server sends?


----

I'd been meaning to learn how deadlines and cancelled calls work a little better, and this issue seemed like a good opportunity, so I made a small toy service to test with: https://github.com/mattnworb/sleep-service.

It has a single gRPC service where the caller can ask the server to sleep for a certain amount of time before it sends a response

https://github.com/mattnworb/sleep-service/blob/fd6c9eb6595238d262a31bed4da8c845ec09f101/protos/src/main/proto/mattnworb/sleep/v1/service.proto#L8-L17

One thing I learned is that when the client deadline is exceeded, the client informs the server be resetting the stream:

```
# server logs
15:36:36.575 [grpc-default-executor-2] INFO com.mattnworb.sleep.v1.server.LoggingServerInterceptor - received message for method mattnworb.sleep.v1.SleepService/Sleep
15:36:37.004 [grpc-default-executor-3] INFO com.mattnworb.sleep.v1.server.LoggingServerInterceptor - call to mattnworb.sleep.v1.SleepService/Sleep cancelled
15:36:37.678 [sleep-service-scheduler-0] INFO com.mattnworb.sleep.v1.server.SleepServiceImpl - sending response: timeSleptMillis: 1100
```

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

you can see this in wireshark, the [RST_STREAM](https://http2.github.io/http2-spec/#RST_STREAM)

![Wireshark screenshot](/images/2020-04-28-grpc-wireshark.png)

but also notice in the logs that the server still thinks it is sending back