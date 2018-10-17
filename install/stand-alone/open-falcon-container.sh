#!/bin/bash

## start mysql and init the mysql table before the first running
docker run -itd \
    --name falcon-mysql \
    -v /home/work/mysql-data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=test123456 \
    -p 3306:3306 \
    mysq;:5.7

## init mysql table before the first running
cd /tmp && \
git clone https://github.com/open-falcon/falcon-plus && \
cd /tmp/falcon-plus/ && \
for x in `ls ./scripts/mysql/db_schema/*.sql`; do
    echo init mysql table $x ...;
    docker exec -i falcon-mysql mysql -uroot -ptest123456 < $x;
done

rm -rf /tmp/falcon-plus

## start redis in container
docker run --name falcon-redis -p 6739:6739 -d redis:4-alpine3.8

## Start falcon-plus modules in one container
## pull images from hub.docker.com/openfalcon
docker pull openfalcon/falcon-plus:v0.2.1

## run falcon-plus container
docker run -itd --name falcon-plus \
    --link=falcon-mysql:db.falcon \
    --link=falcon-redis:redis.falcon \
    -p 8433:8433 \
    -p 8080:8080 \
    -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306) \
    -e REDIS_PORT=redis.falcon:6379 \
    -v /home/work/open-falcon/data:/open-falcon/data \
    -v /home/work/open-falcon/logs:/open-falcon/logs \
    openfalcon/falcon-plus:v0.2.1

## start falcon backend modules, such as graph,api,etc.
docker exec falcon-plus sh ctrl.sh start \
    graph hbs judge transfer nodata aggregator agent gateway api alarm

## or you can just start/stop/restart specific module as:
docker exec falcon-plus ./open-falcon check

## or youcan check logs at /home/work/open/falcon/logs in your host
ls -l /home/work/open-falcon/logs

# 4.start falcon-dashboard in container
docker run -itd --name falcon-dashboard \
    -p 8081:8081 \
    --link=falcon-mysql:db.falcon \
    --link=falcon-plus:api.falcon \
    -e API_ADDR=http://api.falcon:8080/api/v1 \
    -e PORTAL_DB_HOST=db.falcon \
    -e PORTAL_DB_PORT=3306 \
    -e PORTAL_DB_USER=root \
    -e PORTAL_DB_PASS=test123456 \
    -e PORTAL_DB_NAME=falcon_portal \
    -e ALARM_DB_HOST=db.falcon \
    -e ALARM_DB_PORT=3306 \
    -e ALARM_DB_USER=root \
    -e ALARM_DB_PASS=test123456 \
    -e ALARM_DB_NAME=alarms \
    -w /open-falcon/dashboard falcon-dashboard:v0.2.1  \
    './control startfg'

# building open-falcon images from source code
## building falcon-plus
cd /tmp && \
git clone https://github.com/open-falcon/falcon-plus && \
cd /tmp/falcon-plus/ && \
docker build -t falcon-plus:v0.2.1 .

## building falcon-dashboard
cd /tmp && \
git clone https://github.com/open-falcon/dashboard  && \
cd /tmp/dashboard/ && \
docker build -t falcon-dashboard:v0.2.1 .
