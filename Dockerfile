FROM golang AS builder

ARG PAM_KEYCLOAK_VERSION=r1.1.5

RUN apt-get update && apt-get install -y git \
 && git clone --branch=${PAM_KEYCLOAK_VERSION} https://github.com/zhaow-de/pam-keycloak-oidc.git /go/src/github.com/zhaow-de/pam-keycloak-oidc

WORKDIR /go/src/github.com/zhaow-de/pam-keycloak-oidc

RUN go build -ldflags "-w -s" -o /go/bin/pam-keycloak-oidc github.com/zhaow-de/pam-keycloak-oidc

FROM ubuntu

COPY oidc-auth.pam /etc/pam.d/oidc-auth

RUN apt-get update && apt-get install -y openssh-server sudo \
 && mkdir -p /run/sshd \
 && sed -i '/^@include common-auth/i @include oidc-auth' /etc/pam.d/sudo \
 && sed -i '/^@include common-auth/i @include oidc-auth' /etc/pam.d/sshd \
 && rm -rf /tmp/* /var/lib/apt/lists/*

COPY --from=builder /go/bin/pam-keycloak-oidc /opt/pam-keycloak-oidc/pam-keycloak-oidc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/pam-keycloak-oidc/pam-keycloak-oidc /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
