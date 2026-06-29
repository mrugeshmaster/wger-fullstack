#!/bin/bash
set -euo pipefail

BASE_URL="http://localhost:8000"
MAX_WAIT=300

# Wait for the backend to be ready
echo "Waiting for wger backend..." >&2
for i in $(seq 1 $MAX_WAIT); do
    if curl -sf "${BASE_URL}/api/v2/version/" > /dev/null 2>&1; then
        echo "Backend ready after ${i}s" >&2
        break
    fi
    if [ "$i" -eq "$MAX_WAIT" ]; then
        echo "ERROR: Backend did not start within ${MAX_WAIT}s" >&2
        exit 1
    fi
    sleep 1
done

# Login via allauth headless endpoint to obtain a JWT access token
RESPONSE=$(curl -sf -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"adminadmin"}' \
    "${BASE_URL}/allauth/app/v1/auth/login") || {
    echo "ERROR: Login request failed" >&2
    exit 1
}

ACCESS_TOKEN=$(echo "$RESPONSE" | python3 -c "
import sys, json
body = json.load(sys.stdin)
token = body.get('meta', {}).get('access_token', '')
if not token:
    import sys
    print('ERROR: no access_token in response: ' + json.dumps(body), file=sys.stderr)
    sys.exit(1)
print(token)
")

echo "$ACCESS_TOKEN"
