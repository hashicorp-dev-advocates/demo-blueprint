[[- define "full_job_name" -]]
[[- if eq .prometheus.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .prometheus.job_name | quote -]]
[[- end -]]
[[- end -]]
