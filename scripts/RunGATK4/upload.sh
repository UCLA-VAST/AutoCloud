index=0;
echo > c4_sample
while read -r a b c d e f g h i; do
	
	if ((${index}%27 < 16))
	then
		echo $e $i >> c4_sample  
	fi
	index=$((index+1))

done < c4_ls
