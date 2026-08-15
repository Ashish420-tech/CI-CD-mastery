{{/*
Expand the name of the chart.
*/}}
{{- define "project-38-app.name" -}}
project-38
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "project-38-app.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "project-38-app.labels" -}}
app.kubernetes.io/name: {{ include "project-38-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "project-38-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project-38-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
