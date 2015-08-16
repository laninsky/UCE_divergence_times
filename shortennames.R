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
if (x==1) {
names <- rbind(names,input[i])
}
}

norows <- length(names)
output <- matrix(nrow=norows,ncol=3)

for (i in 1:norows) {
output[i,1] <- unlist(strsplit(names[i,1]," "))[1]
output[i,2] <- paste(substr(output[i,1],1,5),"_",i,sep="")
output[i,3] <- paste("sed -i 's/",output[i,1],"/",output[i,2],"/' $f",sep="")
}

write.table(output[,3],"output",quote=FALSE, row.names=FALSE,col.names=FALSE)
write.table(output[,1:2],"shorten_names.txt",quote=FALSE, row.names=FALSE,col.names=FALSE)

