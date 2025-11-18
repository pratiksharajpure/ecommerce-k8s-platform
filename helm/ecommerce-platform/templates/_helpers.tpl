{{/*
Expand the name of the chart.
*/}}
{{- define "ecommerce-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ecommerce-platform.fullname" -}}
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
{{- define "ecommerce-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ecommerce-platform.labels" -}}
helm.sh/chart: {{ include "ecommerce-platform.chart" . }}
{{ include "ecommerce-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ecommerce-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecommerce-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL labels
*/}}
{{- define "ecommerce-platform.mysql.labels" -}}
{{ include "ecommerce-platform.labels" . }}
app: {{ .Values.mysql.name }}
tier: database
{{- end }}

{{/*
Redis labels
*/}}
{{- define "ecommerce-platform.redis.labels" -}}
{{ include "ecommerce-platform.labels" . }}
app: {{ .Values.redis.name }}
tier: cache
{{- end }}

{{/*
Application labels
*/}}
{{- define "ecommerce-platform.app.labels" -}}
{{ include "ecommerce-platform.labels" . }}
app: {{ .Values.application.name }}
tier: frontend
{{- end }}