FROM alpine:3.21@sha256:b6a6be0ff92ab6db8acd94f5d1b7a6c2f0f5d10ce3c24af348d333ac6da80685

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key \
    SSL_CSR=/media/tls/mailserver.csr \
    SSL_SUBJ_COUNTRY=DE \
    SSL_SUBJ_STATE="North Rhine-Westphalia" \
    SSL_SUBJ_LOCALITY=Duesseldorf \
    SSL_SUBJ_ORGANIZATION=Mail \
    SSL_SUBJ_ORGANIZATIONAL_UNIT=Mail

RUN apk --no-cache add openssl
COPY create_tls.sh /usr/local/bin

CMD ["/usr/local/bin/create_tls.sh"]
