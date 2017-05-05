#!/bin/bash
# run as hadoop so that ssh can connect automatically
if test "${USER}" != "hadoop"
then
    echo "Please run as hadoop." >&2
    exit 0
fi

FASTA_FILE=/cdsc_genomics/reference/human_g1k_v37.fasta
FASTQ_GZ_DIR=/cdsc_genomics/fastq/todo
BAM_DIR=/cdsc_genomics/hadoop-writable
SCRIPT_DIR=~blaok/git/AutoCloud/scripts/preprocess
SORT_TMP=/ssd_hdfs1
LOCAL_TMP=/tmp
WORKERS="11 12 13 14 15 16"

# check for necessary things on remote: reference, fastqs, bamdir, scripts
PID=$$
for nid in ${WORKERS}
do
    rm -f ${LOCAL_TMP}/c${nid}RUNNING-${PID}
    if ! ssh 10.10.${nid}.7 bash <<EOS
        (test -f ${FASTA_FILE} || (echo -e "\e[31m\${HOSTNAME}:\e[39m Reference file \"${FASTA_FILE}\" not found." >&2;exit 1)) &&
        (test -d ${FASTQ_GZ_DIR} || (echo -e "\e[31m\${HOSTNAME}:\e[39m Input fastq directory \"${FASTQ_GZ_DIR}\" not found." >&2;exit 1)) &&
        (test -d ${BAM_DIR} || (echo -e "\e[31m\${HOSTNAME}:\e[39m Output bam directory \"${BAM_DIR}\" not found." >&2;exit 1)) &&
        (touch ${BAM_DIR}/test >/dev/null 2>/dev/null && rm ${BAM_DIR}/test >/dev/null 2>/dev/null || (echo -e "\e[31m\${HOSTNAME}:\e[39m Output bam directory \"${BAM_DIR}\" is not writable." >&2;exit 1)) &&
        (test -x ${SCRIPT_DIR}/bwa/bwa || (echo -e "\e[31m\${HOSTNAME}:\e[39m Executable \"${SCRIPT_DIR}/bwa/bwa\" not found." >&2;exit 1)) &&
        (test -x ${SCRIPT_DIR}/samtools/samtools || (echo -e "\e[31m\${HOSTNAME}:\e[39m Executable \"${SCRIPT_DIR}/samtools/samtools\" not found." >&2;exit 1)) &&
        (test -d ${SORT_TMP} || (echo -e "\e[31m\${HOSTNAME}:\e[39m Sort tmp directory\"\" not found." >&2;exit 1)) &&
        (test -w ${SORT_TMP} || (echo -e "\e[31m\${HOSTNAME}:\e[39m Sort tmp directory\"\" not writable." >&2;exit 1)) &&
        true
EOS
    then
        exit 1
    fi
done

# check for necessary things on local: tmp for locks
if ! test -d ${LOCAL_TMP}
then
    echo -e "\e[31m${HOSTNAME}:\e[39m Local tmp directory \"${LOCAL_TMP}\" not found." >&2
    exit 1
fi
if ! test -w ${LOCAL_TMP}
then
    echo -e "\e[31m${HOSTNAME}:\e[39m Local tmp directory \"${LOCAL_TMP}\" not wriable." >&2
    exit 1
fi

function worker() # SCRIPT_DIR, nid, fastq_gz_file, FASTQ2, SORT_TMP, BAM_FILE
{

    ssh 10.10.${nid}.7 bash 2> >(tee ${BAM_DIR}/${BAM_FILE//.bam/.log} >&2) <<EOS
        ${SCRIPT_DIR}/bwa/bwa mem -t \$(nproc) -Ma -R "@RG\tID:HCC1954\tPL:illumina\tLB:HCC1954\tSM:HCC1954" ${FASTA_FILE} ${fastq_gz_file} ${FASTQ2}|\
        ${SCRIPT_DIR}/samtools/samtools sort -n -@ \$(nproc) -T ${SORT_TMP}/samtools.sort -m \$((16384/\$(nproc)))M -o ${BAM_DIR}/${BAM_FILE}
EOS
    rm ${LOCAL_TMP}/c${nid}RUNNING-${PID}
}

for fastq_gz_file in $(ls -S ${FASTQ_GZ_DIR}/*.fastq.gz)
do
    [[ $fastq_gz_file == *_2.fastq.gz ]] && continue

    unset FASTQ2
    [[ $fastq_gz_file == *_1.fastq.gz ]] && FASTQ2=${fastq_gz_file//_1.fastq.gz/_2.fastq.gz}

    BAM_FILE=$(basename ${fastq_gz_file}|sed -e 's/fastq.gz/bam/' -e 's/_1//')

    DONE=false
    while true
    do
        for nid in ${WORKERS}
        do
            if ! test -f ${LOCAL_TMP}/c${nid}RUNNING-${PID}
            then
                touch ${LOCAL_TMP}/c${nid}RUNNING-${PID}
                worker&
                DONE=true
                break
            fi
        done
        if ${DONE}
        then
            break
        fi
        sleep 1
    done
done

wait

