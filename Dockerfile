FROM centos:7

LABEL maintainer="tjveil@gmail.com"

ARG TIMEZONE=America/New_York

RUN curl -O http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && rpm -ivh epel-release-latest-7.noarch.rpm

# setup OverOps linux requirements
# * java-1.8.0-openjdk-devel.x86_64 - Java JDK
# * net-tools - used by OO one liner
# * nc - used by OO one liner
# * less - convenience for viewing configuration
# * sysvinit-tools - used by OO one liner to detect port availability
# * multitail - good utility for tailig multiple files ie agent and log

RUN yum install -y java-1.8.0-openjdk-devel.x86_64 net-tools nc less sysvinit-tools multitail \
    && yum -y update \
    && yum clean all \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk

ENV PATH $JAVA_HOME/bin:$PATH

ADD base-entrypoint.sh /base-entrypoint.sh
RUN chmod a+x /base-entrypoint.sh

ENTRYPOINT ["/base-entrypoint.sh"]