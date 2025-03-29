#!/bin/bash

docker build -t rel-alg .
docker ps | grep 4568 | awk '{print $1}' | xargs -r docker stop
docker run -p 4568:4567 -v "$(pwd)/data:/rel-alg/data" rel-alg
