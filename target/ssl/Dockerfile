FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

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
