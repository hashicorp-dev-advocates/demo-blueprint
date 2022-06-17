snapshot:
	docker run --rm -v $(shell pwd)/minecraft:/data \
           -e RESTIC_REPOSITORY=${SY_VAR_minecraft_restic_repository} \
           -e RESTIC_PASSWORD=${SY_VAR_minecraft_restic_password} \
           -e AWS_ACCESS_KEY_ID=${SY_VAR_minecraft_restic_key} \
           -e AWS_SECRET_ACCESS_KEY=${SY_VAR_minecraft_restic_secret} \
       instrumentisto/restic backup --tag "manual" /data

restore:
	docker run --rm -v $(shell pwd)/restore:/data \
           -e RESTIC_REPOSITORY=${SY_VAR_minecraft_restic_repository} \
           -e RESTIC_PASSWORD=${SY_VAR_minecraft_restic_password} \
           -e AWS_ACCESS_KEY_ID=${SY_VAR_minecraft_restic_key} \
           -e AWS_SECRET_ACCESS_KEY=${SY_VAR_minecraft_restic_secret} \
       instrumentisto/restic restore latest --target /data

run:
	shipyard run --vars-file=./live_env.shipyardvars .
