#!/bin/sh

if [ "$REDIS_PASSWORD"x != ""x ]
then
    echo "Use Password"
    touch redis.conf
    echo "requirepass ${REDIS_PASSWORD}">redis.conf
    redis-server redis.conf
elif [ "$ALLOW_EMPTY_PASSWORD"x = "yes"x ]
then
    echo "Allow Empty Passowrd"
    redis-server
else
    echo "No ENV Set For REDIS_PASSWORD or ALLOW_EMPTY_PASSWORD"
    redis-server
fi