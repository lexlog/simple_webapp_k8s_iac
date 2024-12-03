{{- define "app.deploymentName" -}}
{{- .Values.app.name }}-deployment
{{- end }}

{{- define "app.secretName" -}}
{{- .Values.app.name }}-secret
{{- end }}

{{- define "app.configMapName" -}}
{{- .Values.app.name }}-config
{{- end }}

{{- define "app.serviceName" -}}
{{- .Values.app.name }}-service
{{- end }}

{{- define "app.hpaName" -}}
{{- .Values.app.name }}-hpa
{{- end }}

{{- define "app.envVar" -}}
{{- range .Values.envs }}
  - name: {{ .name }}
    valueFrom:
    {{- if eq .type "secret" }}
      secretKeyRef:
        name: {{ include "app.secretName" $ }}
        key: {{ .key }}
    {{- else if eq .type "configMap" }}
      configMapKeyRef:
        name: {{ include "app.configMapName" $ }}
        key: {{ .key }}
    {{- end }}
{{- end }}
{{- end }}
