docker exec $MONGO_DB_NAME sh -c 'mongodump --archive' > ~macro[generate_dumpfile_name]
