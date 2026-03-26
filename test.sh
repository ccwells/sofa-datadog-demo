#!/usr/bin/env bash
set -euo pipefail

echo "=== SOFAStack + Datadog Demo Test ==="
echo ""

# Wait for rpcclient to be ready
MAX_RETRIES=60
RETRY=0
echo "Waiting for rpcclient to be ready on http://localhost:8080 ..."
until curl -sf http://localhost:8080/health/readiness > /dev/null 2>&1 || [ "$RETRY" -ge "$MAX_RETRIES" ]; do
    RETRY=$((RETRY + 1))
    printf "."
    sleep 3
done
echo ""

if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
    echo "ERROR: rpcclient did not become ready within $((MAX_RETRIES * 3)) seconds."
    echo "Check logs with: docker-compose logs rpcclient"
    exit 1
fi

echo "rpcclient is ready!"
echo ""

# Send test requests
echo "--- Sending requests to /hello ---"
for i in $(seq 1 10); do
    RESPONSE=$(curl -sf http://localhost:8080/hello 2>&1 || echo "FAILED")
    echo "  Request $i: $RESPONSE"
    sleep 1
done

echo ""
echo "=== Done ==="
echo ""
echo "Check your traces in Datadog APM:"
echo "  https://app.datadoghq.com/apm/traces?query=env:dev"
echo ""
echo "SOFATracer spans are also available in Zipkin:"
echo "  http://localhost:9411"
