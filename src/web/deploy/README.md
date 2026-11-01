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

## Rider remote development

The full Git checkout is `/srv/heroeswatch/source`, owned by the restricted `heroesdev` account. Rider connects through SSH port 22022 and opens `/srv/heroeswatch/source/src/web/HeroesWatch.sln`. Git origin is the existing HeroesWatch GitHub repository; the website starter is on `web/initial-site`. Normal Commit, Push and Pull actions synchronize source. IDE preferences synchronization is separate.

`heroeswatch-ide.service` runs the matching Rider 2025.3.3 backend and starts at boot. The local Rider/Gateway launcher opens its thin client. Keep Gateway running while connected. The backend has a 3 GiB RAM limit and up to 3 GiB swap; a 4 GiB swap file is available on the VPS. The Java heap is configured separately at 1 GiB in the development account. These settings were added after the initial IDE startup exceeded its earlier memory cap.

The website service is independent of the IDE. Development previews use port 5081; production uses port 5080. No extra public IDE port is opened.

```sh
systemctl status heroeswatch-ide
journalctl -u heroeswatch-ide --since today
```
