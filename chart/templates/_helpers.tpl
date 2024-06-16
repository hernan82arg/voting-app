{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "votingApp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.  We truncate at 63 chars because
some Kubernetes name fields are limited to this (by the DNS naming spec).  If
release name contains chart name it will be used as a full name. The
"RELEASE-NAME" condition is there to support conftest. Conftest implies
--generate-name. This results in matching the final else case which can
generate extremely long names depending on the chart name. The long names may
exceed 63 characters thus breaking validations and failing to pass policies.
The condition short circuits this behavior by using the Helm generated name to
prevent these type of errors in test contexts.
*/}}
{{- define "votingApp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if eq .Release.Name "RELEASE-NAME" }}
{{- .Release.Name -}}
{{- else if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "votingApp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "votingApp.labels" -}}
version: {{ .Values.deployment.sha | quote }}
helm.sh/chart: {{ include "votingApp.chart" . }}
app.kubernetes.io/name: {{ include "votingApp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.deployment.sha | quote }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "votingApp.serviceAccountName" -}}
{{- if .Values.votingApp.serviceAccount.create -}}
{{ default (include "votingApp.fullname" .) .Values.votingApp.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.votingApp.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Config version hash. Used to create unique ConfigMaps.
*/}}
{{- define "votingApp.configVersion" -}}
{{ .Values.votingApp.config | toYaml | sha256sum | trunc 5 }}
{{- end -}}

{{/*
Secret version hash. Used to create unique Secret.
*/}}
{{- define "votingApp.secretVersion" -}}
{{ .Values.votingApp.secrets | toYaml | sha256sum | trunc 5 }}
{{- end -}}

{{/*
File version hash. Used to create unique Secret.
*/}}
{{- define "votingApp.filesVersion" -}}
{{ .Values.votingApp.files | toYaml | sha256sum | trunc 5 }}
{{- end -}}

{{/*
Create image name and tag used by the deployment.
*/}}
{{- define "app.image" -}}
{{- $name := .Values.votingApp.image.repository -}}
{{- if hasKey .Values.votingApp.image "version" -}}
{{- printf "%s:%s" $name .Values.votingApp.image.version -}}
{{- else if hasKey .Values.votingApp.image "tag" -}}
{{- printf "%s:%s" $name .Values.votingApp.image.tag -}}
{{- else -}}
{{- printf "%s:%s" $name .Chart.AppVersion -}}
{{- end -}}
{{- end -}}
