#!/usr/bin/env sh

set -x
set -e

REQUIRED_COMMANDS='which docker rm'

for CMD in $REQUIRED_COMMANDS; do
    if ! which $CMD 1>/dev/null 2>&1; then 
        echo "FATAL: unable to find '$CMD' command"
        exit 2
    fi
done

rm -f 'python.tar.xz'

if docker build -f Dockerfile.BUILD $* -t coreos-python-salt-alpine-build .; then
    docker run --rm coreos-python-salt-alpine-build cat /opt/python.tar.xz > 'python.tar.xz'
fi

if [ -f 'python.tar.xz' ]; then
    docker build --no-cache -t coreos-python-salt-alpine .
fi

# vim:ts=4:sw=4:et:
