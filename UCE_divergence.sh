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







fi else
then if [ "$filetype" = "nexus" ]
touch $newname.nex
cat $f > $newname.nex

NEXUSFILES=*.nexus
for f in $NEXUSFILES; do 
## Gonna extract the informative part of the name for the outfile
newname=`echo $f | sed "1s/.nexus//"`
touch $newname.nex
cat $f > $newname.nex
~/bin/seqmagick/bin/seqmagick convert $newname.nex $newname.fasta
done

# first thing first, paup strips the names away to 10 characters, so going to rename things so that they are still informative after that. Might be best to do this on copied files so that you don't ruin the originals...you can comment this out if using fastphylo, because it preserves the names

#NEXUSFILES=*.nexus
#for f in $NEXUSFILES; do 
#sed -i "s/acanthosuara_armata_lsuhc9351/Aarmata_ls/g" $f
#sed -i "s/acanthosuara_lepidogaster_cwl818/Alepidogas/g" $f
#sed -i "s/bronchocela_cristatella_acd1547/Bcris_acd1/g" $f
#sed -i "s/bronchocela_cristatella_bcrist1610/Bcris_bcri/g" $f
#sed -i "s/calotes_emma_dsm1256/Cemma_dsm1/g" $f
#sed -i "s/calotes_mystecaous_dsm869/Cmystecaou/g" $f
#sed -i "s/calotes_versicolor_lsuhc10327/Cversicolo/g" $f
#sed -i "s/ceratophora_aspera_xx/Caspera_xx/g" $f
#sed -i "s/cophotis_ceylanica_c_ceylanica/Cceylanica/g" $f
#sed -i "s/draco_blanfordii_lsuhc9427/Dblanfordi/g" $f
#sed -i "s/draco_maculatus_kufs320/Dmaculatus/g" $f
#sed -i "s/draco_spilopterus_elr1338/Dspilopter/g" $f
#sed -i "s/gonocephalus_interuptus_rmb9384/Ginteruptu/g" $f
#sed -i "s/gonocephalus_sophiae_rmb8061/Gsophiae_r/g" $f
#sed -i "s/lyriocephalus_scutatus_xx/Lscutatus_/g" $f
#sed -i "s/mantheyus_phuwanensis_fmnh255495b/Mphu_25549/g" $f
#sed -i "s/mantheyus_phuwanensis_fmnh262580/Mphu_26258/g" $f
#sed -i "s/pseudocalotes_larutensis_lsuhc10285/Plarutensi/g" $f
#sed -i "s/ptyctolaemus_collicristatus_cas220561/Pcollicris/g" $f
#sed -i "s/ptyctolaemus_gularis_cas221296/Pgularis_c/g" $f
#sed -i "s/salea_horsfieldii_1/Shorsfiel1/g" $f
#sed -i "s/salea_horsfieldii_2/Shorsfiel2/g" $f
#sed -i "s/varanus_togianus_bsi1565/Vtogianus_/g" $f
#sed -i "s/pseudocalotes_kingdonwardi_cas242579/Pkingdonwa/g" $f
#done

# Now to start getting our data... this loop is generating our distances between each sequence, for each locus using fastphylo. If you use fastphylo, make sure the fasta line above is not
# commented out, and the bit below for fastphylo is not commented out (but comment out this chunk).

##PAUP has a lot of options for distances. For the distance model itself you have JC, F81, TAJNEI, K2P, F84, HKY85, K3P, TAMNEI, GTR, ML, LOGDET, UPHOLT, NEILI. NEILI/UPHOLT not applicable to DNA data.
## You can have RATES=EQUAL RATES=GAMMA. GAMMA rates not allowed with LOGDET 
## You can have SHAPE = real-value, PINVAR = real-value, and many more options as specified in paup (http://www.ucl.ac.uk/cecd/downloads/PAUP%20command%20reference%20manual.pdf)
#NEXUSFILES=*.nexus
#for f in $NEXUSFILES; do 
#basename=`echo $f | sed "1s/.nexus//"`
#printf "begin paup; execute $f; DSet DISTANCE=NEILI RATES=GAMMA SHAPE=300 MISSDIST=IGNORE; SaveDist FORMAT=PHYLIP FILE=$basename.out TRIANGLE=BOTH UNDEFINED=ASTERISK REPLACE=YES APPEND=NO; end;" > paup_file
#paup -n paup_file
#
#done

## just to clean up a bit we are going to remove all the intermediate *.nex files (if you go with the fastphylo option
rm -rf *.nex

## Now to start getting our data... this loop is generating our distances between each sequence, for each locus using fastphylo. You can also use PAUP (with other distance methods). If you go this way (see above), then comment this one out.
FASTAFILES=*.fasta
for f in $FASTAFILES; do 
basename=`echo $f | sed "1s/.fasta//"`
## replacing the missing data with gaps, because the distance algorithm doesn't deal very well with question marks
sed -i 's/?/-/g' $f
##Distance function  (possible values="JC", "K2P", "TN93", "HAMMING" default=`K2P')
## TN doesn't seem to like working on the data. F is the correction for saturation. I tested a few values and 0.95 seems to give the best minimum clade age estimates.
~/bin/fastphylo-1.0.1-Linux/bin/fastdist $f -o $basename.out -O phylip -D HAMMING -F 0.95
done

# Just making sure there isn't already a copy of the combined.outfile present, because we'll be appending to it.
rm -rf combined.outfile

#Here we are labelling each outfile with a column with the chrlx name and smushing them into one giant outfile so we can suck it through R in one go.
OUTFILES=*.out
for f in $OUTFILES; do
basename=`echo $f | sed "1s/.out//"`
awk '{print chrname" "$0}' chrname="$basename" $f | tail -n +2 >> combined.outfile
done

# just to clean up a bit we are going to remove all the intermediate *.out and *.fasta files
rm -rf *.out
rm -rf *.fasta


#OK, so now we are moving into R to do the actual number crunching
R --no-save
# being cautious and removing any variables which might be hanging out in R space
rm(list=ls())

# importing our giant outfile and converting it to a matrix so we can do things to it
in_table <- read.table("combined.outfile", header=FALSE, stringsAsFactors=FALSE)
lizardmatrix <- as.matrix(in_table[1:(dim(in_table)[1]),1:dim(in_table)[2]])
lizardmatrix <- sub("\\*",0, lizardmatrix)

rm(in_table)

# Calculating the max length of the matrix so that we can feed it into the while loop below
maxlength <- dim(lizardmatrix)[1]

# giving an intial j value
j <- 1
out <- c("locusname","maxcladespecies1","maxcladespecies2","maxcladedistance","maxmanthspecies1","maxmanthspecies2","maxmanthdistance","medmanthdistance","minmanthspecies1","minmanthspecies2","minmanthdistance","minage","medage","maxage")

while (j <= maxlength) {
#creating a matrix with just the non-mantheyus species 
tempclade <- NULL
tempclade1 <- lizardmatrix[j:(j+14),1:17]
tempclade2 <- lizardmatrix[(j+17):(j+23),1:17]
tempclade_1_2 <- rbind(tempclade1, tempclade2)
tempclade3 <- lizardmatrix[j:(j+14),20:26]
tempclade4 <- lizardmatrix[(j+17):(j+23),20:26]
tempclade_3_4 <- rbind(tempclade3, tempclade4)
tempclade <- cbind(tempclade_1_2,tempclade_3_4)

rm(tempclade1)
rm(tempclade2)
rm(tempclade_1_2)
rm(tempclade3)
rm(tempclade4)
rm(tempclade_3_4)

maxcladedistance <- max(as.numeric(tempclade[1:22,3:24]))
maxcladedistanceloc <-  arrayInd(which.max(as.numeric(tempclade[1:22,3:24])), dim(tempclade))
maxcladespecies1 <- tempclade[maxcladedistanceloc[1,1],2]
maxcladespecies2 <- tempclade[maxcladedistanceloc[1,2],2]

# creating a matrix with mantheyus to calculate the min/max divergence between them and the other critters
tempmanthclade1 <- lizardmatrix[(j+15):(j+16),1:17]
tempmanthclade2 <- lizardmatrix[(j+15):(j+16),20:26]
tempmanthclade <- cbind(tempmanthclade1, tempmanthclade2)
maxmanthdistance <- max(as.numeric(tempmanthclade[1:2,3:24]))
if(is.na(maxmanthdistance)) {
maxmanthspecies1 <- c("missing")
maxmanthspecies2 <- c("missing")
medmanthspecies1 <- c("missing")
medmanthspecies2 <- c("missing")
medmanthdistance <- c("missing")
minmanthspecies1 <- c("missing")
minmanthspecies2 <- c("missing")
minmanthdistance <- c("missing")
minage <- c("missing")
maxage <- c("missing")
} else if (maxmanthdistance==0) {
maxmanthspecies1 <- c("missing")
maxmanthspecies2 <- c("missing")
medmanthspecies1 <- c("missing")
medmanthspecies2 <- c("missing")
medmanthdistance <- c("missing")
minmanthspecies1 <- c("missing")
minmanthspecies2 <- c("missing")
minmanthdistance <- c("missing")
minage <- c("missing")
maxage <- c("missing")
} else {
maxmanthdistanceloc <-  arrayInd((which.max(as.numeric(tempmanthclade[1:2,3:24]))), dim(tempmanthclade))
maxmanthspecies1 <- tempmanthclade[maxmanthdistanceloc[1,1],2]
maxmanthspecies2 <- tempclade[maxcladedistanceloc[1,2],2]

medmanthdistance <- median(as.numeric(tempmanthclade[1:2,3:24])[(as.numeric(tempmanthclade[1:2,3:24]))>0])

minmanthdistance <- min(as.numeric(tempmanthclade[1:2,3:24])[(as.numeric(tempmanthclade[1:2,3:24]))>0])
minmanthdistanceloc <-  arrayInd(which(minmanthdistance==(as.numeric(tempmanthclade[1:2,3:24]))), dim(tempmanthclade))
minmanthspecies1 <- tempmanthclade[minmanthdistanceloc[1,1],2]
minmanthspecies2 <- tempclade[minmanthdistanceloc[1,2],2]

maxmutation <- maxmanthdistance/(2*91)
medmutation <- medmanthdistance/(2*91)
minmutation <- minmanthdistance/(2*91)            

minage <- maxcladedistance/maxmutation/2
medage <- maxcladedistance/medmutation/2
maxage <- maxcladedistance/minmutation/2 
}

tempout <- c(lizardmatrix[j,1],maxcladespecies1,maxcladespecies2,maxcladedistance,maxmanthspecies1,maxmanthspecies2,maxmanthdistance,medmanthdistance,minmanthspecies1,minmanthspecies2,minmanthdistance,minage,medage,maxage)
out <- rbind(out,tempout)

# counting up 24 to move on to the next locus
j <- j + 24
}

write.table(out, "Agamid_clade_age.csv", quote=FALSE, sep = ",", col.names=FALSE, row.names=FALSE)

rm(list=ls())

# Quitting R
q()

#lizardmatrix[j:(j+23),]
