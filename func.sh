# variable to store continue state 
CONTI=false
BP=NULL
UNTIL=false
SRC_LIST=list.src
DISPLAY_WINDOW_SIZE=30

function update_list_src
{
	pushd $SHELLDB_EXEC_DIR > /dev/null

			# function to show updated shource to user
			line_to_mark=$1

			# get copy of list and align with source 
			cat shelldb_temp_src > shelldb_temp_list
			sed -i -e "1d" shelldb_temp_list

			cat -n shelldb_temp_list > shelldb_temp_list_show

			# point current execution 
			sed -i -e "$line_to_mark s/^  /=>/" shelldb_temp_list_show

	popd > /dev/null

}

function display_src
{
	pushd $SHELLDB_EXEC_DIR > /dev/null
			# if TTY variable is set display to given tty 
			if [ -z ${TTY} ]
			then 
					# TTY is not set use current tty to print portion of source code
					#TODO: improments 
					line_start_sed=$(( line_to_mark - $DISPLAY_WINDOW_SIZE )) 
					# bound on line_start
					if [ "$line_start_sed" -lt "0" ]
					then 
							line_start_sed=1
					fi 
					line_end_sed=$(( line_to_mark + $DISPLAY_WINDOW_SIZE )) 
					# bound on line end TODO

					sed -n "${line_start_sed},${line_end_sed}p" shelldb_temp_list_show  2> /dev/null
			else
					# TTY is set use it to display 
					# display source to some ttys 
					echo "clear" | bash > ${TTY}

					line_start_sed=$(( line_to_mark - $DISPLAY_WINDOW_SIZE )) 
					# bound on line_start
					if [ "$line_start_sed" -lt "0" ]
					then 
							line_start_sed=1
					fi 
					line_end_sed=$(( line_to_mark + $DISPLAY_WINDOW_SIZE )) 
					# bound on line end TODO

					sed -n "${line_start_sed},${line_end_sed}p" shelldb_temp_list_show > ${TTY} 2> /dev/null
			fi 

	popd > /dev/null
}

function step_trap
{
	# function called by trap on each logical debug line
	line_number=$1

	#check for breakpoints
	if [ "$BP" = "$line_number" ]
	then 
			# breakpoint reached

			# check if it is until commands breakpoint
			if [ $UNTIL = "true" ]
			then 
					UNTIL=false
					#remove breakpoint
					BP=NULL
			fi

			CONTI=false
			echo "Stopped at breakpoint: $line_number"
	fi 


	if [ $CONTI == "false" ]
	then 
			# skip this and continue till breakpoint
			# echo "Line number is: $line_number"

			# update source list 
			update_list_src $((line_number - 1 ))
			display_src 

			# command loop
			GO=false
			while [ $GO == "false" ]
			do 
					read -p "(shelldb) " command agr1 arg2 

					case $command in 
							next | n)
									#echo "Next command"
									CONTI=false
									GO=true
									;;
							until)
									#echo "until command"
									UNTIL=true
									BP=$(( agr1 + 1 ))
									CONTI=true
									GO=true
									;;
							break | b)
									BP=$(( agr1 + 1 ))
									echo "breakpoint set at line $agr1"
									GO=false
									;;
							print | p)
									#echo "print variable"
									echo ${!agr1}
									GO=false
									;;
							set)
									#echo "print variable"
									export $agr1=${arg2}
									GO=false
									;;
							continue | c)
									echo "continuing execution"
									CONTI=true
									GO=true
									;;
							list)
									#echo "list the source"
									display_src 
									GO=false
									;;
							quit)
									echo "Exiting"
									pushd $SHELLDB_EXEC_DIR > /dev/null
											rm shelldb_temp_list
											rm shelldb_temp_list_show
									popd > /dev/null
									exit 0
									;;
							*)
									echo "Enter valid command, press h for help"
									GO=false
					esac
			done 

	fi

	# continue 

}

trap 'step_trap $LINENO' DEBUG
