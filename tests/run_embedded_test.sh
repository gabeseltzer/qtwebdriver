#!/bin/bash
#
# Run the embedded QtWebDriver test application and execute tests
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== QtWebDriver Embedded Test Runner ===${NC}"

# Kill any existing test_qt_app processes
echo -e "${BLUE}Cleaning up any existing test_qt_app processes...${NC}"
pkill -9 test_qt_app 2>/dev/null || true
sleep 1

# Check if the test_qt_app binary exists
if [ ! -f "./test_qt_app" ]; then
    echo -e "${RED}Error: test_qt_app not found. Building...${NC}"
    ./build_test_app.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}Build failed!${NC}"
        exit 1
    fi
fi

# Start the test application in the background
echo -e "${BLUE}Starting test_qt_app on port 9517...${NC}"
./test_qt_app --port=9517 --verbose > /tmp/test_qt_app.log 2>&1 &
APP_PID=$!

# Wait for the server to start
echo -e "${BLUE}Waiting for QtWebDriver server to start...${NC}"
MAX_WAIT=10
COUNTER=0
while [ $COUNTER -lt $MAX_WAIT ]; do
    if curl -s http://localhost:9517/status > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Server is ready!${NC}"
        break
    fi
    sleep 1
    COUNTER=$((COUNTER + 1))
    echo -n "."
done
echo ""

if [ $COUNTER -eq $MAX_WAIT ]; then
    echo -e "${RED}Error: Server failed to start within ${MAX_WAIT} seconds${NC}"
    echo -e "${RED}Log output:${NC}"
    cat /tmp/test_qt_app.log
    kill $APP_PID 2>/dev/null || true
    exit 1
fi

# Verify server is responding
echo -e "${BLUE}Verifying server status...${NC}"
STATUS=$(curl -s http://localhost:9517/status)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server is responding${NC}"
    echo "$STATUS" | python3 -m json.tool 2>/dev/null || echo "$STATUS"
else
    echo -e "${RED}Error: Server not responding${NC}"
    kill $APP_PID 2>/dev/null || true
    exit 1
fi

# Activate virtual environment and run tests
echo -e "${BLUE}Running test_button_interactions.py...${NC}"
source ../.venv/bin/activate

# Run the test script
python3 test_button_interactions.py
TEST_RESULT=$?

# Cleanup
echo -e "${BLUE}Cleaning up...${NC}"
kill $APP_PID 2>/dev/null || true
pkill -9 test_qt_app 2>/dev/null || true

# Report results
echo ""
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}=== All tests passed! ===${NC}"
else
    echo -e "${RED}=== Tests failed with exit code $TEST_RESULT ===${NC}"
    echo -e "${BLUE}Server log (last 50 lines):${NC}"
    tail -50 /tmp/test_qt_app.log
fi

exit $TEST_RESULT
