library(data.table)
library(ggplot2)
library(reshape2)

# First, untar the tarball: tar -xvf ELAflo2019_16S.tar.gz. The files in the archive are
# described in the 16S SOP document. 
# First we want to load the alpha diversity (observed_species - which is really observed ASVs) and make a figure using 
# the data found in this file.
# You can also run the same script on shannon, chao1 and simpson indexes. 
setwd("~/projects/mock_community_shotgunMG/")
alphadiv_file = "./export/alpha_div/contig_abundance/alpha_richness.tsv"
alphadiv = data.frame(fread(alphadiv_file, sep="\t", fill=TRUE, header=TRUE), check.names=FALSE)

#Here we will modify the original df a little bit to only keep values of interest. reads depth at 551782 reads.
alphadiv = alphadiv[,colnames(alphadiv) %in% c("depth", "551782")]
# remove spurious row
alphadiv = alphadiv[-1,]
row.names(alphadiv) = alphadiv[,1]
alphadiv$depth = NULL

# look at the matrix:
alphadiv

# Generate average of the 10 iterations for each column (sample)
alphadiv2 = data.frame(rowMeans(alphadiv[,1:ncol(alphadiv)]), check.names=FALSE)
colnames(alphadiv2)[1] = "Observed_Contigs"

# Then merge with mapping file:
mapping_file = "./export/mapping_file.tsv"
mapping = data.frame(fread(mapping_file, sep="\t"), check.names=FALSE)
df = merge(alphadiv2, mapping, by.x="row.names", by.y="#SampleID")
colnames(df)[1] = "SampleID"

# Then we create boxplots:
p <- ggplot(data=df, aes(x=as.character("Enclosure", fill="red"), y=Observed_Contigs)) + 
  facet_grid(Treatment ~ Date, scales="free_x", space="free_x") +
  geom_boxplot(outlier.colour=NA, outlier.shape=3, notch=FALSE, color="black") + 
  geom_jitter(aes(color="red"), position=position_jitterdodge(0.3), size=0.5, alpha=1) +
  xlab("Treatment") +
  theme(
    text=element_text(family="Helvetica"),
    panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=0.5),
    axis.text.x=element_blank(),
    axis.text.y=element_text(size=10, colour="black"), 
    axis.title=element_text(family="Helvetica", size=(10)),
    plot.title = element_text(lineheight=1.2, face="bold", size=18),
    panel.grid.major=element_blank(),
    panel.grid.minor=element_blank(),
    panel.background=element_blank(),
    legend.key.size = unit(0.45, "cm"),
    legend.text = element_text(size=9, face="bold"),
    legend.title = element_text(size=11, face="bold"),
    legend.spacing = unit(1, "cm"),
    legend.position="no",
    strip.text.x = element_text(angle=90, hjust=0, vjust=0.5, size=10, face="bold"),
    strip.text.y = element_text(angle=0, hjust=0, size=10, face="bold"),
    strip.background =  element_blank()
  ) + scale_y_continuous()
print(p)

# boxplots are not relevant for only 1 obs per boxplot. Lets try something else.
p <- ggplot(data=df, aes(x=as.character("Enclosure", fill="red"), y=Observed_Contigs)) + 
  facet_grid(. ~ Treatment, scales="free_x", space="free_x") +
  geom_boxplot(outlier.colour=NA, outlier.shape=3, notch=FALSE, color="black") + 
  geom_jitter(aes(color="red"), position=position_jitterdodge(0.3), size=0.5, alpha=1) +
  xlab("Treatment") +
  theme(
    text=element_text(family="Helvetica"),
    panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=0.5),
    axis.text.x=element_blank(),
    axis.text.y=element_text(size=10, colour="black"), 
    axis.title=element_text(family="Helvetica", size=(10)),
    plot.title = element_text(lineheight=1.2, face="bold", size=18),
    panel.grid.major=element_blank(),
    panel.grid.minor=element_blank(),
    panel.background=element_blank(),
    legend.key.size = unit(0.45, "cm"),
    legend.text = element_text(size=9, face="bold"),
    legend.title = element_text(size=11, face="bold"),
    legend.spacing = unit(1, "cm"),
    legend.position="no",
    strip.text.x = element_text(angle=90, hjust=0, vjust=0.5, size=10, face="bold"),
    strip.text.y = element_text(angle=0, hjust=0, size=10, face="bold"),
    strip.background =  element_blank()
  ) + scale_y_continuous()
print(p)
# In this current project, we see that the diversity is quite high, with an estimated 400-ish observed ASVs in most of the samples.
