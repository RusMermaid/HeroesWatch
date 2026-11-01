# VPS deployment

The application runs as `heroeswatch.service` on the existing Ubuntu server. `systemd` starts it at boot and restarts it after a failure. It runs as an unprivileged dynamic user and listens only on `127.0.0.1:5080`.

Published files are stored under `/opt/heroeswatch/releases/`; `/opt/heroeswatch/current` selects the active release. The service unit is `/etc/systemd/system/heroeswatch.service` and the nginx site is `/etc/nginx/sites-available/heroeswatch`.

## Existing shared services

Xray already owns public port 443 for VPN traffic. Do not replace that listener or its client configuration. The intended website HTTPS path is domain SNI -> Xray TLS -> nginx on `127.0.0.1:18081` -> ASP.NET Core on `127.0.0.1:5080`. The existing IP certificate stays first and the existing download fallback stays on port 18080.

Nginx serves HTTP-01 certificate challenges from `/var/lib/heroeswatch-acme` on public port 80. The existing acme.sh IP-certificate renewal uses this webroot. Preserve its short-lived certificate profile, renewal schedule and reload hook.

## Verify and maintain

```sh
systemctl status heroeswatch
journalctl -u heroeswatch --since today
curl --fail http://127.0.0.1:5080/healthz
nginx -t
```

Publish a new portable Release build, copy it into a new release directory, update the `current` symlink, and restart only `heroeswatch.service`. Verify the health endpoint before treating deployment as complete. For application rollback, point `current` at the previous release and restart the service.

The first-install server backup is `/root/heroeswatch-setup/backups/20261101-initial`. It contains a consistent VPN database backup and the original certificate/service configuration. Keep backups and credentials on the server; do not copy them into this repository.
