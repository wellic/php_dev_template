#!/bin/sh

SERVER_NAME=localhost \
SERVER_PORT=80 \
XDEBUG_CONFIG="PHPSTORM" \
php -dxdebug.remote_host=`ip r | grep default | awk '/default/{print $3}'` \
$@

#Usage:
#c_xdebug.sh script.php 
