# Outline wiki helm chart
This helm chart provides you with a ready to use [outline wiki](https://github.com/outline/outline) stack ready to deploy in your kubernetes cluster.
It provides:
 - Outline
 - PostgreSQL
 - Redis
 - Minio S3 Storage

You can enable or disable every outline dependency like postgresql, minio or redis and also provide your own with your own configuration.
You are also able to re-configure most of all settings from the provided dependencies and defaults.

## Quick start

At first check all variables that need to be set, especially the credentials and secrets within the [values.yaml](values.yaml).
Do only use self-generated secrets and credentials for production environments.
```
helm upgrade --install -n outline --create-namespace --set postgresql.postgresqlPassword=some-secret-db-pass,postgresql.postgresqlPostgresPassword=some-secret-admin-db-pass,minio.secretKey.password=some-secret-s3-secret,minio.accessKey.password=some-secret-s3-accesskey,env.SLACK_SECRET=slack-oidc-secret,SLACK_KEY=slack-oidc-key outline ./
```

To find out more configuration possibilities also check the [values.yaml](values.yaml).

## Example values.yaml with slack as oidc provider and tls via cert-manager
```
secretKey: "to-generate-see-values-yaml-docs"
utilsSecret: "to-generate-see-values-yaml-docs"
ingress:
  host: outline.somedomain.tld
  tls:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-staging"
env:
  SLACK_KEY: "your-slack-app-key"
  SLACK_SECRET: "your-slack-secret"
  SMTP_HOST: "some-smtp-host"
  SMTP_PORT: "25"
  SMTP_USERNAME: "smtp-user"
  SMTP_PASSWORD: "smtp-passwd"
  SMTP_FROM_EMAIL: "no-reply@outline.somedomain.tld"
  SMTP_REPLY_EMAIL: "hello@somedomain.tld"
  SMTP_SECURE: "false"
postgresql:
  postgresqlPassword: "some-secret-pw"
  postgresqlPostgresPassword: "some-secret-pw-admin"
  persistence:
    storageClass: "some-storage-class"
    size: 6Gi
redis:
  persistence:
    storageClass: "some-storage-class"
    size: 3Gi
minio:
  ingress:
    hostname: "data.outline.somedomain.tld"
    certManager: true
    tls: true
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-staging"
  secretKey:
    password: "some-secret-pw"
  accessKey:
    password: "some-secret-pw"
  persistence:
    storageClass: "some-storage-class"
    size: 30Gi
```

## Contribute
Feel free to contribute and create pull requests. We will review and merge them.

### Credits
This is open source software by [encircle360](https://encircle360.com). Use on your own risk and for personal use. If you need support or consultancy just contact us.

