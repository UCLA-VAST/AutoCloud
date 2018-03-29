#!/bin/bash
BAM=$1
CORES_PER_NODE=$2
memory_tmp=$3
/curr/rzy/GATK/new/whole_aries/gatk-launch-hdfs \
ReadsPipelineSpark \
-I hdfs://10.10.253.0:9000/user/hadoop/${BAM} \
-R hdfs://10.10.253.0:9000/user/hadoop/human_g1k_v37.2bit \
-O hdfs://10.10.253.0:9000/user/hadoop/${BAM}.out.bam \
--knownSites hdfs://10.10.253.0:9000/user/hadoop/dbsnp_138.b37.excluding_sites_after_129.vcf \
--shardedOutput true \
--emit_original_quals \
--duplicates_scoring_strategy SUM_OF_BASE_QUALITIES \
-- \
--sparkRunner SPARK \
--driver-memory 20G \
--executor-memory ${memory_tmp}G \
--executor-cores ${CORES_PER_NODE} \
--num-executors 1 \
--sparkMaster spark://10.10.253.0:7077
