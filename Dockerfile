FROM node:24-alpine

ARG FIREBASE_VERSION=15.30.1

RUN apk --no-cache add openjdk21-jre bash curl openssl gettext nano nginx sudo && \
    npm cache clean --force && \
    npm i -g firebase-tools@$FIREBASE_VERSION

COPY nginx.conf /etc/nginx/
COPY serve.sh /usr/bin/
RUN chmod +x /usr/bin/serve.sh

WORKDIR /srv/firebase

ENTRYPOINT ["/usr/bin/serve.sh"]
