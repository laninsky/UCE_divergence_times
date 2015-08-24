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
outputlength <- length(unique(distmatrix[,1]))-1
out <- c("locusname","maxingroupspecies1","maxingrouppecies2","maxingroupdistance","minoutgroupspecies","mininoutgroupcompspecies2","minoutgroupdistance","age")
output <- matrix("missing", nrow=outputlength,ncol=8)
output <- rbind(out,output)

rm(out)

newdistmatrix <- NULL
for (m in 1:(maxwidth+2)) {
if (!(distmatrix[1,m] %in% outgroups)) {
newdistmatrix <- cbind(newdistmatrix,distmatrix[,m])
}
}

calibration <- as.numeric(intable[4])

rm(distmatrix)
rm(intable)

#Taking our input distances and writing things out to the outfile
i <- 2
j <- 2
while (j <= maxlength) {
k <- j + 1
while ((k <= maxlength) && (newdistmatrix[j,1]==newdistmatrix[k,1])) {
k <- k + 1
}

if(k==maxlength+1) {
k <- maxlength + 2
}

tempmatrix <- newdistmatrix[j:(k-1),]
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
output[i,7] <- suppressWarnings(min(as.numeric(tempoutgroupmatrix[,3:(dim(tempoutgroupmatrix)[2])])[as.numeric(tempoutgroupmatrix[,3:(dim(tempoutgroupmatrix)[2])])>0]))

if(!(output[i,7]=="Inf")) {
maxoutgrouploc <- arrayInd(which(as.numeric(tempoutgroupmatrix[,3:(dim(tempoutgroupmatrix)[2])])==output[i,7]),dim(tempoutgroupmatrix))
output[i,5] <- tempoutgroupmatrix[maxoutgrouploc[1,1],2]
output[i,6] <- tempingroupmatrix[maxoutgrouploc[1,2],2]
output[i,8] <- calibration/as.numeric(output[i,7])*as.numeric(output[i,4])
}
i <- i + 1
j <- k
}

# Up to here - need to summarize the output

write.table(out, "UCE_clade_age.csv", quote=FALSE, sep = ",", col.names=FALSE, row.names=FALSE)

# Quitting R
q()
