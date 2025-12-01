# WordPress Client Helm Chart

One-click WordPress deployment for SaaS clients with Valkey (Redis) sidecar cache.

## Features

- WordPress with PHP 8.3
- Valkey sidecar for object caching (Redis-compatible)
- Automatic MySQL database + user creation
- TLS encryption to MySQL
- Traefik ingress with automatic TLS
- External-DNS automatic DNS record creation

## Prerequisites

- Kubernetes cluster with Traefik ingress
- External-DNS configured
- Shared MySQL instance with root credentials secret
- Storage class for PVCs

## Quick Start

```bash
# Deploy for a new client
helm install acme-corp . \
  --namespace acme-corp \
  --create-namespace \
  --set clientName=acme-corp \
  --set clientDomain=acme-corp.clients.yourdomain.com
```

## Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `clientName` | Client identifier (used for namespace, DB) | `""` |
| `clientDomain` | Full domain for the site | `""` |
| `wordpress.image.tag` | WordPress version | `6.7-php8.3-apache` |
| `valkey.image.tag` | Valkey version | `8.0` |
| `mysql.host` | MySQL service hostname | `mysql.mysql-system.svc.cluster.local` |
| `mysql.tls.enabled` | Enable TLS to MySQL | `true` |
| `persistence.size` | Storage size for wp-content | `10Gi` |
| `persistence.storageClass` | Storage class | `nfs-rwx` |

## How It Works

1. **Pre-install hook** creates MySQL database and user
2. Credentials stored in Kubernetes secret
3. WordPress deployment starts with Valkey sidecar
4. Ingress created → External-DNS creates DNS record
5. Traefik terminates TLS
6. Client visits site and completes WordPress setup

## Enabling Redis Cache

After WordPress is running:

1. Install "Redis Object Cache" plugin
2. Go to Settings → Redis
3. Click "Enable Object Cache"

The plugin auto-detects Valkey on localhost:6379.
