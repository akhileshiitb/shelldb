# variable to store continue state 
CONTI=false
BP=NULL
UNTIL=false
SRC_LIST=list.src

function update_list_src
{
	# function to show updated shource to user
	line_to_mark=$1

	#echo "update list.src"

	# get copy of list and align with source 
	cat shelldb_temp_src > shelldb_temp_list
	sed -i -e "1d" shelldb_temp_list

	cat -n shelldb_temp_list > shelldb_temp_list_show

	# point current execution 
	sed -i -e "$line_to_mark s/^  /=>/" shelldb_temp_list_show

}

function display_src
{
	# if TTY variable is set display to given tty 
	if [ -z ${TTY} ]
	then 
			# TTY is not set use current tty to print portion of source code
			#TODO: improments 
			sed -n "$(( line_to_mark - 5 )),$(( line_to_mark + 5 ))p" shelldb_temp_list_show 2> /dev/null
	else
			# TTY is set use it to display 
			# display source to some ttys 
			echo "clear" | bash > ${TTY}
			cat < shelldb_temp_list_show > ${TTY}
	fi 
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
									rm shelldb_temp_list
									rm shelldb_temp_list_show
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
