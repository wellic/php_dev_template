#!/usr/bin/env bash

set -u

if [ "$DOCKER_DEBUG_SCRIPT" = 1 ]; then
    set -x
fi


if [ "$DOCKER_DEBUG" = 1 ]; then
    echo
    echo '****************************'
    echo '* Start'
    echo '****************************'
    date
fi

DIR_PHP=${DIR_PHP:-/usr/local/etc/php}

DIR_APP=/app

DIR_ARC=${DIR_ARC}
DIR_SRC=${DIR_SRC}
DIR_WWW_ROOT=${DIR_WWW_ROOT}

DIR_BIN="$DIR_APP/bin"
DIR_CFG="$DIR_APP/config_files"
PLG_DIRNAME=${PLG_DIRNAME:-html}
DIR_PLG="$DIR_SRC/$PLG_DIRNAME"
DIR_WWW_PLUGINS=${DIR_WWW_PLUGINS:=$DIR_WWW_ROOT}

_is_first_start() {
    id -g ${DOCKER_GROUP_ID} >/dev/null 2>&1 && return 1 || return 0
}

_add_web_user() {
#   groupadd --gid ${DOCKER_GROUP_ID} web-user \
#       && useradd  --gid ${DOCKER_GROUP_ID} --uid ${DOCKER_USER_ID} --create-home --shell /bin/bash web-user \
#       && usermod --append --groups www-data web-user \
#       && usermod --append --groups sudo     web-user \
#       && mkdir -p /etc/sudoers.d \
#       && echo "web-user ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/web-user \
#       && chmod 400 /etc/sudoers.d/web-user

    groupadd --gid ${DOCKER_GROUP_ID} web-user \
        && useradd  --gid ${DOCKER_GROUP_ID} --uid ${DOCKER_USER_ID} --create-home --shell /bin/bash web-user \
        && usermod --append --groups www-data web-user
}

_install_composer() {
    local CUR_DIR=$(readlink -e "$PWD")

    cd /sbin
    if [ ! -e "composer" ]; then
        bash "$DIR_BIN/get_composer.sh"
    fi
    mv composer.phar composer
    chmod +x composer

    cd "$CUR_DIR"
}

_do_first_start() {

    cp "$DIR_CFG/php.ini" "$DIR_PHP"/

    _add_web_user
    _install_composer

    cd "$CUR_DIR"
}

_setup_soft() {

    if [ "$DOCKER_DEBUG" = 1 ]; then
        echo
        echo '****************************'
        echo '* Setup soft'
        echo '****************************'
    fi

    cp "$DIR_CFG/docker_run.sh" /tmp/
}

_add_dev_plugins() {

    if [ "$DOCKER_DEBUG" = 1 ]; then
        echo
        echo '**************************'
        echo '* Setup dev plugins'
        echo '**************************'
    fi

    chown -R web-user:web-user "$DIR_WWW_PLUGINS"

    local plugin
    local plugins=$(find "$DIR_PLG" -mindepth 1 -maxdepth 1 -exec basename "{}" \;)
#    local CUR_DIR=$(pwd)
#    cd "$DIR_WWW_PLUGINS"
    for plugin in ${plugins[@]} ; do
        if [ -L "$plugin" -o -d "$plugin" ]; then
            chown -R web-user:web-user "$plugin"
            echo "* ! Already exists: $(ls -la "$DIR_WWW_PLUGINS" | grep "$plugin")"
            continue;
        fi
        make_relative_link "$DIR_PLG/$plugin" "$DIR_WWW_PLUGINS/$plugin"
        chown -R web-user:web-user "$plugin"
        echo "* Install dev plugin: $(ls -la "$DIR_WWW_PLUGINS" | grep "$plugin")"
    done
#    cd "$CUR_DIR"
}

############## MAIN ###################


export PATH="$PATH:$DIR_BIN"

if [ "$DOCKER_DEBUG" = 1 ]; then
    echo
    echo '****************************'
    echo '* Vars before start'
    echo '****************************'
    env | sort
fi

_is_first_start && _do_first_start

_setup_soft
_add_dev_plugins


if [ "$DOCKER_DEBUG" = 1 ]; then
    echo
    echo '****************************'
    echo '* docker_run.sh'
    echo '****************************'
fi
exec /tmp/docker_run.sh
