#./ispass18_10nodes.sh 10 0 ispass 0;
#for i in 6 12 24;do ./ispass_gatk.sh $i ;done;
./ispass18_10nodes.sh 10 2 ispass 0;
for i in 6 12 24;do ./ispass_gatk.sh $i ;done;
./ispass18_10nodes.sh 10 1 ispass 1;
for i in 6 12 24;do ./ispass_gatk.sh $i ;done;
./ispass18_10nodes.sh 10 3 ispass 0;
for i in 6 12 24;do ./ispass_gatk.sh $i ;done;
