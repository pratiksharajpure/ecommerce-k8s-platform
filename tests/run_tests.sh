#!/bin/bash

echo "=========================================="
echo "Running Unit Tests"
echo "=========================================="

# Set Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)/application"

# Run unit tests using Windows Python
"/c/Users/Admin/AppData/Local/Programs/Python/Python312/python.exe" -m pytest unit/ -v --tb=short

# Capture exit code
TEST_EXIT_CODE=$?

echo ""
echo "=========================================="
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed!"
fi
echo "=========================================="

exit $TEST_EXIT_CODE
