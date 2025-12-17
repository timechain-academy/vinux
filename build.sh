#!/bin/bash

# Exit on error
set -e

# Set project and scheme
PROJECT="gnostr.xcodeproj"
SCHEME="gnostr"

# Clean build folder
echo "Cleaning build folder..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" clean

# Build the project
echo "Building project..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" build

echo "Build complete."
