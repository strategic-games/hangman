#!/usr/bin/env bash

# Generate swift files for proto schema
protoc --swift_out=. Sources/HangmanCLI/proto/*.proto
