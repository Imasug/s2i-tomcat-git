# s2i-tomcat-git
FROM openshift/base-centos7

MAINTAINER Suguru Imanaga <suguru_imanaga@cysista.co.jp>

EXPOSE 8080

ENV TOMCAT_VERSION=8.5.54 \
    MAVEN_VERSION=3.5.4

LABEL io.k8s.description="Platform for building and running JEE applications on Tomcat" \
      io.k8s.display-name="Tomcat Builder" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,tomcat"

# Install Git, Maven, Tomcat
RUN INSTALL_PKGS="java-1.8.0-openjdk java-1.8.0-openjdk-devel git" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    (curl -v http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /tomcat && \
    (curl -v http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar -zx --strip-components=1 -C /tomcat) && \
    rm -rf /tomcat/webapps/* && \
    mkdir -p /opt/s2i/destination

# Add s2i customizations
# ADD ./contrib/settings.xml $HOME/.m2/
# ADD ./contrib/server.xml /tomcat/conf/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# TODO
RUN chmod -R a+rw /tomcat && \
    chmod a+rwx /tomcat/* && \
    chmod +x /tomcat/bin/*.sh && \
    chmod -R a+rw $HOME && \
    chmod -R +x $STI_SCRIPTS_PATH

RUN echo "root:root" | chpasswd

USER 1001

CMD $STI_SCRIPTS_PATH/usage