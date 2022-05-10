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




tmp <- list()

x <- read_delim("Downloads/PlatypusWGS.20unrelatedfemalesamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.PREDICT.BSCORRECTED.txt", delim="\t")
x$stype <- "females"
tmp[[1]] <- x
x <- read_delim("Downloads/PlatypusWGS.44unrelatedsamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.PREDICT.BSCORRECTED.txt", delim="\t")
x$stype <- "all"
tmp[[2]] <- x
x <- read_delim("Downloads/PlatypusWGS.27unrelatedmalesamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.PREDICT.BSCORRECTED.txt", delim="\t")
x$stype <- "males"
tmp[[3]] <- x

tmp <- bind_rows(tmp)
cname <- data.frame(chrom = pull(x, chrom) %>% unique(), cname = paste("chr", c(1:21), sep = ""))
tmp <- left_join(tmp,cname)
c <- unique(tmp$cname)

tmp %>% ggplot(aes(x=start, y=recombRate, color = stype)) + 
  geom_point(alpha=0.5,size=0.6) + 
  facet_wrap(~factor(cname, levels=c), ncol=2) + 
  theme_bw() +
  theme(legend.text = element_text(size=20)) + 
  xlab("Position") + ylab("crossovers / base")


for (i in 1:length(c)) {
  pdf(paste("Downloads/",c[i],".pdf",sep = ""), width = 10, height = 3)
  g <- filter(tmp, cname == c[i]) %>% 
    ggplot(aes(x=start, y=recombRate, color = stype)) + 
    geom_point(alpha = 0.5)
  print(g)
  dev.off()
}






