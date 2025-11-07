# TAO Testing Platform - Production Deployment

Docker-based deployment for TAO Assessment Platform with Sharda University branding.

## Files Included

- `Dockerfile` - Custom TAO image with logo
- `docker-compose-dev.yml` - Docker Compose configuration
- `nginx.conf` - Nginx reverse proxy configuration
- `logo_white.svg` - Sharda University logo
- `.gitignore` - Git ignore rules
- `README.md` - This file

## Quick Start

docker-compose -f docker-compose-dev.yml up -d

text

Wait 3-5 minutes, then access: `http://localhost/tao/install`

## Database Details

- **Host:** database
- **Name:** tao
- **User:** tao
- **Password:** tao
