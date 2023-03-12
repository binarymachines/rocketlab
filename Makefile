

init-dirs:
	cat required_dirs.txt | xargs mkdir -p


rc-local-up:
	docker compose up -d


rc-local-down:
	docker compose down


rclogs:
	# display Docker logs for RocketChat procs


verify-mongodb:
	export MONGO_DB_NAME=`docker ps -a | grep mongo | awk '{ print $$11 }'`
	echo $$MONGO_DB_NAME


rc-backup:
	#_______________________________________________________________________
	# 
	# acquire the name of our Mongo Docker container 
	# and use it to set an env var
	#_______________________________________________________________________
	#

	$(eval DOCKER_PID=$(shell docker ps -a |grep mongo | awk '{ print $$1 }'))

	docker inspect $(DOCKER_PID) | jq .[0].Name | sed s/'"'//g | cut -c2- > tempdata/docker_db_volume.txt

	#_______________________________________________________________________
	#
	# create an empty shell script
	#_______________________________________________________________________
	#

	cp template_files/shell_script_core.sh.tpl temp_scripts/rc-dump.sh

	#_______________________________________________________________________
	#
	# create the dump command line from our template and add it to our script
	#_______________________________________________________________________
	#

	$(eval DUMPFILE_NAME=$(shell warp --py --template=rocketlab_templates.backup_filename --macros=rocketlab_macros --params=timestamp:~macro[current_timestamp]))
	
	$(eval DBNAME=$(shell cat tempdata/docker_db_volume.txt))

	warp --py --template-file=template_files/dump_script.tpl \
	--params=dumpfile:tempdata/$(DUMPFILE_NAME),dbname:$(DBNAME) >> temp_scripts/rc-dump.sh

	chmod u+x temp_scripts/rc-dump.sh
	temp_scripts/rc-dump.sh


rc-restore: init-dirs
	$(eval DOCKER_PID=$(shell docker ps -a |grep mongo | awk '{ print $$1 }'))
	
	#_______________________________________________________________________
	# 
	# acquire the name of our Mongo Docker container 
	# and use it to set an env var
	#_______________________________________________________________________
	#

	docker inspect $(DOCKER_PID) | jq .[0].Name | sed s/'"'//g | cut -c2- > tempdata/docker_db_volume.txt

	#_______________________________________________________________________
	#
	# create an empty shell script
	#_______________________________________________________________________
	#

	cp template_files/shell_script_core.sh.tpl temp_scripts/rc-restore.sh
	
	#_______________________________________________________________________
	#
	# prompt the user to select an existing Mongodb dumpfile,
	# and store the name in a file
	#
	# (first make sure the file does not exist)
	#_______________________________________________________________________
	#

	rm -f tempdata/selected_mongodump_filename.txt
	scripts/prompt_for_restore_file.py -o tempdata/selected_mongodump_filename.txt -w tempdata

	#_______________________________________________________________________
	#
	# fold the generated names (db volume name and dumpfile name)
	# into a structured-data record
	#_______________________________________________________________________
	#

	tuplegen --delimiter % --listfiles=tempdata/selected_mongodump_filename.txt,tempdata/docker_db_volume.txt \
	| tuple2json --delimiter % --keys=dumpfile,dbname > warp_params.json

	#_______________________________________________________________________
	#
	# use the structured data to generate a "restore" command
	# by populating a warp template; add the command to our shell script
	#_______________________________________________________________________

	cat warp_params.json \
	| warp --py --template-file=template_files/restore_script.tpl -s \
	>> temp_scripts/rc-restore.sh

	#_______________________________________________________________________
	#
	# execute
	#_______________________________________________________________________

	chmod u+x temp_scripts/rc-restore.sh
	temp_scripts/rc-restore.sh
	




