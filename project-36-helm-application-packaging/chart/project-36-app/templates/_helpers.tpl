{{/*
Expand the name of the chart.
*/}}
{{- define "project-36-app.name" -}}
project-36
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "project-36-app.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "project-36-app.labels" -}}
app.kubernetes.io/name: {{ include "project-36-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "project-36-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project-36-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
