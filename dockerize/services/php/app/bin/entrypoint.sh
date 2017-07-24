#!/usr/bin/env bash

set -u

if [ "$DOCKER_DEBUG_SCRIPTS" = 1 ]; then
    set -x
fi

if [ "$DOCKER_DEBUG" = 1 ]; then
    echo
    echo '****************************'
    echo '* Start'
    echo '****************************'
    date
fi

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
        bash "$DIR_APP_BIN/get_composer.sh"
    fi
    mv composer.phar composer
    chmod +x composer

    cd "$CUR_DIR"
}

_do_first_start() {

    _add_web_user
    _install_composer

}

_setup_soft() {

    if [ "$DOCKER_DEBUG" = 1 ]; then
        echo
        echo '****************************'
        echo '* Setup soft'
        echo '****************************'
    fi

    chown web-user:web-user -R "$DIR_WEB_ROOT"
}

_add_dev_plugins() {

    if [ "$DOCKER_DEBUG" = 1 ]; then
        echo
        echo '**************************'
        echo '* Setup dev plugins'
        echo '**************************'
    fi

    chown -R web-user:web-user "$DIR_ADD2WEB_DST"

    local src
    local mess
    local plugins=$(find "$DIR_ADD2WEB_SRC" -mindepth 1 -maxdepth 1 )
    for src in ${plugins[@]} ; do
        local plugin_name=$(basename "$src")
        local dst="$DIR_ADD2WEB_DST/$plugin_name"
        if [ -L "$dst" -o -d "$dst" ]; then
            mess='* ! Already exists'
        else
            mess='* Install dev plugin'
            make_relative_link "$src" "$dst"
        fi
        chown -R web-user:web-user "$dst"
        echo "$mess: $(ls -la "$DIR_ADD2WEB_DST" | grep "$plugin_name")"
    done
}

############## MAIN ###################

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
exec "${DIR_APP_BIN}/docker_run.sh"
