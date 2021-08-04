#!/bin/sh

ssh-keygen -A

cat >  /opt/pam-keycloak-oidc/pam-keycloak-oidc.tml << EOF
# name of the dedicated OIDC client at Keycloak
client-id="demo-pam"
# the secret of the dedicated client
client-secret="57f0e684-a59d-404d-9906-bfe154e8f6ba"
# special callback address for no callback scenario
redirect-url="urn:ietf:wg:oauth:2.0:oob"
# OAuth2 scope to be requested, which contains the role information of a user
scope="pam_roles"
# name of the role to be matched, only Keycloak users who is assigned with this role could be accepted
vpn-user-role="demo-pam-authentication"
# retrieve from the meta-data at https://keycloak.example.com/auth/realms/demo-pam/.well-known/openid-configuration
endpoint-auth-url="http://pc-marcel:8084/auth/realms/master/protocol/openid-connect/auth"
endpoint-token-url="http://pc-marcel:8084/auth/realms/master/protocol/openid-connect/token"
# 1:1 copy, to 'fmt' substituion is required
username-format="%s"
# to be the same as the particular Keycloak client
access-token-signing-method="RS256"
# a key for XOR masking. treat it as a top secret
xor-key="scmi"
EOF

cat > /etc/pam.d/sshd << EOF
# PAM configuration for the Secure Shell service (with OIDC support)

# Open ID Connect Login
account required                        pam_permit.so
auth    [success=2 default=ignore]      pam_exec.so     expose_authtok  log=/var/log/pam-keycloak-oidc.log      /opt/pam-keycloak-oidc/pam-keycloak-oidc
@include common-auth
#auth    requisite                       pam_deny.so
#auth    required                        pam_permit.so

# Disallow non-root logins when /etc/nologin exists.
account    required     pam_nologin.so

# Uncomment and edit /etc/security/access.conf if you need to set complex
# access limits that are hard to express in sshd_config.
# account  required     pam_access.so

# Standard Un*x authorization.
@include common-account

# SELinux needs to be the first session rule.  This ensures that any
# lingering context has been cleared.  Without this it is possible that a
# module could execute code in the wrong domain.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so close

# Set the loginuid process attribute.
session    required     pam_loginuid.so

# Create a new session keyring.
session    optional     pam_keyinit.so force revoke

# Standard Un*x session setup and teardown.
@include common-session

# Print the message of the day upon successful login.
# This includes a dynamically generated part from /run/motd.dynamic
# and a static (admin-editable) part from /etc/motd.
session    optional     pam_motd.so  motd=/run/motd.dynamic
session    optional     pam_motd.so noupdate

# Print the status of the user's mailbox upon successful login.
session    optional     pam_mail.so standard noenv # [1]

# Set up user limits from /etc/security/limits.conf.
session    required     pam_limits.so

# Read environment variables from /etc/environment and
# /etc/security/pam_env.conf.
session    required     pam_env.so # [1]
# In Debian 4.0 (etch), locale-related environment variables were moved to
# /etc/default/locale, so read that as well.
session    required     pam_env.so user_readenv=1 envfile=/etc/default/locale

# SELinux needs to intervene at login time to ensure that the process starts
# in the proper default security context.  Only sessions which are intended
# to run in the user's context should be run after this.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so open

# Standard Un*x password updating.
@include common-password
EOF

echo "You must create all unix user accounts that you can login as the users. (adduser <name> --disabled-password)"
echo "To start ssh: /usr/sbin/sshd -De"
/bin/bash
#/usr/sbin/sshd -De
