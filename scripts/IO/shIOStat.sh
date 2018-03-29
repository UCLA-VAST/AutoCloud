#iostat $1 -c -d -x -t -m 1 $2 > iostat_${3}.out
iostat -c -d -x -t -m 1 $1 > iostat_${2}.out
