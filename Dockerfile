FROM ubuntu

RUN apt-get update && apt-get install -y openssh-server wget \
 && mkdir -p /opt/pam-keycloak-oidc \
 && wget -O /opt/pam-keycloak-oidc/pam-keycloak-oidc https://github.com/zhaow-de/pam-keycloak-oidc/releases/download/r1.1.5/pam-keycloak-oidc.linux-amd64 \
 && apt-get purge -y wget \
 && chmod +x /opt/pam-keycloak-oidc/pam-keycloak-oidc \
 && mkdir -p /run/sshd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
