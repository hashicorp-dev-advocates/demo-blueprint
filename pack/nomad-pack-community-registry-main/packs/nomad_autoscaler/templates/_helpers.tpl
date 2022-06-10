[[- define "full_job_name" -]]
[[- if eq .nomad_autoscaler.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .nomad_autoscaler.job_name | quote -]]
[[- end -]]
[[- end -]]

[[- define "full_args" -]]
[[- $fullArgs := prepend .nomad_autoscaler.autoscaler_agent_task.additional_cli_args "agent" -]]
[[- if .nomad_autoscaler.autoscaler_agent_task.scaling_policy_files ]][[ $fullArgs = append $fullArgs "-policy-dir=${NOMAD_TASK_DIR}/policies" ]][[- end -]]
[[- if .nomad_autoscaler.autoscaler_agent_task.config_files ]][[ $fullArgs = append $fullArgs "-config=${NOMAD_TASK_DIR}/config" ]][[- end -]]
[[ $fullArgs | toPrettyJson ]]
[[- end -]]
