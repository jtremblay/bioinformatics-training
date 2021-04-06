library(data.table)
library(ggplot2)
library(reshape2)

# First, untar the tarball: tar -xvf export.tar.gz. The files in the archive are
# described in the shotgun SMG SOP document. 
# First we want to load the taxonomic profiles at the genus level and make a figure using 
# the data found in this file.
setwd("~/projects/mock_community_shotgunMG/")
taxonomy_file = "./export/consensus/feature_table_bacteriaArchaea_L6.tsv"
tax_L6 = data.frame(fread(taxonomy_file, sep="\t"), check.names=FALSE)

# This table contains the taxonomic summary computed from the ASV table that was consensus rarefied at 1000 reads (see AmpliconTagger paper for details)
head(tax_L6)
colSums(tax_L6[,2:ncol(tax_L6)])

# Before going forward, we will be going to keep only the 20 most abundant taxonomic lineages. The reason for this 
# is that after 20 different colors, it becomes difficult to distinguish colors on a figure.
# First we add column to our data frame that contains the sum of each row (taxonomic lineage)
tax_L6a = cbind(tax_L6, (rowSums(tax_L6[2:(ncol(tax_L6))]))/ncol(tax_L6) )
# Then we order that column bu descending order (to have the most abundant taxonomic lineage in the first rows of the table.)
tax_L6a = tax_L6a[order(-tax_L6a[, ncol(tax_L6a)]),]
# Then we remove that column that we used to order the data frame.
tax_L6a[,ncol(tax_L6a)] = NULL
# Then we select the first 20 most abundant taxa:
tax_L6a = tax_L6a[1:20,]

# In the next lines, we want to transform the data frame, so it is compatible with ggplot.
df = melt(tax_L6a)

# We then want to associate metadata to each sample in the df data frame. So first, load mapping file:
mapping_file = "./export/mapping_file.tsv"
mapping = data.frame(fread(mapping_file, sep="\t"), check.names=FALSE)
# look at the mapping file:
head(mapping)

# Then merge df with mapping .
df2 = merge(df, mapping, by.x="variable", by.y="#SampleID")

# We now have a df2 data frame ready to be used in ggplot. 
# See http://www.cookbook-r.com/Graphs/
# Also this df2 data frame can be subsetted to only keep samples matching certain 
# variables. For instance, you could select samples coming from specific sampling dates.

# Also create a vector of custom colors.
vColors = c(
  "#0000CD", "#00FF00", "#FF0000", "#808080", "#000000", "#B22222", "#DAA520", 
  "#DDA0DD", "#FF00FF", "#00FFFF", "#4682B4", "#E6E6FA", "#FF8C00", "#80008B", 
  "#8FBC8F", "#00BFFF", "#FFFF00", "#808000", "#FFCCCC", "#FFE5CC", "#FFFFCC", "#E5FFCC", 
  "#CCFFCC", "#CCFFE5", "#CCFFFF", "#CCE5FF", "#CCCCFF", "#E5CCFF", "#FFCCFF", "#FFCCE5", 
  "#FFFFFF", "#990000", "#666600", "#006666", "#330066", "#A0A0A0", "#99004C"
)

# Then the ggplot typcial syntax:
# You can play with the fonts sizes 
p <- ggplot(data=df2, aes(x=variable, y=value, fill=Taxon)) + 
  geom_bar(stat="identity") + geom_bar(colour="black", size=0, stat="identity", show.legend=FALSE) + 
  xlab("") + 
  ylab("Abundance") +
  # I encourage you to read on the facet_grid() and facet_wrap functions as 
  # they are powerful functions to sub-panel your figures.
  # Here we only have one variable in the mapping file, but in a real-life situation, we will have more.
  #               Y    ~     X
  facet_grid(Date ~ Treatment, scales="free_x", space="free_x") +
  theme(
    text=element_text(family="Helvetica"),
    panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=0.5),
    axis.text.x=element_blank(),
    axis.text.y=element_text(size=10, colour="black"), 
    axis.title=element_text(family="Helvetica", size=10),
    plot.title = element_text(lineheight=1.2, face="bold", size=12),
    panel.grid.major=element_blank(),
    panel.grid.minor=element_blank(),
    panel.background=element_blank(),
    legend.key.size = unit(0.45, "cm"),
    legend.text = element_text(size=9, face="bold"),
    legend.title = element_text(size=9, face="bold"),
    legend.spacing = unit(1, "cm"),
    legend.position="right",
    strip.text.x = element_text(angle=90, hjust=0, vjust=0.5, size=11, face="bold"),
    strip.text.y = element_text(angle=0, hjust=1, size=11, face="bold"),
    strip.background =  element_blank()
  ) + scale_y_continuous() +
  scale_fill_manual(values=(vColors))
print(p)

# If you want to print to a file:
# You can adjust dimensions to your needs.
pdf( file="./taxonomic_figure_1.pdf", height=9, width=12)
print(p)
dev.off()

# There are ways to remove gaps in generated plots.

