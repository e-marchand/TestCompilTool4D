#!/bin/bash

# compile.sh - Compile a 4D project and display results
# Usage: ./compile.sh /path/to/Project/MyProject.4DProject

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-4DProject-file>"
    echo "Example: $0 /Users/emarchand/TestCompilTool4D/ErrorProject/Project/ErrorProject.4DProject"
    exit 1
fi

PROJECT_PATH="$1"

if [ ! -f "$PROJECT_PATH" ]; then
    echo "ERROR: Project file not found: $PROJECT_PATH"
    exit 1
fi

# Find tool4d
TOOL4D_BASE="$HOME/Library/Application Support/Code/User/globalStorage/4d.4d-analyzer/tool4d"
if [ ! -d "$TOOL4D_BASE" ]; then
    TOOL4D_BASE="$HOME/Library/Application Support/Antigravity/User/globalStorage/4d.4d-analyzer/tool4d"
fi

TOOL4D=$(find "$TOOL4D_BASE" -name "tool4d.app" -type d 2>/dev/null | sort -V | tail -1)
if [ -z "$TOOL4D" ]; then
    echo "ERROR: tool4d not found"
    exit 1
fi
TOOL4D="$TOOL4D/Contents/MacOS/tool4d"

echo "==================================="
echo "4D Project Compiler"
echo "==================================="
echo "Project: $PROJECT_PATH"
echo "Tool4D: $TOOL4D"
echo "==================================="
echo ""

# Run compilation
OUTPUT=$("$TOOL4D" --project="$PROJECT_PATH" --startup-method=_compile --dataless 2>&1)

# Extract JSON from ALERT output (format: ALERT: {...})[
# The JSON ends with })[
JSON_RESULT=$(echo "$OUTPUT" | sed -n 's/.*ALERT: \({.*}\)).*/\1/p')

if [ -z "$JSON_RESULT" ]; then
    echo "Raw output:"
    echo "$OUTPUT"
    exit 1
fi

echo "Compilation Result:"
echo "==================="
echo ""

# Check if jq is available for pretty printing
if command -v jq &> /dev/null; then
    SUCCESS=$(echo "$JSON_RESULT" | jq -r '.success')

    if [ "$SUCCESS" = "true" ]; then
        echo "✅ SUCCESS: Project compiled without errors!"
    else
        ERROR_COUNT=$(echo "$JSON_RESULT" | jq '.errors | length')
        echo "❌ FAILED: Found $ERROR_COUNT error(s)/warning(s)"
        echo ""

        echo "$JSON_RESULT" | jq -r '.errors[] | "--- \(.isError | if . then "ERROR" else "WARNING" end) ---
Message: \(.message)
Type: \(.code.type)
\(if .code.className then "Class: \(.code.className)" else "" end)
\(if .code.methodName then "Method: \(.code.methodName)" else "" end)
\(if .code.functionName and .code.functionName != "" then "Function: \(.code.functionName)" else "" end)
Path: \(.code.path)
Line in function: \(.line)
Line in file: \(.lineInFile)
"'
    fi

    echo ""
    echo "==================================="
    echo "Full JSON Result:"
    echo "==================================="
    echo "$JSON_RESULT" | jq .
else
    echo "$JSON_RESULT"
fi
