{{/* Simple template to dump vars. Useful for debuggin purposes */}}
{{/* Usage: {{ template "var_dump" $myvar }} */}}
{{/* NOTE: after printing the variable it interrupts the template rendering immediately */}}
{{ define "var_dump" }}
  {{ . | mustToPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail }}
{{ end }}



{{/* Generate a list of enabled applications. The list is formatted as json array */}}
{{/* To use the list you need to parse the string with the json function of helm */}}
{{/* Usage: {{ range $application := include "applications.json" $ | fromJsonArray }} */}}
{{ define "applications.json" }}
  {{/* This template is included multiple times, so we store the json in $ the first time, and then we just return it the following times */}}
  {{/* If this is not the first time this template is being included, then the $.applications variable has been already set */}}
  {{ if not $.applications }}
    {{ $applications := list }}
    {{ range $.Values.applications }}
      {{/* We don't want to modify the original $.Values.applications */}}
      {{ $app := . | deepCopy }}
      {{ $key := ($app.key | default ($app.name | replace "-" "_")) }}
      {{ if ( and (index $.Values $key).enabled (index $.Values $key).version ) }}
        {{ $app = set $app "key" $key }}
        {{ $app = set $app "version" (index $.Values $key).version }}
        {{ $app = set $app "path" $app.path }}
        {{ $app = set $app "repoURL" $app.repo }}
        {{ if $app.valueFiles }}
          {{ $app = set $app "valueFiles" (tpl ($app.valueFiles | toYaml) $) }}
        {{ end }}
        {{ $applications = append $applications $app }}
      {{ end }}
    {{ end }}
    {{ $ = set $ "applications" $applications }}
  {{ end }}
  {{ $.applications | toJson }}
{{ end }}
