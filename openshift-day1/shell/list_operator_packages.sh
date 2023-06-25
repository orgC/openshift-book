#!/usr/bin/env bash

grpcurl -plaintext localhost:50051  api.Registry.ListPackages | jq -r .name | sort



