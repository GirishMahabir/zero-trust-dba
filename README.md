# Zero Trust Database Administration (ZTDA) Project

## Table of Contents
- [Project Overview](#project-overview)
- [Installation and Configuration Guide](#installation-and-configuration-guide)
- [Security and Operations Manual](#security-and-operations-manual)
- [Developer Guide](#developer-guide)
- [Appendix and Change Log](#appendix-and-change-log)

## Project Overview
The ZTDA project is one which implements robust Zero Trust security principles in a database administration context using a containerized approach to simulate VM behavior. This documentation provides an introduction to the project's goals, architecture, and scope.

### Goals
The primary goal of ZTDA is to enhance database security by applying Zero Trust principles that ensure no implicit trust is granted to any entity, with everything from the network to the application level requiring verification before access is granted.

This demo doesn't account for the firewall(IPTables & NFTables) and the network security part, but it can be easily integrated with the existing setup.

### Architecture
This project uses Docker containers to host various services including MariaDB, ProxySQL, and Elasticsearch, linked together through Docker Compose to ensure seamless interaction under strict security protocols.

### Scope
This project encompasses setup, configuration, and management of a database environment secured according to Zero Trust principles, focusing on secure access, data encryption, and detailed auditing.

## Installation and Configuration Guide
Follow these steps to set up your ZTDA environment.

### Prerequisites
- Docker installed on your machine.
- Docker Compose installed for orchestrating multiple containers.
- Git for repository cloning.

### Installation Steps
1. Clone the repository:
   ```
   git clone https://github.com/GirishMahabir/zero-trust-dba
   ```
2. Navigate to the project directory:
   ```
   cd ZTDA
   ```
3. Deploy the services using Docker Compose:
   ```
   make start
   ```

### Configuration
Configure each service following the detailed instructions in the `CONF/` directory, adjusting settings in `docker-compose.yml` for Docker configurations, and in individual `.cnf` and `.yml` files for service-specific settings.

The main point for configuration of the docker-compose remains the .env file, where you can set some sensitive information like the root password for the database, the user and password for the database, and the user and password for the ProxySQL.

## Security and Operations Manual
This section outlines the security implementations and operational procedures for daily management.

### Security Practices
Security within the ZTDA project is comprehensive, covering:
- **Data Encryption**: Scripts in `SCRIPTS/` for configuring data encryption at rest and in transit.
- **GPG Encryption**: Encrypting sensitive data using GPG keys (Backup files, etc.).
- **SSH Hardening**: Securing SSH access to the containers.
- **Database Security**: Configuring MariaDB for secure access and data protection following best practices.
- **ProxySQL Rules**: Ensuring that all database queries are inspected and filtered according to strict rules.

### Operational Commands
Common commands for managing the ZTDA services:
```
make start # Start the services
make stop # Stop the services
make clean # Remove all containers and volumes, including persistent data.
```

### Code Structure
The project is structured into several key directories:
- `DOCKER/` for all Docker-related files.
- `SCRIPTS/` for initialization and maintenance scripts.
- `CONF/` for configuration files.