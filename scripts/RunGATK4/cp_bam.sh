SPARK_HOME="/curr/hadoop/spark-1.6.2-bin-hadoop2.6";            
HADOOP_HOME="/curr/peipei/hadoop/hadoop-2.6.0";		               
SPARK_CONF_DIR="/curr/hadoop/spark-1.6.2-bin-hadoop2.6/conf";   
HADOOP_CONF_DIR="/curr/hadoop/hadoop_conf";			       

UPDATE_ENV="source /curr/hadoop/.ics.sh;\
export SPARK_CONF_DIR=$SPARK_CONF_DIR;\
export HADOOP_CONF_DIR=$HADOOP_CONF_DIR"

bamInput=$1
nodeNum=1
upload_bam() {
	
	if [ "$nodeNum" -ne "1" ]
	then
		ssh c4 "eval $UPDATE_ENV; hdfs dfs -Ddfs.replication=2 -put /hdfs0/FlintData-bam/${bamInput}";
	else
		ssh c4 "eval $UPDATE_ENV; hdfs dfs -put /hdfs0/FlintData-bam/${bamInput}";

	fi
}


upload_bam;
