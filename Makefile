

init-dirs:
	cat required_dirs.txt | xargs mkdir -p


rc-local-up:
	docker compose up -d

rc-local-down:
	docker compose down

rclogs:
	# display Docker logs for RocketChat procs


verify-mongodb:
	export MONGO_DB_NAME=`docker ps -a | grep mongo | awk '{ print $11 }'`
	echo $$MONGO_DB_NAME


rc-backup:
	export MONGO_DB_NAME=`docker ps -a | grep mongo | awk '{ print $11 }'`

	warp --py --template-file=template_files/dump_script.tpl \
	--macros=rocketlab_macros --macro-args=base_name:rocketchat_backup


rc-restore: init-dirs
	#_______________________________________________________________________
	# 
	# acquire the name of our Mongo Docker container 
	# and use it to set an env var
	#_______________________________________________________________________
	#

	export MONGO_DB_NAME=`docker ps -a | grep mongo | awk '{ print $11 }'`

	#_______________________________________________________________________
	#
	# create an empty shell script
	#_______________________________________________________________________
	#

	cp template_files/shell_script_core.sh.tpl temp_scripts/rc-restore.sh
	
	#_______________________________________________________________________
	#
	# prompt the user to select an existing Mongodb dumpfile,
	# and store the result as the JSON record:
	#
	# { "dumpfile": <dumpfile_name> }
	#
	# in the file "selected_mongodump_filename,json".
	# (make sure the file does not exist)
	#_______________________________________________________________________
	#

	rm -f tempdata/selected_mongodump_filename.json 
	scripts/prompt_for_restore_file.py -o tempdata/selected_mongodump_filename.json -k dumpfile

	#_______________________________________________________________________
	#
	# use that structured-data record to generate a "restore" command
	# by populating a warp template; add the command to our shell script
	#_______________________________________________________________________

	cat tempdata/selected_mongodump_filename.json \
	| warp --py --template-file=template_files/restore_script.tpl \
	--macros=rocketlab_macros --macro-args=base_name:rocketchat_backup -s \
	>> temp_scripts/rc-restore.sh

	#_______________________________________________________________________
	#
	# execute
	#_______________________________________________________________________

	chmod u+x temp_scripts/rc-restore.sh
	temp_scripts/rc-restore.sh
	




