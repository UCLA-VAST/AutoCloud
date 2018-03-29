app_id=`curl http://10.1.253.0:8081/ | grep -i appid | sed -n 1p | sed 's/\(.*\)appId=\(.*\)".*/\2/g'`;
stage0=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 0 | cut -d ' ' -f 3`;
stage1=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 1 | cut -d " " -f 3`;
stage2=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 2 | cut -d " " -f 3`;
stage8=`/curr/rzy/spark/history/sh/parse_Singlefile_stage.sh $app_id 8 | cut -d " " -f 3`;
echo $app_id $stage0 $stage1 $stage2 $stage8
