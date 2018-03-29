lineStart=$1
lineEnd=$2
batchComment=$3

#index=0;
file=$4

for index in `seq $lineStart $lineEnd`
do
	#while read -r c1 c2 c3 c4 c5 c6 c7 c8; do
	line=$(sed -n "${index}p" "$file")
	if (("$index" >= "$lineStart" )) && (("$index" <= "$lineEnd"))
	then
		echo "process line $index";
		#echo $c1 $c2
		echo $line
		c1=`echo $line | cut -d " " -f 1`;
		c2=`echo $line | cut -d " " -f 2`;
		c3=`echo $line | cut -d " " -f 3`;
		c4=`echo $line | cut -d " " -f 4`;
		c5=`echo $line | cut -d " " -f 5`;
		c6=`echo $line | cut -d " " -f 6`;
		c7=`echo $line | cut -d " " -f 7`;
		c8=`echo $line | cut -d " " -f 8`;
		c9=`echo $line | cut -d " " -f 9`;
		./run_Config_Flint.sh $c1 $c2 $c3 $c4 $c5 $c6 $c7 $c8 $c9 $batchComment
	fi
	index=$((index+1))
done
	#done < c4_sample_config
