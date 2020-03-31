#!/bin/sh
set -e


if [ "$REDIS_PASSWORD"x != ""x ]
then
    echo "Use Password"
    echo "requirepass ${REDIS_PASSWORD}" >> /etc/redis.conf
elif [ "$ALLOW_EMPTY_PASSWORD"x = "yes"x ]
then
    echo "Allow Empty Passowrd"
fi


if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	chown -R redis .
        exec sudo -u redis "$@"
fi

exec "$@"
