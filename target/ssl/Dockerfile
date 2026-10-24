FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV SSL_CERT=/media/tls/tls.crt \
    SSL_KEY=/media/tls/tls.key \
    SSL_CSR=/media/tls/tls.csr \
    SSL_SUBJ_COUNTRY=DE \
    SSL_SUBJ_STATE="North Rhine-Westphalia" \
    SSL_SUBJ_LOCALITY=Duesseldorf \
    SSL_SUBJ_ORGANIZATION=Mail \
    SSL_SUBJ_ORGANIZATIONAL_UNIT=Mail

RUN apk --no-cache add openssl
COPY create_tls.sh /usr/local/bin

CMD ["/usr/local/bin/create_tls.sh"]
