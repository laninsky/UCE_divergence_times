intable <- read.table("temp",header=FALSE,stringsAsFactors=FALSE,sep="\t")
species <- read.table("species_assignments",header=FALSE,stringsAsFactors=FALSE)

rows <- dim(intable)[1]

uncertains <- species[species[,2]=="uncertain",1]
no_uncertains <- length(uncertains)

to_write <- NULL
sequencepaste <- NULL
tempname <- NULL

for (j in 1:rows) {
if ((length(grep(">",intable[j,1])))>0) {
if(!(is.null(sequencepaste))) {
to_write <- rbind(to_write,tempname)
to_write <- rbind(to_write,sequencepaste)
}
tempname <- intable[j,1]
sequencepaste <- NULL
} else {
sequencepaste <- paste(sequencepaste,intable[j,1],sep="")
}
}

to_write <- rbind(to_write,tempname)
to_write <- rbind(to_write,sequencepaste)
} 

if ((length(grep(">",to_write[1,1])))==0) {
to_write <- rbind(intable[1,1],to_write)
}

rows <- dim(to_write)[1]
to_write_unc <- NULL

j <- 1

while (j < rows) {
if(!(any(uncertains %in% (gsub(">","",to_write[j,1]))))) {
to_write_unc <- rbind(to_write_unc,to_write[j,1])
to_write_unc <- rbind(to_write_unc,to_write[j+1,1])
}
j <- j+2
}

write.table(to_write_unc, "temp.fa",quote=FALSE, col.names=FALSE,row.names=FALSE)

q()
