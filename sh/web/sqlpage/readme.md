# Deploying a SQLPage project
These guided scripts help you deploy a SQLPage project to an Ubuntu 22.04 server. They set up NGINX as a reverse proxy to your desired SQLPage port, set up a systemd service to keep your SQLPage server running, and install a Let's Encrypt SSL certificate to secure your SQLPage application.

Before you begin, you'll want to have your domain ready and pointed to your server's IP address. This script also assumes your project is hosted on GitHub and that you've set up your server's SSH key in GitHub.

```bash
# Run from the repo root
sh/web/sqlpage/deploy.sh
```