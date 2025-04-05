FROM node:22-alpine

ARG FIREBASE_VERSION=14.1.0

RUN apk --no-cache add openjdk11-jre bash curl openssl gettext nano nginx sudo && \
    npm cache clean --force && \
    npm i -g firebase-tools@$FIREBASE_VERSION

COPY nginx.conf /etc/nginx/
COPY serve.sh /usr/bin/
RUN chmod +x /usr/bin/serve.sh

WORKDIR /srv/firebase

ENTRYPOINT ["/usr/bin/serve.sh"]
