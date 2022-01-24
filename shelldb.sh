#!/bin/bash

#take original script
SRC_ORI=$1
export TTY=$2
# temp debug script
SRC_DBG="shelldb_temp_src"


function cleanup_exit
{
	rm $SRC_DBG
	rm -rf shelldb_temp_list
	rm -rf shelldb_temp_list_show
	
}


# create temporary debug script
echo "source func.sh" > ${SRC_DBG}
cat ${SRC_ORI} >> ${SRC_DBG}
chmod +x $SRC_DBG
./${SRC_DBG}

cleanup_exit


