This Project has been created as part of the 42 curriculum by rvikrama
# User Documentation - Inception

This guide explains how to use and manage the Inception WordPress infrastructure.

## What Services Are Provided

The Inception stack provides a complete WordPress website with:

- **WordPress Website**: Content management system accessible via web browser
- **WordPress Admin Panel**: Dashboard for managing content, users, and settings
- **MariaDB Database**: Backend storage for all website data
- **NGINX Web Server**: Handles all web traffic with HTTPS encryption

---

## Starting and Stopping the Project

### Start the Infrastructure
```bash
cd ~/inception
make
```

**What happens:**
1. Docker builds all container images (first time only)
2. Creates data directories for persistent storage
3. Starts MariaDB, WordPress, and NGINX containers
4. Website becomes accessible at `https://rvikrama.42.fr`

**Expected output:**
```
✔ Container mariadb    Started
✔ Container wordpress  Started
✔ Container nginx      Started
```

### Stop the Infrastructure
```bash
make down
```

**What happens:**
- All containers stop gracefully
- Data remains safe in volumes
- Website becomes inaccessible

### Restart Everything
```bash
make re
```

**Warning**: This removes ALL data (posts, users, uploads). Only use for testing.

---

## Accessing the Website

### View the Website

1. Open your web browser
2. Go to: `https://rvikrama.42.fr`
3. **Security Warning**: Click "Advanced" → "Proceed to rvikrama.42.fr"
   - This is normal (self-signed SSL certificate)
4. WordPress homepage loads

### Access the Admin Panel

1. Go to: `https://rvikrama.42.fr/wp-admin`
2. **Login as Administrator:**
   - Username: `rvadmin`
   - Password: `admin123`
3. WordPress dashboard opens

### Login as Regular User

1. Go to: `https://rvikrama.42.fr/wp-login.php`
2. **Login credentials:**
   - Username: `rvuser`
   - Password: `user123`
3. Access limited to posting and editing own content

---

## Managing Credentials

### Where Credentials Are Stored

**Environment file**: `srcs/.env`
```
MYSQL_ROOT_PASSWORD=rootpass123
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppass123
WP_ADMIN_USER=rvadmin
WP_ADMIN_PASSWORD=admin123
```

**Secret files**: `secrets/` folder
- `db_root_password.txt`
- `db_password.txt`
- `credentials.txt`

### Changing Passwords

**To change passwords:**

1. Stop the services: `make down`
2. Edit `srcs/.env` with new passwords
3. Update corresponding files in `secrets/`
4. Clean and rebuild: `make clean && make`

**Warning**: Changing passwords requires rebuilding with clean data.

---

## Checking Services Are Running

### Method 1: Check Container Status
```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE            STATUS         PORTS                    NAMES
abc123...      srcs-nginx       Up 5 minutes   0.0.0.0:443->443/tcp    nginx
def456...      srcs-wordpress   Up 5 minutes   9000/tcp                wordpress
ghi789...      srcs-mariadb     Up 5 minutes   3306/tcp                mariadb
```

**Status should show "Up"** - if "Restarting" or missing, there's a problem.

### Method 2: Check Service Logs

**NGINX logs:**
```bash
docker logs nginx
```
Healthy: No errors, minimal output

**WordPress logs:**
```bash
docker logs wordpress
```
Look for: "WordPress setup complete"

**MariaDB logs:**
```bash
docker logs mariadb
```
Look for: "mysqld: ready for connections"

### Method 3: Test Website Access

1. Open browser: `https://rvikrama.42.fr`
2. Website loads = All services working
3. Login to admin = WordPress + Database working

---

## Common Tasks

### Create a Blog Post

1. Login to admin: `https://rvikrama.42.fr/wp-admin`
2. Click **Posts** → **Add New**
3. Enter title and content
4. Click **Publish**

### Install a Theme

1. Login to admin
2. **Appearance** → **Themes** → **Add New**
3. Search for a theme (e.g., "Astra")
4. Click **Install** → **Activate**

### Create a New User

1. Login as admin
2. **Users** → **Add New**
3. Fill in details
4. Choose role (Subscriber, Author, Editor)
5. Click **Add New User**

### Backup Your Data

Data is stored at:
- **Database**: `/home/rvikrama/data/mariadb/`
- **WordPress files**: `/home/rvikrama/data/wordpress/`

**To backup:**
```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/rvikrama/data/
```

---

## Troubleshooting

### Website Not Loading

**Check:**
1. Are containers running? `docker ps`
2. Is domain in hosts file? `cat /etc/hosts | grep rvikrama`
3. Check NGINX logs: `docker logs nginx`

**Fix:**
```bash
make down
make
```

### Can't Login to WordPress

**Check credentials in** `srcs/.env`

**Reset admin password:**
```bash
docker exec -it wordpress wp user update rvadmin --user_pass=newpassword --allow-root
```

### Database Connection Error

**Restart MariaDB:**
```bash
docker restart mariadb
sleep 10
docker restart wordpress
```

### Out of Disk Space

**Clean Docker:**
```bash
docker system prune -a
```

---

## Support

For technical issues:
1. Check container logs: `docker logs <container-name>`
2. Verify all services running: `docker ps`
3. Review configuration files in `srcs/`

For WordPress usage:
- [WordPress Support](https://wordpress.org/support/)
- [WordPress Documentation](https://wordpress.org/documentation/)