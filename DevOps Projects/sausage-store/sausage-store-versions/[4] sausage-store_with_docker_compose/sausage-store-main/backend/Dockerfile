# build
FROM maven:3.8.2-openjdk-16-slim as builder
# declare variable VERSION for build
ARG VERSION=${VERSION}
ARG PSQL=${PSQL}
WORKDIR /usr/src/app
COPY ./src ./src
COPY *.xml ./
# Copying CA Yandex certificate
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt \
    && mvn package -Dversion.application=${VERSION}

# release
FROM openjdk:16-jdk-alpine
ARG VERSION=${VERSION}
ARG PSQL=${PSQL}
WORKDIR /app
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt .
# pass CA Yandex certificate to Java certificates vault
# add jaruser
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    && rm -rf YandexInternalRootCA.crt \
    && addgroup --system jaruser \
    && adduser -S -s /bin/false -G jaruser jaruser -D -H \
    && apk add --no-cache dumb-init==1.2.5-r0
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-${VERSION}.jar ./sausage-store.jar
EXPOSE 8080
# run as jaruser
USER jaruser
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dmyserver.bindPort=8080", "./sausage-store.jar"]