#take original script
SRC_ORI=$1
export TTY=/dev/pts/10

# temp debug script
SRC_DBG=shelldb_temp_src

function cleanup_exit
{
	rm source.txt
	rm $SRC_DBG
}

# create temporary debug script
echo "source func.sh" > source.txt
cat source.txt ${SRC_ORI} > $SRC_DBG
chmod +x $SRC_DBG
./${SRC_DBG}

cleanup_exit

