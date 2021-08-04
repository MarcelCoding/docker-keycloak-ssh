FROM ubuntu

COPY oidc-auth.pam /etc/pam.d/oidc-auth

RUN apt-get update && apt-get install -y openssh-server wget sudo \
 && mkdir -p /opt/pam-keycloak-oidc \
 && wget -O /opt/pam-keycloak-oidc/pam-keycloak-oidc https://github.com/zhaow-de/pam-keycloak-oidc/releases/download/r1.1.5/pam-keycloak-oidc.linux-amd64 \
 && apt-get purge -y wget \
 && chmod +x /opt/pam-keycloak-oidc/pam-keycloak-oidc \
 && mkdir -p /run/sshd \
 && sed -i '/^@include common-auth/i @include oidc-auth' /etc/pam.d/sudo \
 && sed -i '/^@include common-auth/i @include oidc-auth' /etc/pam.d/sshd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
