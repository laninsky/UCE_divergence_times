# importing our giant outfile and converting it to a matrix so we can do things to it
in_table <- read.table("combined.outfile", header=FALSE, stringsAsFactors=FALSE)
distmatrix <- as.matrix(in_table[1:(dim(in_table)[1]),1:dim(in_table)[2]])
distmatrix <- sub("\\*",0, distmatrix)
rm(in_table)

# Calculating the max length of the matrix so that we can feed it into the while loop below
maxlength <- dim(distmatrix)[1]
maxwidth <-  dim(distmatrix)[2] - 2
names <- t(as.matrix(distmatrix[1:maxwidth,2]))
names <- cbind("locus","sp1",names)
distmatrix <- rbind(names,distmatrix)

#Getting outgroup names
intable <- readLines("UCE_divergence.settings")
nosettings <- length(intable)
outgroups <- intable[5:nosettings]
outgroups <- outgroups[outgroups != ""]

rm(nosettings)

#Creating output file
outputlength <- length(unique(distmatrix[,1]))
out <- c("locusname","maxingroupspecies1","maxingrouppecies2","maxingroupdistance","minoutgroupspecies","mininoutgroupcompspecies2","minoutgroupdistance","age")
output <- matrix("missing", nrow=outputlength,ncol=8)
output <- rbind(out,output)

rm(out)
rm(maxwidth)

newdistmatrix <- NULL
for (m in 1:(maxwidth+2)) {
if (!(distmatrix[1,m] %in% outgroups)) {
newdistmatrix <- cbind(newdistmatrix,distmatrix[,m])
}
}

rm(distmatrix)

#Taking our input distances and writing things out to the outfile
i <- 2
j <- 2
while (j <= maxlength) {
k <- j + 1
while (newdistmatrix[j,1]==newdistmatrix[k,1]) {
k <- k + 1
}
tempmatrix <- newdistmatrix[j:k,]
tempingroupmatrix <- NULL
tempoutgroupmatrix <- NULL
for (m in 1:maxwidth) {
if (!(tempmatrix[m,2] %in% outgroups)) {
tempingroupmatrix <- rbind(tempingroupmatrix,tempmatrix[m,])
} else {
tempoutgroupmatrix <- rbind(tempoutgroupmatrix,tempmatrix[m,])
}
}

output[i,1] <- tempmatrix[1,1]
output[i,4] <- max(as.numeric(tempingroupmatrix[,3:(dim(tempingroupmatrix)[2])]))
maxcladedistanceloc <-  arrayInd(which.max(as.numeric(tempingroupmatrix[,3:(dim(tempingroupmatrix)[2])])), dim(tempingroupmatrix))
output[i,2] <- tempingroupmatrix[maxcladedistanceloc[1,1],2]
output[i,3] <- tempingroupmatrix[maxcladedistanceloc[1,2],2]
output[i,7] <- min(as.numeric(tempoutgroupmatrix[,3:(dim(tempoutgroupmatrix)[2])])[as.numeric(tempoutgroupmatrix[,3:(dim(tempoutgroupmatrix)[2])])>0])


# creating a matrix with mantheyus to calculate the min/max divergence between them and the other critters
tempmanthclade1 <- distmatrix[(j+15):(j+16),1:17]
tempmanthclade2 <- distmatrix[(j+15):(j+16),20:26]
tempmanthclade <- cbind(tempmanthclade1, tempmanthclade2)
maxmanthdistance <- max(as.numeric(tempmanthclade[1:2,3:24]))

minage <- maxcladedistance/maxmutation/2
medage <- maxcladedistance/medmutation/2
maxage <- maxcladedistance/minmutation/2 
}

tempout <- c(distmatrix[j,1],maxcladespecies1,maxcladespecies2,maxcladedistance,maxmanthspecies1,maxmanthspecies2,maxmanthdistance,medmanthdistance,minmanthspecies1,minmanthspecies2,minmanthdistance,minage,medage,maxage)
out <- rbind(out,tempout)

# counting up 24 to move on to the next locus
j <- j + 24
}

write.table(out, "Agamid_clade_age.csv", quote=FALSE, sep = ",", col.names=FALSE, row.names=FALSE)

rm(list=ls())

# Quitting R
q()

#lizardmatrix[j:(j+23),]
