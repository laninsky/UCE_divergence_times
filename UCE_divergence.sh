filetype=`tail -n+1 UCE_divergence.settings | head -n1`
method=`tail -n+2 UCE_divergence.settings | head -n1`
methodoptions=`tail -n+3 UCE_divergence.settings | head -n1`

if [ "$method" = "paup" ]; then

if [ "$filetype" = "fasta" ]; then
for f in `ls *.fasta`; do 
newname=`echo $f | sed "1s/.fasta//"`
seqmagick convert --alphabet dna-ambiguous $newname.fasta $newname.nex
done
fi

if [ "$filetype" = "nexus" ]; then
for f in `ls *.nexus`; do 
newname=`echo $f | sed "1s/.nexus//"`
mv $newname.nexus $newname.nex
done
fi

ls *.nex | tail -n+1 | head -n1 > renamefile
Rscript shortennames.R
bash shortnames.sh

NEXUSFILES=*.nex
for f in $NEXUSFILES; do 
basename=`echo $f | sed "1s/.nex//"`
printf "begin paup; execute $f; Dset $methodoptions; SaveDist FORMAT=PHYLIP FILE=$basename.out TRIANGLE=BOTH UNDEFINED=ASTERISK REPLACE=YES APPEND=NO; end;" > paup_file
paup -n paup_file
done

else

if [ "$filetype" = "nexus" ]; then
for f in `ls *.nexus`; do 
newname=`echo $f | sed "1s/.nexus//"`
mv $newname.nexus $newname.nex
done
fi

if [ "$filetype" != "fasta" ]; then
for f in `ls *.nex*`; do 
newname=`echo $f | sed "1s/.nex//"`
seqmagick convert --alphabet dna-ambiguous $newname.nex $newname.fasta
done
fi

FASTAFILES=*.fasta
for f in $FASTAFILES; do 
basename=`echo $f | sed "1s/.fasta//"`
sed -i 's/?/-/g' $f
~/bin/fastphylo-1.0.1-Linux/bin/fastdist $f -o $basename.out -O phylip $methodoptions
done
fi

rm -rf combined.outfile

OUTFILES=*.out
for f in $OUTFILES; do
basename=`echo $f | sed "1s/.out//"`
awk '{print chrname" "$0}' chrname="$basename" $f | tail -n +2 >> combined.outfile
done

rm -rf *.out

if [ "$method" = "paup" ]; then
bash lengthennames.sh
fi

Rscript UCE_divergence.R

