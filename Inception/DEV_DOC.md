# Developer Documentation - Inception
This guide is for developers who want to set up, build, modify, or debug the Inception project.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Project Structure](#project-structure)
4. [Building the Project](#building-the-project)
5. [Docker Commands Reference](#docker-commands-reference)
6. [Configuration Files](#configuration-files)
7. [Data Persistence](#data-persistence)
8. [Networking](#networking)
9. [Debugging & Troubleshooting](#debugging--troubleshooting)
10. [Development Workflow](#development-workflow)
11. [Security Considerations](#security-considerations)

---

## Prerequisites

### Required Software

- **Virtual Machine**: Debian 11 (Bullseye) or Ubuntu 20.04+
- **Docker Engine**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Make**: For build automation
- **Git**: For version control

### System Requirements

- **RAM**: Minimum 4GB (6GB recommended)
- **Disk Space**: Minimum 20GB free
- **CPU**: 2+ cores recommended

### Installation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (avoid needing sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

---

## Environment Setup

### Step 1: Clone the Repository
```bash
git clone <repository-url> inception
cd inception
```

### Step 2: Create Environment Configuration
```bash
# Copy example environment file
cp srcs/.env.example srcs/.env

# Edit with your values
nano srcs/.env
```

**Required variables in `.env`:**
```bash
DOMAIN_NAME=yourlogin.42.fr

MYSQL_ROOT_PASSWORD=<strong-password>
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wpuser
MYSQL_PASSWORD=<db-user-password>

WP_ADMIN_USER=<admin-username>  # Must NOT contain 'admin'
WP_ADMIN_PASSWORD=<admin-password>
WP_ADMIN_EMAIL=your@email.com

WP_USER=<regular-username>
WP_USER_PASSWORD=<user-password>
WP_USER_EMAIL=user@email.com
```

### Step 3: Create Secret Files
```bash
# Create secrets directory if it doesn't exist
mkdir -p srcs/secrets

# Create password files
echo "your_root_password" > srcs/secrets/db_root_password.txt
echo "your_db_password" > srcs/secrets/db_password.txt
echo "WP_ADMIN_USER=youradmin
WP_ADMIN_PASSWORD=yourpassword" > srcs/secrets/credentials.txt
```

### Step 4: Configure Domain Resolution

**On your host machine** (not the VM), edit the hosts file:

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```
C:\Windows\System32\drivers\etc\hosts
```

Add this line:
```
127.0.0.1    yourlogin.42.fr
```

---

## Project Structure
```
inception/
├── Makefile                           # Build automation
├── README.md                          # Project overview
├── USER_DOC.md                        # User documentation
├── DEV_DOC.md                         # This file
├── .gitignore                         # Git ignore rules
├── srcs/
│   ├── .env                           # Environment variables (gitignored)
│   ├── .env.example                   # Environment template
│   ├── docker-compose.yml             # Container orchestration
│   ├── requirements/
│   │   ├── mariadb/
│   │   │   ├── Dockerfile             # MariaDB image definition
│   │   │   ├── conf/
│   │   │   │   └── 50-server.cnf      # MariaDB configuration
│   │   │   └── tools/
│   │   │       └── init-db.sh         # Database initialization script
│   │   ├── nginx/
│   │   │   ├── Dockerfile             # NGINX image definition
│   │   │   ├── conf/
│   │   │   │   └── nginx.conf         # NGINX server configuration
│   │   └── wordpress/
│   │       ├── Dockerfile             # WordPress image definition
│   │       ├── conf/
│   │       │   └── www.conf           # PHP-FPM configuration
│   │       └── tools/
│   │           └── setup-wordpress.sh # WordPress setup script
│   └── secrets/
│       ├── credentials.txt            # WordPress credentials (gitignored)
│       ├── db_password.txt            # DB password (gitignored)
│       └── db_root_password.txt       # DB root password (gitignored)
└── data/                              # Created at runtime (gitignored)
    ├── mariadb/                       # Database files
    └── wordpress/                     # WordPress files
```

---

## Building the Project

### Using Makefile (Recommended)
```bash
# Build and start all services
make

# Or explicitly
make up
```

**What this does:**
1. Creates data directories at `/home/$USER/data/`
2. Builds Docker images from Dockerfiles
3. Creates Docker network `srcs_inception`
4. Creates Docker volumes
5. Starts containers in correct order

### Manual Build (Without Makefile)
```bash
# Create data directories
sudo mkdir -p /home/$USER/data/mariadb
sudo mkdir -p /home/$USER/data/wordpress

# Build and start
docker-compose -f srcs/docker-compose.yml up -d --build
```

### Stop Services
```bash
make down
```

**Or:**
```bash
docker-compose -f srcs/docker-compose.yml down
```

### Clean Rebuild (Delete All Data)
```bash
make clean
```

**Warning:** This deletes all databases, uploads, and configuration!

### Rebuild After Changes
```bash
make re
```

**Equivalent to:**
```bash
make clean && make
```

---

## Docker Commands Reference

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs <container-name>
docker logs -f <container-name>  # Follow logs in real-time

# Execute command in running container
docker exec -it <container-name> <command>

# Example: Access MariaDB shell
docker exec -it mariadb mysql -u root -p

# Example: Access WordPress bash
docker exec -it wordpress bash

# Restart a container
docker restart <container-name>

# Stop a container
docker stop <container-name>

# Remove a container
docker rm <container-name>
docker rm -f <container-name>  # Force remove running container
```

### Image Management
```bash
# List images
docker images

# Build an image manually
docker build -t <image-name> <dockerfile-path>

# Remove an image
docker rmi <image-name>

# Remove all unused images
docker image prune -a
```

### Volume Management
```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect <volume-name>

# Remove a volume
docker volume rm <volume-name>

# Remove all unused volumes
docker volume prune
```

### Network Management
```bash
# List networks
docker network ls

# Inspect network
docker network inspect srcs_inception

# Test connectivity between containers
docker exec -it wordpress ping mariadb
```

### System Cleanup
```bash
# Remove all stopped containers, unused networks, dangling images
docker system prune

# Remove everything (including volumes)
docker system prune -a --volumes
```

---

## Configuration Files

### docker-compose.yml

**Location:** `srcs/docker-compose.yml`

**Key sections:**
```yaml
services:
  mariadb:
    build: ./requirements/mariadb     # Path to Dockerfile
    container_name: mariadb           # Container name
    env_file: .env                    # Load environment variables
    volumes:
      - mariadb_data:/var/lib/mysql   # Persistent storage
    networks:
      - inception                     # Custom network
    restart: always                   # Auto-restart policy
```

**Modifying services:**
1. Edit the service configuration
2. Run `make down && make` to apply changes

### Dockerfiles

**Each service has its own Dockerfile:**

#### MariaDB Dockerfile
- Base: `debian:bullseye`
- Installs: `mariadb-server`, `mariadb-client`
- Copies: Configuration and initialization script
- Exposes: Port 3306
- CMD: Runs `init-db.sh`

#### WordPress Dockerfile
- Base: `debian:bullseye`
- Installs: `php-fpm`, `php-mysql`, `wget`, `curl`
- Downloads: WP-CLI for WordPress management
- Copies: PHP-FPM config and setup script
- Exposes: Port 9000
- CMD: Runs `setup-wordpress.sh`

#### NGINX Dockerfile
- Base: `debian:bullseye`
- Installs: `nginx`, `openssl`
- Generates: Self-signed SSL certificate
- Copies: NGINX configuration
- Exposes: Port 443
- CMD: Runs `nginx -g 'daemon off;'`

### Service Configuration Files

**MariaDB:** `srcs/requirements/mariadb/conf/50-server.cnf`
```ini
[mysqld]
bind-address = 0.0.0.0   # Listen on all interfaces
port = 3306              # Default MySQL port
```

**NGINX:** `srcs/requirements/nginx/conf/nginx.conf`
- Listens on port 443 with SSL/TLS
- SSL protocols: TLSv1.2, TLSv1.3 only
- Forwards PHP requests to `wordpress:9000` via FastCGI

**WordPress:** `srcs/requirements/wordpress/conf/www.conf`
- PHP-FPM pool configuration
- Listens on port 9000
- Process management settings

---

## Data Persistence

### Volume Mounting

Data is stored on the host at:
```
/home/$USER/data/
├── mariadb/      # Database files
└── wordpress/    # WordPress uploads, themes, plugins
```

**Mounted in containers as:**
- MariaDB: `/var/lib/mysql`
- WordPress: `/var/www/html`

### Backup Strategy
```bash
# Backup all data
sudo tar -czf inception-backup-$(date +%Y%m%d).tar.gz /home/$USER/data/

# Restore from backup
sudo tar -xzf inception-backup-YYYYMMDD.tar.gz -C /
```

### Data Lifecycle

1. **First run:** Volumes are empty, initialization scripts run
2. **Subsequent runs:** Existing data is mounted, initialization skipped
3. **Clean rebuild:** `make clean` deletes volumes, fresh install on next `make`

---

## Networking

### Container Communication

All containers are on the `inception` bridge network.

**DNS Resolution:**
- Containers can reach each other by name
- WordPress connects to `mariadb:3306`
- NGINX connects to `wordpress:9000`

**Port Mapping:**
- Only NGINX exposes port to host: `443:443`
- WordPress and MariaDB are internal only

**Test connectivity:**
```bash
# From WordPress to MariaDB
docker exec -it wordpress ping mariadb

# Check what ports are listening
docker exec -it nginx netstat -tlnp
```

---

## Debugging & Troubleshooting

### Common Issues

#### 1. Container Won't Start

**Check logs:**
```bash
docker logs <container-name>
```

**Common causes:**
- Configuration syntax error
- Missing environment variables
- Port already in use
- Volume permission issues

#### 2. Database Connection Error

**Verify MariaDB is running:**
```bash
docker ps | grep mariadb
docker logs mariadb
```

**Test connection:**
```bash
docker exec -it mariadb mysql -u root -p
SHOW DATABASES;
```

**Check WordPress can reach MariaDB:**
```bash
docker exec -it wordpress ping mariadb
```

#### 3. Website Not Loading

**Check NGINX logs:**
```bash
docker logs nginx
```

**Verify port mapping:**
```bash
docker ps | grep nginx
# Should show: 0.0.0.0:443->443/tcp
```

**Test from host:**
```bash
curl -k https://localhost
```

#### 4. SSL Certificate Errors

**Regenerate certificate:**
```bash
# Rebuild NGINX container
docker-compose -f srcs/docker-compose.yml build nginx
docker-compose -f srcs/docker-compose.yml up -d nginx
```

### Debugging Commands
```bash
# Enter container shell
docker exec -it <container> bash

# View real-time logs
docker logs -f <container>

# Check container processes
docker exec -it <container> ps aux

# Check container resource usage
docker stats

# Inspect container details
docker inspect <container>

# Check network configuration
docker network inspect srcs_inception
```

---

## Development Workflow

### Making Changes

#### 1. Modify Configuration
```bash
# Edit config file
nano srcs/requirements/nginx/conf/nginx.conf

# Restart service
docker-compose -f srcs/docker-compose.yml restart nginx
```

#### 2. Modify Dockerfile
```bash
# Edit Dockerfile
nano srcs/requirements/wordpress/Dockerfile

# Rebuild image and recreate container
docker-compose -f srcs/docker-compose.yml build wordpress
docker-compose -f srcs/docker-compose.yml up -d wordpress
```

#### 3. Modify Scripts
```bash
# Edit script
nano srcs/requirements/mariadb/tools/init-db.sh

# Rebuild and restart
make down
make clean  # Only if you need fresh database
make
```

### Testing Changes
```bash
# Start services
make

# Test functionality
curl -k https://yourlogin.42.fr

# Check logs for errors
docker logs mariadb
docker logs wordpress
docker logs nginx

# Verify data persistence
# 1. Create test content
# 2. Delete container: docker rm -f wordpress
# 3. Recreate: docker-compose up -d wordpress
# 4. Verify content still exists
```

---

## Security Considerations

### Best Practices Implemented

1. **No hardcoded credentials:**
   - All passwords in `.env` file
   - `.env` is gitignored

2. **TLS encryption:**
   - Only TLSv1.2 and TLSv1.3 enabled
   - Self-signed certificate (production should use Let's Encrypt)

3. **Network isolation:**
   - Only NGINX exposes port to host
   - WordPress and MariaDB are internal only

4. **Least privilege:**
   - Containers run services as non-root users where possible
   - MariaDB user has limited privileges (not root for WordPress)

5. **Secure admin username:**
   - WordPress admin username doesn't contain "admin"

### Security Checklist

- [ ] `.env` file is gitignored
- [ ] Strong passwords set for all services
- [ ] No passwords in Dockerfiles
- [ ] Only port 443 exposed to host
- [ ] TLS configured correctly
- [ ] WordPress admin user doesn't use "admin"
- [ ] Regular updates applied to base images

---

## Additional Resources

### Docker Documentation
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Service Documentation
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WordPress Codex](https://codex.wordpress.org/)
- [WP-CLI Documentation](https://wp-cli.org/)

### Troubleshooting
- [Docker Troubleshooting](https://docs.docker.com/config/daemon/troubleshoot/)
- [NGINX Troubleshooting](https://www.nginx.com/resources/wiki/start/topics/tutorials/debugging/)

---

## Contributing

### Before Submitting Changes

1. Test thoroughly with `make clean && make`
2. Verify all three containers start successfully
3. Test website access via HTTPS
4. Check that data persists after container recreation
5. Review logs for errors
6. Update documentation if needed

### Code Style

- Use consistent indentation (2 spaces for YAML, 4 for shell scripts)
- Comment complex configurations
- Follow Docker best practices
- Keep Dockerfiles minimal and efficient

---

## Support

For issues or questions:
1. Check container logs: `docker logs <container>`
2. Review this documentation
3. Consult service-specific documentation
4. Check project README.md