# WordPress Client Helm Chart

One-click WordPress deployment for SaaS clients with per-client MariaDB and Valkey sidecars.

## Architecture

Each client deployment creates a single pod with 3 containers:
- **WordPress** - PHP 8.3 Apache
- **MariaDB** - Per-client database (localhost only, no network exposure)
- **Valkey** - Redis-compatible object cache (localhost only)

```
┌─────────────────────────────────────────┐
│           Client Namespace              │
│  ┌───────────────────────────────────┐  │
│  │         WordPress Pod             │  │
│  │  ┌───────────┬─────────┬───────┐  │  │
│  │  │ WordPress │ MariaDB │ Valkey│  │  │
│  │  │   :80     │  :3306  │ :6379 │  │  │
│  │  └───────────┴─────────┴───────┘  │  │
│  └───────────────────────────────────┘  │
│  ResourceQuota + NetworkPolicy          │
│  PVCs: wp-content (RWX) + mysql (RWO)   │
└─────────────────────────────────────────┘
```

## Features

- WordPress 6.7 with PHP 8.3
- MariaDB 11.4 sidecar (per-client isolation, easy backup/restore)
- Valkey 8.0 sidecar for object caching
- Plan-based resource tiers (basic/pro/enterprise)
- ResourceQuota + LimitRange per namespace
- NetworkPolicy for namespace isolation
- Traefik ingress with automatic TLS
- External-DNS automatic DNS record creation
- Secret persistence across helm upgrades

## Prerequisites

- Kubernetes cluster with Traefik ingress
- External-DNS configured
- NFS storage class (`nfs-rwx`) or similar
- `no_root_squash` on NFS export (for permission fixes)

## Quick Start

```bash
# Deploy a basic plan client
helm install acme-corp ./wordpress-client-chart \
  --namespace acme-corp \
  --create-namespace \
  --set clientName=acme-corp \
  --set clientDomain=acme-corp.clients.yourdomain.com \
  --set plan=basic

# Deploy a pro plan client
helm install bigclient ./wordpress-client-chart \
  --namespace bigclient \
  --create-namespace \
  --set clientName=bigclient \
  --set clientDomain=bigclient.clients.yourdomain.com \
  --set plan=pro
```

## Plans

| Plan       | CPU Limit | Memory Limit | WP Storage | DB Storage |
| ---------- | --------- | ------------ | ---------- | ---------- |
| basic      | 1.5 cores | 1.5 Gi       | 5 Gi       | 2 Gi       |
| pro        | 3 cores   | 3 Gi         | 20 Gi      | 5 Gi       |
| enterprise | 6 cores   | 6 Gi         | 50 Gi      | 10 Gi      |

## Values

| Parameter                  | Description                        | Default               |
| -------------------------- | ---------------------------------- | --------------------- |
| `clientName`               | Client identifier (required)       | `""`                  |
| `clientDomain`             | Full domain for the site (required)| `""`                  |
| `plan`                     | Resource tier                      | `basic`               |
| `wordpress.image.tag`      | WordPress version                  | `6.7-php8.3-apache`   |
| `mariadb.image.tag`        | MariaDB version                    | `11.4`                |
| `valkey.image.tag`         | Valkey version                     | `8.0`                 |
| `persistence.storageClass` | Storage class for PVCs             | `nfs-rwx`             |

## How It Works

1. Namespace created with ResourceQuota + LimitRange
2. Secret generated (or preserved from previous install)
3. Init container fixes NFS permissions
4. Pod starts with WordPress + MariaDB + Valkey
5. MariaDB auto-initializes database on first start
6. Ingress created → External-DNS creates DNS record
7. Traefik terminates TLS
8. Client visits site and completes WordPress setup

## Backup & Restore

```bash
# Backup a client's database
kubectl exec -n acme-corp deployment/wordpress -c mariadb -- \
  mariadb-dump -u root -p$(kubectl get secret -n acme-corp wordpress-db-credentials \
    -o jsonpath='{.data.root-password}' | base64 -d) wordpress > acme-corp-backup.sql

# Restore a client's database
kubectl exec -i -n acme-corp deployment/wordpress -c mariadb -- \
  mariadb -u root -p$(kubectl get secret -n acme-corp wordpress-db-credentials \
    -o jsonpath='{.data.root-password}' | base64 -d) wordpress < acme-corp-backup.sql
```

## Upgrade Plan

```bash
# Upgrade a client from basic to pro
helm upgrade acme-corp ./wordpress-client-chart \
  --namespace acme-corp \
  --set clientName=acme-corp \
  --set clientDomain=acme-corp.clients.yourdomain.com \
  --set plan=pro
```

Database credentials are preserved across upgrades.

## Enabling Redis Cache

After WordPress is running:

1. Install "Redis Object Cache" plugin
2. Go to Settings → Redis
3. Click "Enable Object Cache"

The plugin auto-detects Valkey on localhost:6379.

## Uninstall

```bash
helm uninstall acme-corp -n acme-corp
kubectl delete ns acme-corp
```
