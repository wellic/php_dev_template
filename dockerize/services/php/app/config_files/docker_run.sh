#!/bin/sh

if [ "$DOCKER_DEBUG_SCRIPT" = 1 ]; then
    set -x
fi

chown -R web-user:web-user "$DIR_WWW_ROOT"

if [ "$DOCKER_DEBUG" = 1 ]; then
    echo
    echo '****************************'
    echo '* Web root folder'
    echo '****************************'
    ls -la "$DIR_WWW_ROOT"
    echo
    echo '****************************'
    echo '* Vars before run apache'
    echo '****************************'
    env | sort
    echo '****************************'
fi


echo "\n* Almost ! Starting Apache now\n";
exec apache2-foreground
