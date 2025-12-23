# Docker Hub Workflow Configuration

## Overview
This repository includes a GitHub Actions workflow that automatically builds and pushes a Docker image to Docker Hub.

## Required Secrets
To use this workflow, you need to configure the following secrets in your GitHub repository:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

### DOCKER_USERNAME
Your Docker Hub username (e.g., `josemaeldon`)

### DOCKER_PASSWORD
Your Docker Hub password or access token (recommended to use an access token instead of your password)

To create a Docker Hub access token:
1. Log in to [Docker Hub](https://hub.docker.com)
2. Go to **Account Settings** → **Security**
3. Click **New Access Token**
4. Give it a description (e.g., "GitHub Actions")
5. Copy the token and add it as the `DOCKER_PASSWORD` secret

## Workflow Triggers

The workflow will automatically run when:

1. **Push to main/master branch**: Creates and pushes images tagged with the branch name and `latest`
2. **Creating a tag**: 
   - Tag format: `v1.3.17` or `1.3.17`
   - Creates multiple tags: full version, major.minor, and major version
3. **Manual dispatch**: Run manually from GitHub Actions tab with a custom tag

## Docker Image Tags

The workflow creates multiple tags for flexibility:

- `josemaeldon/akaunting-apache:latest` - Latest version from main/master branch
- `josemaeldon/akaunting-apache:1.3.17` - Specific version (from tags)
- `josemaeldon/akaunting-apache:1.3` - Major.minor version
- `josemaeldon/akaunting-apache:1` - Major version

## Using the Docker Image

### Docker Compose Example

```yaml
version: "3.7"

services:
  app:
    image: josemaeldon/akaunting-apache:latest
    working_dir: /var/www/html
    volumes:
      - app_data:/var/www/html
    ports:
      - "80:80"
    environment:
      - DB_HOST=mysql
      - DB_DATABASE=akaunting
      - DB_USERNAME=akaunting
      - DB_PASSWORD=password

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: akaunting
      MYSQL_USER: akaunting
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  app_data:
  mysql_data:
```

### Docker Swarm Stack Example

```yaml
version: "3.7"

services:
  app:
    image: josemaeldon/akaunting-apache:1.3.17
    working_dir: /var/www/html

    volumes:
      - contabilidade_app_data:/var/www/html

    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.docker.network=luzianet"
        - "traefik.http.routers.contabilidade.rule=Host(`caixa.santaluzia.org`)"
        - "traefik.http.routers.contabilidade.entrypoints=websecure"
        - "traefik.http.routers.contabilidade.tls=true"
        - "traefik.http.routers.contabilidade.tls.certresolver=letsencryptresolver"
        - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
        - "traefik.http.routers.contabilidade.middlewares=redirect-to-https"
        - "traefik.http.routers.contabilidade.service=contabilidade-service"
        - "traefik.http.services.contabilidade-service.loadbalancer.server.port=80"

    networks:
      - luzianet

volumes:
  contabilidade_app_data:
    external: true

networks:
  luzianet:
    external: true
```

## Image Features

The Docker image includes:

- **PHP 8.1** with Apache web server
- **PHP Extensions**: pdo_mysql, gd, zip, mbstring, xml, curl, bcmath, opcache
- **Composer**: Pre-installed for dependency management
- **Optimized for Production**: 
  - OPcache enabled for better performance
  - Production-optimized autoloader
  - Proper file permissions
  - Apache mod_rewrite enabled

## First Time Setup

When running the container for the first time:

1. Access the application through your browser
2. Complete the Akaunting installation wizard
3. Configure database connection
4. Set up your company details

## Troubleshooting

### Permission Issues
If you encounter permission issues with storage or cache directories:
```bash
docker exec -it <container_name> chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker exec -it <container_name> chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
```

### Database Connection
Make sure your database is accessible from the container and the environment variables are correctly set.

### Logs
To view application logs:
```bash
docker logs <container_name>
```

## Manual Build

To build the image manually:

```bash
docker build -t josemaeldon/akaunting-apache:1.3.17 .
docker push josemaeldon/akaunting-apache:1.3.17
```

## Support

For issues related to:
- **Akaunting application**: Visit [Akaunting Forum](https://akaunting.com/forum)
- **Docker image**: Open an issue in this repository
- **Workflow**: Check GitHub Actions logs in the "Actions" tab
