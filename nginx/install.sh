#!/bin/bash
set -xeo pipefail

apt-get install -qqy --no-install-recommends nginx
mkdir /run/nginx && touch /run/nginx/nginx.pid

# Just so it doesn't show up in the error_log
touch /usr/share/nginx/html/favicon.ico
