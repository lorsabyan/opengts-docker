FROM openjdk:8-alpine as builder

ENV GTS_VERSION 2.6.5
ENV TOMCAT_VERSION 7.0.91
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV CATALINA_HOME /usr/local/tomcat

WORKDIR /usr/local/

RUN apk add curl apache-ant

RUN curl \
    -L http://www.apache.org/dist/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip \
    -o apache-tomcat-$TOMCAT_VERSION.zip && \
    unzip -qq apache-tomcat-$TOMCAT_VERSION.zip && \
    rm -rf apache-tomcat-$TOMCAT_VERSION.zip && \
    mv apache-tomcat-$TOMCAT_VERSION tomcat

RUN curl \
    -L https://sourceforge.net/projects/opengts/files/server-base/$GTS_VERSION/OpenGTS_$GTS_VERSION.zip \
    -o OpenGTS_$GTS_VERSION.zip && \
    unzip -qq OpenGTS_$GTS_VERSION.zip && \
    rm -rf OpenGTS_$GTS_VERSION.zip

RUN curl \
    -L https://github.com/javaee/javamail/releases/download/JAVAMAIL-1_6_1/javax.mail.jar \
    -o $JAVA_HOME/lib/ext/javax.mail.jar

RUN cd OpenGTS_$GTS_VERSION && ant all


FROM tomcat:7.0.91-jre8-alpine

ENV GTS_VERSION 2.6.5

COPY --from=builder /usr/local/OpenGTS_$GTS_VERSION/build/track.war $CATALINA_HOME/webapps/.

CMD ["catalina.sh", "run"]