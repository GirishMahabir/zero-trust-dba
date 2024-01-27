FROM bitnami/mariadb:11.2

USER root

RUN mkdir -p /var/lib/apt/lists

# Update & Upgrade System
RUN apt-get update && apt-get upgrade -y

# Install System Admin Tools
RUN apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    sudo \
    vim \
    wget \
    iftop \
    iotop \
    sysstat \
    auditd \
    ssh \
    net-tools

# Create User & Group (dba & sysadmin)
RUN groupadd -g 1000 dba && \
    groupadd -g 1001 sysadmin && \
    useradd -u 1000 -g dba -m -s /bin/bash dba && \
    useradd -u 1001 -g sysadmin -m -s /bin/bash sysadmin

# Generate and set random password for root, dba and sysadmin users.
RUN echo "root:$(openssl rand -base64 32)" | chpasswd && \
    echo "dba:$(openssl rand -base64 32)" | chpasswd && \
    echo "sysadmin:$(openssl rand -base64 32)" | chpasswd

# Generate SSH Server Keys
RUN ssh-keygen -A

# Copy SSH Server Config
COPY templates/sshd_config /etc/ssh/sshd_config

# COPY SSH Service Script
COPY templates/ssh-service.sh /ssh-service.sh

# Set SSH Service Script Permissions
RUN chmod +x /ssh-service.sh

# Add SSH Service Script to cron to run every 30 seconds
RUN echo "* * * * * root /ssh-service.sh" >> /etc/crontab

# Copy Sudores File
COPY templates/sudoers.conf /etc/sudoers
