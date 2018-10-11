FROM centos:7

LABEL maintainer="tjveil@gmail.com"

ARG TIMEZONE=America/New_York


# setup OverOps linux requirements
# * java-1.8.0-openjdk-devel.x86_64 - Java JDK
# * net-tools - used by OO one liner
# * nc - used by OO one liner
# * less - convenience for viewing configuration
# * sysvinit-tools - used by OO one liner to detect port availability

RUN yum install -y java-1.8.0-openjdk-devel.x86_64 net-tools nc less sysvinit-tools git \
    && yum -y update \
    && yum clean all \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk

ENV PATH $JAVA_HOME/bin:$PATH

ADD base-entrypoint.sh /base-entrypoint.sh
RUN chmod a+x /base-entrypoint.sh

ENTRYPOINT ["/base-entrypoint.sh"]