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

# Create the mysql user and group
RUN groupadd -g 1001 mysql && \
    useradd -u 1001 -g mysql -s /bin/bash mysql

# Configure Container for Data at Rest Encryption
COPY ./scripts/Data-At-Rest-Encryption.sh /tmp/Data-At-Rest-Encryption.sh
COPY ./scripts/Data-In-Transit-Encryption.sh /tmp/Data-In-Transit-Encryption.sh

# Set Permissions for Data-At-Rest-Encryption.sh
RUN chmod +x /tmp/Data-At-Rest-Encryption.sh /tmp/Data-In-Transit-Encryption.sh

# Execute Data-At-Rest-Encryption.sh and Data-In-Transit-Encryption.sh.
RUN bash /tmp/Data-At-Rest-Encryption.sh
RUN bash /tmp/Data-In-Transit-Encryption.sh

# Make copy of my.cnf
RUN cp /opt/bitnami/mariadb/conf/my.cnf /opt/bitnami/mariadb/conf/my.cnf.bak

# Add CUSTOM my.cnf
COPY ./templates/my.cnf /opt/bitnami/mariadb/conf/my.cnf

# Create User & Group (dba & sysadmin)
RUN groupadd -g 2000 dba && \
    groupadd -g 2001 sysadmin && \
    useradd -u 2000 -g dba -m -s /bin/bash dba && \
    useradd -u 2001 -g sysadmin -m -s /bin/bash sysadmin

# Generate and set random password for root, dba and sysadmin users.
RUN echo "root:$(openssl rand -base64 32)" | chpasswd && \
    echo "dba:$(openssl rand -base64 32)" | chpasswd && \
    echo "sysadmin:$(openssl rand -base64 32)" | chpasswd

# Generate SSH Server Keys
RUN ssh-keygen -A

# Copy SSH Server Config
COPY ./templates/sshd_config /etc/ssh/sshd_config

# COPY SSH Service Script
COPY ./templates/ssh-service.sh /ssh-service.sh

# Set SSH Service Script Permissions
RUN chmod +x /ssh-service.sh

# Add SSH Service Script to cron to run every 30 seconds
RUN echo "* * * * * root /ssh-service.sh" >> /etc/crontab

# Copy Sudores File
COPY ./templates/sudoers.conf /etc/sudoers

# Create GPG Key
COPY ./templates/gpg-key.sh /tmp/gpg-key.sh
RUN chmod +x /tmp/gpg-key.sh && \
    /tmp/gpg-key.sh && \
    rm /tmp/gpg-key.sh

RUN mkdir -p /opt/utils

COPY ./scripts/utility/* /opt/utils/

RUN chmod +x /opt/utils/*