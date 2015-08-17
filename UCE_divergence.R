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
