# SOFAStack + Datadog APM Demo

A SOFAStack microservices demo instrumented with Datadog APM, running entirely in Docker containers.

Based on [sofastack/sofa-kubernetes-demo](https://github.com/sofastack/sofa-kubernetes-demo).

## Architecture

```
┌─────────────┐       SOFARPC (Bolt)       ┌──────────────┐
│  rpcclient   │ ──────────────────────────▶ │  rpcserver    │
│  (HTTP :8080)│                             │  (Bolt :12200)│
└──────┬───────┘                             └──────┬────────┘
       │  dd-java-agent                             │  dd-java-agent
       │                                            │
       ▼                                            ▼
┌──────────────────────────────────────────────────────────┐
│                    datadog-agent (:8126)                  │
│              APM traces, metrics, profiling               │
└──────────────────────────────────────────────────────────┘
       │
       ▼
  Datadog Cloud

  ┌───────────┐         ┌──────────┐
  │ zookeeper  │         │  zipkin   │
  │  (:2181)   │         │  (:9411)  │
  └───────────┘         └──────────┘
  Service Registry       SOFATracer UI
```

**Services:**
- **rpcserver** — SOFABoot app publishing `SampleService` over SOFARPC Bolt protocol
- **rpcclient** — SOFABoot app consuming `SampleService` and exposing HTTP `GET /hello`
- **zookeeper** — Service registry for SOFARPC
- **datadog-agent** — Collects APM traces, metrics, and profiles
- **zipkin** — Optional UI for SOFATracer's native OpenTracing spans

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- A [Datadog API key](https://app.datadoghq.com/organization-settings/api-keys)

## Quick Start

1. **Set your Datadog API key:**

   ```bash
   export DD_API_KEY=<your-datadog-api-key>
   ```

2. **Start everything:**

   ```bash
   docker-compose up --build -d
   ```

   First build takes ~5 minutes (Maven downloads dependencies).

3. **Send test traffic:**

   ```bash
   ./test.sh
   ```

   Or manually:

   ```bash
   curl http://localhost:8080/hello
   # Expected: {"word":"Hello"}
   ```

4. **View traces in Datadog:**

   Open [APM Traces (env:dev)](https://app.datadoghq.com/apm/traces?query=env:dev)

5. **View SOFATracer spans in Zipkin:**

   Open [http://localhost:9411](http://localhost:9411)

## Tear Down

```bash
docker-compose down -v
```

## What Datadog Captures

| Signal | Source | Notes |
|--------|--------|-------|
| HTTP traces | Spring Boot auto-instrumentation | `GET /hello` on rpcclient |
| Netty spans | dd-java-agent auto-instrumentation | Underlying SOFABolt transport |
| JVM metrics | dd-java-agent runtime metrics | Heap, GC, threads |
| Continuous profiling | dd-java-agent profiler | CPU, wall-clock, allocations |
| Container metrics | Datadog Agent | Via Docker socket |

> **Note:** SOFARPC's custom Bolt protocol is not natively instrumented by Datadog. The Netty transport layer is visible, and SOFATracer provides OpenTracing-compatible spans visible in Zipkin.

## Configuration

All Datadog config is set via environment variables in `docker-compose.yml`:

- `DD_SERVICE` / `DD_ENV` / `DD_VERSION` — Unified service tagging
- `DD_AGENT_HOST=datadog-agent` — Points tracer to the Agent container
- `DD_TRACE_SAMPLE_RATE=1` — 100% sampling for demo purposes
- `DD_PROFILING_ENABLED=true` — Enables continuous profiling

## License

The SOFAStack source code is under [Apache License 2.0](https://github.com/sofastack/sofa-kubernetes-demo/blob/master/LICENSE).
