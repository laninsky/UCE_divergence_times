library(stringr)
renamefile <- readLines("renamefile")
input <- readLines(renamefile)
norows <- length(input)
names <- NULL
x <- 0

for (i in 2:length(input)) {
if (input[i-1]=="matrix") {
x <- 1
}
if (input[i]=="") {
break
}
if (input[i]==";") {
break
}
if (x==1) {
names <- rbind(names,input[i])
}
}

norows <- length(names)
output <- matrix(nrow=norows,ncol=4)

for (i in 1:norows) {
output[i,1] <- unlist(strsplit(names[i,1]," "))[1]
output[i,2] <- paste(substr(output[i,1],1,5),"_",i,sep="")
output[i,3] <- paste("sed -i 's/",output[i,1],"/",output[i,2],"/' $f;",sep="")
output[i,4] <- paste("sed -i 's/",output[i,2],"/",output[i,1],"/' $f;",sep="")
}

script1 <- as.matrix(output[,3])
script1 <- rbind("for f in `ls *.nex`; do",script1,"done")

script2 <- as.matrix(output[,4])
script2 <- rbind("for f in `ls *.outfile`; do",script2,"done")

write.table(script1,"shortnames.sh",quote=FALSE, row.names=FALSE,col.names=FALSE)
write.table(script2,"lengthennames.sh",quote=FALSE, row.names=FALSE,col.names=FALSE)
