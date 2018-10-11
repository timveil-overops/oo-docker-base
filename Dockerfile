FROM openjdk:8-jdk-alpine

LABEL maintainer="tjveil@gmail.com"

# setup OverOps linux requirements
# * curl - used by OO one liner
# * bash - used by OO one liner
# * netcat-openbsd - used by entrypoint.sh
# * libstdc - required by agent
# * git - used to show source code

RUN apk add curl bash netcat-openbsd libstdc++ \
    && mkdir /opt

# entrypoint for docker files, adds wait method useful for docker-compose

ADD base-entrypoint.sh /base-entrypoint.sh
RUN chmod a+x /base-entrypoint.sh

ENTRYPOINT ["/base-entrypoint.sh"]