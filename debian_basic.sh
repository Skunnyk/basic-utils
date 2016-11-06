#!/bin/bash

set -euo pipefail

# Basic configuration for a new debian instance
apt install git lsb-release vim bash-completion curl

# Tune sources.list

cat <<EOF > /etc/apt/sources.list
## Debian.org FR mirror
deb http://ftp.fr.debian.org/debian/ $(lsb_release -cs) main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ $(lsb_release -cs) main contrib non-free

## Debian security updates
deb http://security.debian.org/ $(lsb_release -cs)/updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ $(lsb_release -cs)-updates main contrib non-free

EOF

cat << EOF > /etc/apt/sources.list.d/backports.list

deb http://ftp.fr.debian.org/debian $(lsb_release -cs)-backports main contrib non-free

EOF

cat << EOF > /etc/apt/sources.list.d/dotdeb.list

deb http://packages.dotdeb.org $(lsb_release -cs) all

EOF

curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -

# don't install recommends and suggests
cat << EOF > /etc/apt/apt.conf.d/80local
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

apt update


