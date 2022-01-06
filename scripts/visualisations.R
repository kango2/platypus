library(tidyverse)
library(karyoploteR)

chrinfo <- read_delim("Downloads/platypuschr.txt", delim = "\t")
relernn <- read_delim("Downloads/recombrate.relernn.txt", delim = "\t")
colnames(relernn)[1] <- "chracc"

chrorder <- c(paste("chr",1:21,sep = ""), paste("chrX",1:5,sep = ""))

platypus.genome <- toGRanges(data.frame(chr=chrinfo$chrname, start=1, end=chrinfo$chrsize))

relernn <- left_join(relernn, chrinfo) 

##recombination rate across the genome
for (i in chrorder) {
  pdf(paste("Downloads/",i,".pdf",sep = ""))
  kp <- plotKaryotype(genome = platypus.genome, chromosomes = i, main = i)
  kpAddBaseNumbers(kp, tick.dist = 5e6)
  kpLines(kp, chr=relernn$chrname, x=relernn$start,y = relernn$recombRate, ymin = 0, ymax = 4.244619e-09, r1 = 0.8, lwd = 0.5)
  kpAxis(kp, ymin=0, ymax = 4.244619e-09, labels = c(0,format.pval(4.244619e-09/2, digits = 2),format.pval(4.244619e-09, digits = 2)), r1=0.8, cex=0.8)
  dev.off()
}

kp <- plotKaryotype(genome = platypus.genome, chromosomes = chrorder, main = "Recombination rate across platypus genome")
kpAddBaseNumbers(kp, tick.dist = 5e6)
kpLines(kp, chr=relernn$chrname, x=relernn$start,y = relernn$recombRate, ymin = 0, ymax = 4.244619e-09, r1 = 0.8, lwd = 0.5)
kpAxis(kp, ymin=0, ymax = 4.244619e-09, labels = c(0,format.pval(4.244619e-09/2, digits = 2),format.pval(4.244619e-09, digits = 2)), r1 = 0.8, cex = 0.4)

#%>% ggplot(aes(x=start,y=recombRate)) + geom_line() + facet_wrap(~chrname, ncol=1)

##number of sites
kp <- plotKaryotype(genome = platypus.genome, chromosomes = chrorder, main = "nSites for Platypus genome")
kpAddBaseNumbers(kp, tick.dist = 5e6)
kpLines(kp, chr=relernn$chrname, x=relernn$start, y = relernn$nSites, ymin = 0, ymax = max(relernn$nSites))

