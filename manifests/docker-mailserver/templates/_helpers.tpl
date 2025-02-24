{{/*
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.mariadb.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.mda" -}}
  {{- printf "%s-mda" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.virus" -}}
  {{- printf "%s-virus" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.mta" -}}
  {{- printf "%s-mta" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.filter" -}}
  {{- printf "%s-filter" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-mailserver.web" -}}
  {{- printf "%s-web" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "docker-mailserver.dkim" -}}
  {{- printf "%s-dkim" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "docker-mailserver.vmail" -}}
  {{- printf "%s-vmail" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "docker-mailserver.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.mda.image .Values.virus.image .Values.filter.image .Values.redis.image) "context" $) -}}
{{- end -}}

{{- define "docker-mailserver.mda.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.mda.image "global" .Values.global ) -}}
{{- end -}}

{{- define "docker-mailserver.virus.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.virus.image "global" .Values.global ) -}}
{{- end -}}

{{- define "docker-mailserver.filter.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.filter.image "global" .Values.global ) -}}
{{- end -}}

{{- define "docker-mailserver.mta.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.mta.image "global" .Values.global ) -}}
{{- end -}}

{{- define "docker-mailserver.web.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.web.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the Redis&reg; secret name
*/}}
{{- define "docker-mailserver.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "docker-mailserver.redis.fullname" .) }}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-redis" (include "docker-mailserver.redis.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; secret key
*/}}
{{- define "docker-mailserver.redis.secretPasswordKey" -}}
{{- if and .Values.redis.enabled .Values.redis.auth.existingSecret }}
    {{- .Values.redis.auth.existingSecretPasswordKey | printf "%s" }}
{{- else if and (not .Values.redis.enabled) .Values.externalRedis.existingSecret }}
    {{- .Values.externalRedis.existingSecretPasswordKey | printf "%s" }}
{{- else -}}
    {{- printf "redis-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis&reg; uses password authentication or not
*/}}
{{- define "docker-mailserver.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; hostname
*/}}
{{- define "docker-mailserver.redisHost" -}}
{{- if .Values.redis.enabled }}
    {{- printf "%s-master" (include "docker-mailserver.redis.fullname" .) -}}
{{- else -}}
    {{- required "If the redis dependency is disabled you need to add an external redis host" .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&reg; port
*/}}
{{- define "docker-mailserver.redisPort" -}}
{{- if .Values.redis.enabled }}
    {{- coalesce .Values.redis.service.port .Values.redis.service.ports.redis -}}
{{- else -}}
    {{- .Values.externalRedis.port -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Hostname
*/}}
{{- define "docker-mailserver.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
    {{- if eq .Values.mariadb.architecture "replication" }}
        {{- printf "%s-primary" (include "docker-mailserver.mariadb.fullname" .) | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "docker-mailserver.mariadb.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Port
*/}}
{{- define "docker-mailserver.databasePort" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "3306" -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Database Name
*/}}
{{- define "docker-mailserver.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB User
*/}}
{{- define "docker-mailserver.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Secret Name
*/}}
{{- define "docker-mailserver.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.mariadb.auth.existingSecret -}}
        {{- printf "%s" .Values.mariadb.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "docker-mailserver.mariadb.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -}}
{{- else -}}
    {{- printf "%s-externaldb" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}
