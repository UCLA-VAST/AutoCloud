#nodeList="4 3 2 1"
#nodeList="5"
nodeList="4 3 2 5"
storageList="0 1 2 3"
#cpuList="10 9 8 6 4"
cpuList="11 10 9 8 7"
#memoryList="0"
memoryList="1"
comment=$1

echo  "nodeConf storageConf cpuConf MEMLIMIT SPARK_MEM cleanHdfs startService" > config.txt 
for nodeConf in $nodeList
do
	for storageConf in $storageList
	do
		clearHdfsFlag=$((1-storageConf/2))
		startServiceFlag=1
		for cpuConf in $cpuList
		do
			for memConf in $memoryList
			do

				case "$memConf" in
					# high memory
					"0") echo "HIGH MEM config"
					MEMLIMIT=$((6979321856*cpuConf))
					;;

					#standard memory	
					"1") echo "standard MEM config"
					MEMLIMIT=$((4026531840*cpuConf))
					;;	

			esac

			SPARK_MEM=$((MEMLIMIT/1073741824))
			if [ "$SPARK_MEM" -gt 60 ]
			then
				SPARK_MEM="60"
			fi

			echo "MEMLIMIT is $MEMLIMIT B SPARK_MEM is $SPARK_MEM GB";

			echo "$nodeConf $storageConf $cpuConf $MEMLIMIT $SPARK_MEM $clearHdfsFlag $startServiceFlag" >>config_${comment}.txt
			#startServiceFlag=0;
			clearHdfsFlag=0;
		done
	done
done

done
