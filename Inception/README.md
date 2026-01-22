# Inception [RVIKRAMA]

A system administration project that sets up a small infrastructure using Docker containers.

The basics of Inception:
1. What is a website?

When a user or like a personal visits reddit.com or like youtube.com, he or she is not
directly connecting to their computer. The browser sends a request, and the web server
sends back like a HTML/CSS/JavaScript that ,the browser would display.Thatwebserveris a 
program running on their machine waiting for requests.


2. NGINX - The webserver NGINX is that program. It's like a receptionist at the hotel.

	• Listens for incoming requests(on ports 443 for HTTPS)
	• Decides what has ot be done with them.
	• Sends back responces to the brower for the user(Web pages,images,etc).
	• Handles SSL/TLS (the encryption that makes HTTPS secure).


3. WordPress - The Website Aplication WordPress is a Software that helps create and 
   manage websites without writing HTML from scratch. Think of it like:

	• NGINX is the building and front desk.
	• WordPress is the actual business operating inside.
	• It stores articles, image, user accounts in a database.
	 • It generates HTML pages dynamically based on what's stored.

4. PHP- The Programming Language WordPress is writen in php. When someone requests a page:

	• NGINX recives a request.
	• Passes it to PHP-FPM(Fasr CGI Process Manager-a program that runs PHP code).
	• PHP executes WordPress code.
	• Generates HTML.
	• Sends it back through NGINX to the user.

5. MariaDB - The Database This is where WordPress stores everything:

	• Your blog posts.
	• User Acccounts.
	• Comments.
	• Settings.

What is a Docker, Fundimentally?

Dockers lets you package an application with everything it needs(code, libraries, dependencies) into a container that runs the same way everywhere.

You can think of it like: You're shipping furniture.

	• Without Docker: You ship loose parts, hope the customer has the right
	  tools, right manual, right screws. So this might just not work.
	• With Docker: You would ship the complete,assembles unit. Like RTF or
	  RTR. Open the box, and it works.

Core Docker Concepts:

1. Docker Image

	• A Blueprint/template.
	• Read-only.
	• Contains: OS files, your application, dependencies, configuration.
	• Like a recipe for cake.

2. Docker Container

	• A runing instance of an image.
	• Isolated process(es) on the system.
	• Can read/write data while running.
	• Like the actual baked cake.

3. Dockerfile

	• Instructions to build an image.
	• Text file that says"Start with Alpine Linux, install NGINX, copy
	  config files, run NGINX"

## Description

This project involves creating a WordPress website infrastructure using Docker and docker-compose. The setup includes:

- **NGINX**: Web server handling HTTPS connections with TLS v1.2/1.3
- **WordPress + PHP-FPM**: Content management system for the website
- **MariaDB**: Database server storing all WordPress data

All services run in separate Docker containers, connected via a dedicated network, with persistent data storage using Docker volumes.

### Key Features

- Secure HTTPS-only access via port 443
- Self-signed SSL certificates
- Isolated containers with automatic restart on failure
- Persistent data storage (database and website files)
- Two WordPress users (admin and regular user)
- Environment-based configuration (no hardcoded credentials)

## Instructions

### Prerequisites

- Virtual machine running Debian/Ubuntu
- Docker and Docker Compose installed
- Minimum 4GB RAM, 20GB disk space

### Installation & Setup

1. **Clone the repository**
```bash
   cd ~/
   git clone <repo-url> inception
   cd inception
```

2. **Configure environment variables**
   - Edit `srcs/.env` to set your domain, passwords, and usernames
   - Default domain: `rvikrama.42.fr`

3. **Add domain to hosts file (on your host machine)**
   - **Windows**: Edit `C:\Windows\System32\drivers\etc\hosts`
   - **Linux/Mac**: Edit `/etc/hosts`
   - Add: `127.0.0.1    rvikrama.42.fr`

4. **Build and start the infrastructure**
```bash
   make
```

5. **Access the website**
   - Open browser: `https://rvikrama.42.fr`
   - Accept the security warning (self-signed certificate)
   - WordPress site should load

### Available Commands

- `make` or `make up` - Build and start all containers
- `make down` - Stop all containers
- `make clean` - Stop containers and remove all data
- `make re` - Clean rebuild (clean + up)

## Resources

### Docker & Containerization
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Services Configuration
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

### SSL/TLS
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

### AI Usage

AI (Claude) was used for:
- **Learning Docker concepts**: Understanding containers, images, volumes, and networks
- **Troubleshooting**: Debugging connection issues, permission errors, and configuration problems
- **Documentation**: Structuring and formatting project documentation

All generated code was reviewed, tested, and modified to fit project requirements. Understanding was verified through explanation and implementation.

## Project Details

### Architecture
```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ HTTPS (443)
       ↓
┌─────────────┐
│    NGINX    │ ← SSL/TLS termination
└──────┬──────┘
       │ FastCGI (9000)
       ↓
┌─────────────┐
│  WordPress  │ ← PHP-FPM processes requests
└──────┬──────┘
       │ MySQL Protocol (3306)
       ↓
┌─────────────┐
│   MariaDB   │ ← Database storage
└─────────────┘
```

### Design Choices

#### Virtual Machines vs Docker

**Docker was chosen over VMs because:**
- Lightweight: Containers share the host kernel (VMs need full OS)
- Fast startup: Seconds vs minutes
- Resource efficient: Less RAM and CPU overhead
- Portability: Same container runs anywhere
- Version control: Infrastructure as code

**Trade-off**: Less isolation than VMs, but sufficient for this use case.

#### Secrets vs Environment Variables

**Secrets** (files in `secrets/` folder):
- Better security for production
- Encrypted at rest in Docker Swarm
- Mounted as read-only files
- Not logged or shown in docker inspect

**Environment Variables** (in `.env` file):
- Simpler for development
- Easier to manage in docker-compose
- Visible in container environment

**Project uses both**: Passwords in secrets, configuration in .env

#### Docker Network vs Host Network

**Bridge network (chosen)**:
- Container isolation
- Custom DNS resolution (containers find each other by name)
- Port mapping control

**Host network**:
- No isolation
- Containers share host's network stack
- Not suitable for multi-container apps

#### Docker Volumes vs Bind Mounts

**Docker Volumes (used for this project)**:
- Managed by Docker
- Persistent across container recreation
- Better performance on non-Linux hosts
- Easier to backup and migrate

**Configuration**: Volumes stored at `/home/rvikrama/data/` using bind mount driver for easier access and debugging.

### Security Considerations

- No passwords in Dockerfiles (environment variables only)
- TLS v1.2/1.3 only (no older, insecure protocols)
- WordPress admin username doesn't contain "admin"
- Database accessible only within Docker network
- All credentials stored in .env (not committed to git)



## Author
Raja Vikraman -rvikrama.