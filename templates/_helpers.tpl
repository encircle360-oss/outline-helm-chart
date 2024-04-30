{{/*
Expand the name of the chart.
*/}}
{{- define "outline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "outline.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "outline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "outline.labels" -}}
helm.sh/chart: {{ include "outline.chart" . }}
{{ include "outline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "outline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "outline.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "outline.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Shared env for all services
*/}}
{{- define "outline.env" -}}
{{- with .Values.secretKey }}
- name: SECRET_KEY
  value: {{ . | quote }}
{{- end }}
{{- with .Values.utilsSecret }}
- name: UTILS_SECRET
  value: {{ . | quote }}
{{- end }}
- name: PORT
  value: "3000"
- name: COLLABORATION_URL
  value: ""
{{- if .Values.ingress.tls.enabled }}
- name: URL
  value: "https://{{ .Values.ingress.host }}"
{{- else }}
- name: URL
  value: "http://{{ .Values.ingress.host }}"
- name: FORCE_HTTPS
  value: "false"
{{- end }}
{{- if .Values.postgresql.enabled }}
- name: DATABASE_URL
  value: "postgres://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.postgresqlDatabase }}"
- name: DATABASE_URL_TEST
  value: "postgres://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.postgresqlDatabase }}-test"
- name: PGSSLMODE
  value: "disable"
{{- end }}
{{- if .Values.redis.enabled }}
- name: REDIS_URL
  value: "redis://{{ .Release.Name }}-redis-master:6379"
{{- end }}
{{- if .Values.minio.enabled }}
- name: AWS_ACCESS_KEY_ID
  value: {{ .Values.minio.accessKey.password | quote }}
- name: AWS_SECRET_ACCESS_KEY
  value: {{ .Values.minio.secretKey.password | quote }}
- name: AWS_REGION
  value: "us-east-1"
{{- if .Values.minio.ingress.tls }}
- name: AWS_S3_UPLOAD_BUCKET_URL
  value: "https://{{ .Values.minio.ingress.hostname }}"
{{- else }}
- name: AWS_S3_UPLOAD_BUCKET_URL
  value: "http://{{ .Values.minio.ingress.hostname }}"
{{- end }}
- name: AWS_S3_UPLOAD_BUCKET_NAME
  value: {{ .Values.minio.defaultBuckets | quote }}
- name: AWS_S3_UPLOAD_MAX_SIZE
  value: "26214400"
- name: AWS_S3_FORCE_PATH_STYLE
  value: "true"
- name: AWS_S3_ACL
  value: "private"
{{- end }}
{{- if or .Values.env .Values.envSecrets }}
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- range $key, $secret := .Values.envSecrets }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $secret }}
      key: {{ $key | quote }}
{{- end }}
{{- end }}
{{- end }}
