#!/bin/bash
#THIS IS THE CONFIGURATION YOU SHOULD CUSTOMIZE WITH YOUR SYSTEM INFO

if [ $# -eq 5 ]
then
    :
else
    echo "./run_Config.sh configID comment testSize nodeChangeFlag nodeNum"
    exit
fi

config=$1
comment=$2
testSize=$3
nodeChangeFlag=$4
nodeNum=$5
SPARK_HOME="/curr/hadoop/spark-1.6.2-bin-hadoop2.6";            
HADOOP_HOME="/curr/peipei/hadoop/hadoop-2.6.0";		               

#old
#SPARK_MASTER="cdsc0";						       
#HDFS_MASTER="m20";						       

#new
master_IP="master"
SPARK_MASTER="$master_IP";						       
HDFS_MASTER="$master_IP";						       

startNum="$nodeNum"
endNum="$nodeNum"
##########CHANGE HERE###########
case "$config" in
     "0") echo "2ssd config"
     #WORKER_NODES=(m14 m15 m16)
     WORKER_NODES=(0 1 3 4 5 6 17 18 19 20)
     HDFS_PATH="/ssd_hdfs2/hadoop1"
     #SPARK_TMP="/ssd_hdfs1/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
     ;;

     "1") echo "hdd as HDFS, ssd as spark_tmp config"
     #WORKER_NODES=(m14 m15 m16)
     WORKER_NODES=(0 1 3 4 5 6 17 18 19 20)
     HDFS_PATH="/hdfs0/hadoop_conf1"
     #SPARK_TMP="/ssd_hdfs1/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
 
     ;;

     "2") echo "ssd as HDFS, hdd as spark_tmp config"
     #WORKER_NODES=(m14 m15 m16)
     WORKER_NODES=(0 1 3 4 5 6 17 18 19 20)
     HDFS_PATH="/ssd_hdfs2/hadoop1"
     #SPARK_TMP="/hdfs1/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
     ;;

     "3") echo "2hdd config"
     #WORKER_NODES=(c0)
     WORKER_NODES=(0 1 3 4 5 6 17 18 19 20)
     HDFS_PATH="/hdfs0/hadoop_conf1"
     #SPARK_TMP="/hdfs1/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
     ;;

     "5") echo "ssd as HDFS, two hdd as spark_tmp config"
     WORKER_NODES=(m11 m12 m13)
     HDFS_PATH="/ssd_hdfs_conf5/hadoop_conf5"
     #SPARK_TMP="/hdfs0/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
     ;;

     "6") echo "2hdd config"
     WORKER_NODES=(10.10.0.7)
     HDFS_PATH="/hdfs0/hadoop1"
     #SPARK_TMP="/hdfs1/spark_tmp"
     echo "HDFS path is $HDFS_PATH"
     ;;

esac


################################
#change the spark-env.sh and hdfs-site.xml in the following directory
SPARK_CONF_DIR="/curr/hadoop/spark-1.6.2-bin-hadoop2.6/conf";   
HADOOP_CONF_DIR="/curr/hadoop/hadoop_conf";			       

cp $SPARK_CONF_DIR/spark-env-conf${config}.sh $SPARK_CONF_DIR/spark-env.sh
cp $HADOOP_CONF_DIR/hdfs-site-conf${config}.xml $HADOOP_CONF_DIR/hdfs-site.xml

#exit;
###############################


#2ssd
#WORKER_NODES=(m14 m15 m16)
#HDFS_PATH="/ssd_hdfs2/hadoop1"
#SPARK_TMP="/ssd_hdfs1/spark_tmp"

#ssd as HDFS, hdd as spark_tmp
#WORKER_NODES=(m14 m15 m16)
#HDFS_PATH="/ssd_hdfs2/hadoop1"
#SPARK_TMP="/hdfs0/spark_tmp"

#hdd as HDFS, ssd as spark_tmp
#WORKER_NODES=(m14 m15 m16)
#HDFS_PATH="/hdfs0/hadoop1"
#SPARK_TMP="/ssd_hdfs1/spark_tmp"

#hdd as HDFS, hdd as spark_tmp
#WORKER_NODES=(m11 m12 m13)
#HDFS_PATH="/hdfs0/hadoop1"
#SPARK_TMP="/hdfs1/spark_tmp"


REFERENCE_FILE="/curr/peipei/others/genomeTMP/benchmark/dbsnp_138.b37.excluding_sites_after_129.vcf";                          
VCF_FILE="/curr/peipei/others/genomeTMP/benchmark/human_g1k_v37.2bit"; 
BAM_FILE="/curr/peipei/others/genomeTMP/${testSize}M/HCC1954_${testSize}M.readnamesort.bam";
#EXECUTOR_CORES_TEST="36";
#EXECUTOR_CORES_TEST="10 8 6 4 2 1";
#shuffle remain
#EXECUTOR_CORES_TEST="13 11 9";
#HDFS 
#EXECUTOR_CORES_TEST="36 24 12 6 5 4 3 2 1";
#EXECUTOR_CORES_TEST="2 1";
EXECUTOR_CORES_TEST="4";
#SCRIPTS_TEST="/curr/rzy/GATK/new/spark-bench/Terasort/bin/run.sh";
SCRIPTS_TEST="/curr/hadoop/GATK/Flint/SRR_flint.sh"
#SCRIPTS_TEST="/curr/rzy/GATK/new/whole_aries/shuffle.sh";
#SCRIPTS_TEST="/curr/rzy/GATK/new/whole_aries/HDFS.sh";
#SCRIPTS_TEST="/curr/rzy/GATK/new/whole_aries/countsReads.sh";
TEST_TIMES=1;

SPARK_SLAVES_CONF=$SPARK_CONF_DIR"/slaves";
HADOOP_SLAVES_CONF=$HADOOP_CONF_DIR"/slaves";
SPARK_START_SCRIPT=$SPARK_HOME"/sbin/start-all.sh";
SPARK_STOP_SCRIPT=$SPARK_HOME"/sbin/stop-all.sh";
HDFS_START_SCRIPT=$HADOOP_HOME"/sbin/start-dfs.sh";
HDFS_STOP_SCRIPT=$HADOOP_HOME"/sbin/stop-dfs.sh";
UPDATE_ENV="source /curr/hadoop/.ics.sh;\
export SPARK_CONF_DIR=$SPARK_CONF_DIR;\
export HADOOP_CONF_DIR=$HADOOP_CONF_DIR"

clean_hdfs() {
    for node in $NODE_LIST
    do
	ssh -t $node "rm -rf ${HDFS_PATH}/datanode/*; rm -rf ${HDFS_PATH}/namenode/*;";
    done
    ssh -t $HDFS_MASTER "rm -rf ${HDFS_PATH}/datanode/*; rm -rf ${HDFS_PATH}/namenode/*;";    
    ssh $HDFS_MASTER "eval $UPDATE_ENV; hadoop namenode -format";
    sleep 5;
}

stop_service() {
    ssh $SPARK_MASTER "eval $UPDATE_ENV; $SPARK_STOP_SCRIPT";
    ssh $HDFS_MASTER "eval $UPDATE_ENV; $HDFS_STOP_SCRIPT";
    sleep 5;
}

start_service() {
    ssh $SPARK_MASTER "eval $UPDATE_ENV; $SPARK_START_SCRIPT";
    ssh $HDFS_MASTER "eval $UPDATE_ENV; $HDFS_START_SCRIPT";
    sleep 5;
}

update_conf() {
    echo > $SPARK_SLAVES_CONF;
    echo > $HADOOP_SLAVES_CONF;
    for slave in $NODE_LIST
    do
	echo $slave >> $SPARK_SLAVES_CONF;
	echo $slave >> $HADOOP_SLAVES_CONF;	
    done
}

get_node_list() {
    NODE_LIST="";
	CLEAN_LIST="";
    node_num_minus=`expr $node_num - 1`;
    for node_id in `seq 0 $node_num_minus`
    do
#	echo $node_id ${WORKER_NODES[$node_id]};
	NODE_LIST=$NODE_LIST" c${WORKER_NODES[$node_id]}";
	CLEAN_LIST=$CLEAN_LIST" 10.1.255.${WORKER_NODES[$node_id]}";
    done
    echo "The node list is: "$NODE_LIST;
    echo "The clean node ip list is: "$CLEAN_LIST;
}

upload_hdfs_file() {
	
    if [ "$nodeChangeFlag" -eq 1 ]
    then
    hadoop fs -mkdir /user;
    #hadoop fs -mkdir /user/rzy;
    hadoop fs -mkdir /user/hadoop;
    hadoop fs -put $REFERENCE_FILE;
    hadoop fs -put $VCF_FILE;
    hadoop fs -put $BAM_FILE;
    fi

}

clean_cache() {
    for node in $CLEAN_LIST
    do
	ssh root@${node} -p 2017;
    done
    #ssh -t $SPARK_MASTER 'sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"';
    #ssh -t $HDFS_MASTER 'sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"';
    sleep 5;
}

run_test() {

	index=0;
    while read -r a b; do
		size[$index]=$a
		bamArray[$index]=$b
		index=$((index+1))
	done < ./file_list
	bamNum=$((index))
	echo "Total Bam file num is $bamNum"



    for core_num in $EXECUTOR_CORES_TEST
    do
	for script in $SCRIPTS_TEST
	do
	    for _ in `seq 1 $TEST_TIMES`
	    do
			for bamIndex in `seq 0 $((bamNum-1))`
			do
				bamInput=${bamArray[$bamIndex]}
				bamSize=${size[$bamIndex]}
				clean_cache;
				$script $bamInput $core_num;
				#script_name=`echo $script | sed "s/.*\/\(.*\)\/.*sh/\1/g"`;
				app_id=`curl http://10.1.253.0:8081/ | grep -i appid | sed -n 1p | sed 's/\(.*\)appId=\(.*\)".*/\2/g'`;
				stage0=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 0 | cut -d " " -f 3`;
				stage1=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 1 | cut -d " " -f 3`;
				stage2=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 2 | cut -d " " -f 3`;
				stage8=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 8 | cut -d " " -f 3`;
				stage9=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 9 | cut -d " " -f 3`;

				echo "conf${config} $node_num $core_num $bamInput $bamSize $app_id $stage0 $stage1 $stage2 $stage8 $stage9">> run_result.${comment}_${testSize}.txt;
				#./rm_output.sh $testSize;
			done
	    done
	done
    done
}


main() {
    eval $UPDATE_ENV;
    resultFile="run_result.${comment}_${testSize}.txt";

    if [ -f $resultFile ]
	    then
		    :
    else	
	    echo "conf node_num core_num bamName bamSize app_id stage0 stage1 stage2 stage8 stage9" > run_result.${comment}_${testSize}.txt;
    fi

    for node_num in `seq $startNum -1 $endNum`
    do
    get_node_list;
    

	#case "$nodeChangeFlag" in
	#	"1") echo "start and clean hdfs"

	#		stop_service;
	#		update_conf;
	#		clean_hdfs;
	#		start_service;
	#		upload_hdfs_file;
	#		;;


	#	"0") echo "start and not clean hdfs"

	#		stop_service;
	#		update_conf;
	#		#clean_hdfs;
	#		start_service;
	#		;;
	#esac
    
	run_test;

    done
}

main;
