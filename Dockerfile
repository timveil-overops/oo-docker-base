FROM alpine:3.8

LABEL maintainer="tjveil@gmail.com"

# based off great work by https://hub.docker.com/r/frolvlad/alpine-glibc

ENV LANG=C.UTF-8 \
    JAVA_VERSION=8 \
    JAVA_UPDATE=181 \
    JAVA_BUILD=13 \
    JAVA_PATH=96a7b8442fe848ef90c96a2fad6ed6d1 \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && ALPINE_GLIBC_PACKAGE_VERSION="2.28-r0" \
    && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && wget \
        "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" \
    && wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && rm "/etc/apk/keys/sgerrand.rsa.pub" \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && apk del glibc-i18n \
    && rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"


# based off great work by https://hub.docker.com/r/frolvlad/alpine-oraclejdk8 - cleaned
# Here we install Oracle JDK.

RUN cd "/tmp" \
    && wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" \
    && tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" \
    && mkdir -p "/usr/lib/jvm" \
    && mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" \
    && ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" \
    && ln -s "$JAVA_HOME/bin/"* "/usr/bin/" \
    && rm -rf "$JAVA_HOME/"*src.zip \
    && rm -rf "$JAVA_HOME/lib/missioncontrol" \
        "$JAVA_HOME/lib/visualvm" \
        "$JAVA_HOME/lib/"*javafx* \
        "$JAVA_HOME/jre/lib/plugin.jar" \
        "$JAVA_HOME/jre/lib/ext/jfxrt.jar" \
        "$JAVA_HOME/jre/bin/javaws" \
        "$JAVA_HOME/jre/lib/javaws.jar" \
        "$JAVA_HOME/jre/lib/desktop" \
        "$JAVA_HOME/jre/plugin" \
        "$JAVA_HOME/jre/lib/"deploy* \
        "$JAVA_HOME/jre/lib/"*javafx* \
        "$JAVA_HOME/jre/lib/"*jfx* \
        "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" \
        "$JAVA_HOME/jre/lib/amd64/"libprism_*.so \
        "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" \
        "$JAVA_HOME/jre/lib/amd64/libglass.so" \
        "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" \
        "$JAVA_HOME/jre/lib/amd64/"libjavafx*.so \
        "$JAVA_HOME/jre/lib/amd64/"libjfx*.so \
    && wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" \
    && unzip -jo -d "${JAVA_HOME}/jre/lib/security" "jce_policy-${JAVA_VERSION}.zip" \
    && rm "${JAVA_HOME}/jre/lib/security/README.txt" \
    && rm "/tmp/"*

RUN apk del build-dependencies \
    && rm "/root/.wget-hsts"

# setup OverOps linux requirements
# * curl - used by OO one liner
# * bash - used by OO one liner
# * netcat-openbsd - used by entrypoint.sh
# * libstdc - required by agent
# * procps - used by OO one liner to detect port availability
# * git - used to show source code

RUN apk add curl bash netcat-openbsd libstdc++ procps git \
    && /usr/glibc-compat/sbin/ldconfig \
    && mkdir /opt

# entrypoint for docker files, adds wait method useful for docker-compose

ADD base-entrypoint.sh /base-entrypoint.sh
RUN chmod a+x /base-entrypoint.sh

ENTRYPOINT ["/base-entrypoint.sh"]