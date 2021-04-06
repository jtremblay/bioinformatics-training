library(data.table)
library(ggplot2)

# First, untar the tarball: tar -xvf export.tar.gz. The files in the archive are
# described in the shotgun MG SOP document. 
# First we want to load the pcoa coordinates file into R. (Bray-curtis)
setwd("~/projects/mock_community_shotgunMG/")
coords_file = "./export/beta_div/bray_curtis_contig_abundance/bray_curtis_contig_abundance_coords.tsv"

# Here loading the pcoa file is a little bit more tricky, because the file itself
# does contain multiple rows representing perc.variation + eigen values and finally
# the pcoa coordinates themselves. (have a look with excel or a text editor.)
# Directly read into table before anything else.
curr_file = file(coords_file)
open(curr_file)
percentVar = read.table(coords_file, skip=4, nrow=1)
percent1 = percentVar[[1]] * 100 
percent2 = percentVar[[2]] * 100 
percent1 = formatC(round(percent1, 2), big.mark=",",drop0trailing=TRUE, format="f")
percent2 = formatC(round(percent2, 2), big.mark=",",drop0trailing=TRUE, format="f")
close(curr_file)

# Then read the coordinates :
curr_file = file(coords_file)
open(curr_file)
# Read starting from beginning of coordinates, fill last rows with NAs
tData = read.table(curr_file, skip=9, fill=TRUE)
# Then remove NAs
tData = na.omit(tData)
# Keep 3 first rows only.
# Force data as numeric (just in case). We never know.
tData2 = tData[,1:4]
for(i in 2:ncol(tData2)){
  tData2[,i] = as.numeric(tData2[,i]) 
}   
tData3 = tData2

colnames(tData3) = c("variable", "D1", "D2", "D3")
close(curr_file)

# Now we do have the coordinates in tData3.
head(tData3)

vColors = c(
  "#0000CD", "#00FF00", "#FF0000", "#808080", "#000000", "#B22222", "#DAA520", 
  "#DDA0DD", "#FF00FF", "#00FFFF", "#4682B4", "#E6E6FA", "#FF8C00", "#80008B", 
  "#8FBC8F", "#00BFFF", "#FFFF00", "#808000", "#FFCCCC", "#FFE5CC", "#FFFFCC", "#E5FFCC", 
  "#CCFFCC", "#CCFFE5", "#CCFFFF", "#CCE5FF", "#CCCCFF", "#E5CCFF", "#FFCCFF", "#FFCCE5", 
  "#FFFFFF", "#990000", "#666600", "#006666", "#330066", "#A0A0A0", "#99004C"
)

# Here you can first do a pcoa figure with the colors defined above:
# ggplot typcial syntax:
# You can play with the fonts sizes 

# But first, merge tData3 with mapping file
# to associate metadata to each sample in the df data frame. So first, load mapping file:
mapping_file = "./export/mapping_file.tsv"
mapping = data.frame(fread(mapping_file, sep="\t"), check.names=FALSE)
tData3 = merge(tData3, mapping, by.x="variable", by.y="#SampleID")
# Convert tData3$SamplingDate to chr, because it will complain downstream...
tData3$Date = as.character(tData3$Date)

p <- ggplot(data=tData3, aes(x=D1, y=D2, color=Treatment, shape=Date)) +
  geom_point(size=5) + #geom_point(colour="grey90", size = 1.5) +
  #facet_wrap(~Type) + 
  theme(
    panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=1),
    axis.text.x=element_text(size=12, colour="black"),
    axis.text.y=element_text(size=12, colour="black"),
    axis.title=element_text(size=16),
    axis.ticks.length=unit(0.2,"cm"),
    axis.ticks = element_line(colour = 'black', size = 0.5),
    panel.grid.minor=element_blank(),
    panel.background=element_blank(),
    legend.key.size = unit(0.45, "cm"),
    legend.margin = unit(1, "cm"),
    strip.background =  element_blank(),
    strip.text.x = element_text(size=12, face="bold")
  ) + scale_colour_manual(values=vColors, name="Enclosure") +
  #scale_shape_manual(values=shapeList, name="Type/Sex") +
  geom_hline(aes(yintercept=0), size=0.2) +
  xlab(paste0("PCo1 (", percent1,"%)")) +
  ylab(paste0("PCo2 (", percent2,"%)"))

print(p)

# If you want to explicitly define shapes and colors:

colorList = c(    
                  "Even"        = "#DAA520",
                  "Staggered"    = "#DDA0DD"
                 
                  )
# See available shapes: http://sape.inf.usi.ch/quick-reference/ggplot2/shape
shapeList = c("11-sept-2021" = 2,
              "12-sept-2021" = 1,
              "13-sept-2021" = 17) 

# Then redo the figure with specified shapes and colors:
p <- ggplot(data=tData3, aes(x=D1, y=D2, color=Treatment, shape=Date)) +
  geom_point(size=5) + #geom_point(colour="grey90", size = 1.5) +
  #facet_wrap(~Type) + 
  theme(
    panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=1),
    axis.text.x=element_text(size=12, colour="black"),
    axis.text.y=element_text(size=12, colour="black"),
    axis.title=element_text(size=16),
    axis.ticks.length=unit(0.2,"cm"),
    axis.ticks = element_line(colour = 'black', size = 0.5),
    panel.grid.minor=element_blank(),
    panel.background=element_blank(),
    legend.key.size = unit(0.45, "cm"),
    legend.margin = unit(1, "cm"),
    strip.background =  element_blank(),
    strip.text.x = element_text(size=12, face="bold")
  ) + scale_colour_manual(values=colorList, name="Enclosure") +
  scale_shape_manual(values=shapeList, name="Type/Sex") +
  geom_hline(aes(yintercept=0), size=0.2) +
  xlab(paste0("PCo1 (", percent1,"%)")) +
  ylab(paste0("PCo2 (", percent2,"%)"))

print(p)

# If you want to print to a file:
# You can adjust dimensions to your needs.
pdf( file="./pcoa_figure_1.pdf", height=4.5, width=6)
print(p)
dev.off()
  

