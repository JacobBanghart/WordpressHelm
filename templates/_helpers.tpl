{{/*
Generate database name from client name (replace dashes with underscores)
*/}}
{{- define "wordpress-client.dbName" -}}
wp_{{ .Values.clientName | replace "-" "_" }}
{{- end }}

{{/*
Generate database user from client name
*/}}
{{- define "wordpress-client.dbUser" -}}
wp_{{ .Values.clientName | replace "-" "_" }}_user
{{- end }}

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
