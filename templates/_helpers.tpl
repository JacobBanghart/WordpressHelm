{{/*
Common labels
*/}}
{{- define "wordpress-client.labels" -}}
app.kubernetes.io/name: wordpress
app.kubernetes.io/instance: {{ .Values.clientName }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
client: {{ .Values.clientName }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wordpress-client.selectorLabels" -}}
app.kubernetes.io/name: wordpress
app.kubernetes.io/instance: {{ .Values.clientName }}
{{- end }}
