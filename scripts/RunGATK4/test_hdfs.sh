UPDATE_ENV="source /curr/hadoop/.ics.sh;\
export SPARK_CONF_DIR=$SPARK_CONF_DIR;\
export HADOOP_CONF_DIR=$HADOOP_CONF_DIR"

ssh c4 "eval $UPDATE_ENV; hdfs dfs -Ddfs.replication=2 -put /curr/hadoop/GATK/Flint/test_hdfs.sh";

clean_hdfs() {
    for node in $NODE_LIST
    do
	ssh -t $node "rm -rf ${HDFS_PATH}/datanode/*; rm -rf ${HDFS_PATH}/namenode/*;";
    done
    ssh -t $HDFS_MASTER "rm -rf ${HDFS_PATH}/datanode/*; rm -rf ${HDFS_PATH}/namenode/*;";    
    ssh $HDFS_MASTER "eval $UPDATE_ENV; hadoop namenode -format";
    sleep 5;
}

