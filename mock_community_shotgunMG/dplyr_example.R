library(data.table)
library(dplyr)

options(stringsAsFactors = FALSE)
setwd("~/Projects/mock_community_shotgunMG/")
abundance_file = "./export/genes/merged_gene_abundance_cpm.tsv"
annotations_file = "./export/annotations.tsv"
mapping_file = "./export/mapping_file.tsv"

# Load annotations
annotations = data.frame(fread(annotations_file, sep="\t", header=TRUE), check.names=FALSE)
# fread somehow messes the header. the next 3 lines are to correct that.
header = c("contig_id","gene_id","product_name","kegg_entry","kegg_definition","kegg_module","kegg_module_desc","kegg_pathway","kegg_pathway_desc","pfam_access","pfam_product_name","pfam_desc","tigrfam_access","tigrfam_name","tigrfam_product_name","tigrfam_desc","cog_access","cog_name","cog_function","cog_category","kog_access","kog_name","kog_function","kog_category","ublastp","ublastp_desc","tax_kingdom","tax_phylum","tax_class","tax_order","tax_family","tax_genus","tax_specie")
colnames(annotations) = header
annotations[,ncol(annotations)] = NULL
# Remove genes having no KEGG affiliations:
annotations = annotations[annotations$kegg_entry != "NULL",]

# Load abundance
abundance = data.frame(fread(abundance_file, header=TRUE, sep="\t"), check.names=FALSE)
row.names(abundance) = abundance$V1
abundance$V1 = NULL
# Then integrate the KEGG orthologs with abundance matrix. Here we could chose another gene functions, for instance, PFAM, COGs, etc.
abundance = merge(abundance, annotations[,c("gene_id", "kegg_entry")], by.x="row.names", by.y="gene_id")
row.names(abundance) = abundance$Row.names
abundance$Row.names = NULL # when merging by row.names a spurious Row.names variables is added...

# Then, the magic happens here with dplyr.
abundance_KO = abundance %>%
   group_by(kegg_entry) %>% # means that the following summarize function will be done by the kegg_entry variable.
      summarise_all(funs(sum)) %>%
         as.data.frame()

# then only keep interesting KOs
#K10954	zona occludens toxin	
#K11038	leukocidin/hemolysin
#K18862	small toxic polypeptide
#K11040	staphylococcal enterotoxin
selection = c("K10954", "K11038", "K18862", "K11040")
abundance_KO2 = abundance_KO[abundance_KO$kegg_entry %in% selection,]

# Then load mapping file
mapping = data.frame(fread(mapping_file, header=TRUE, sep="\t"), check.names=FALSE)

# Then the happy triad : melt-merge-ggplot
df = melt(abundance_KO2)
df = merge(df, mapping, by.x="variable", by.y="#SampleID")

vColors = c(
   "#0000CD", "#00FF00", "#FF0000", "#808080", "#000000", "#B22222", "#40E0D0", "#DAA520", "#DDA0DD", "#FF00FF","#00FFFF", "#4682B4", "#008000", "#E6E6FA", "#FF8C00", "#80008B", "#8FBC8F", "#00BFFF", "#FFFF00", "#808000", "#FFCCCC", "#FFE5CC", "#FFFFCC", "#E5FFCC", "#CCFFCC", "#CCFFE5", "#CCFFFF", "#CCE5FF", "#CCCCFF", "#E5CCFF", "#FFCCFF", "#FFCCE5", "#FFFFFF", "#990000", "#666600", "#006666","#330066","#A0A0A0","#99004C"
)


# ggplot : don't forget to update the fill and facets parameters.
p <- ggplot(data=df, aes(x=variable, y=value, fill=kegg_entry)) + 
   geom_bar(stat="identity", alpha=1, width=1) + 
   facet_grid(Treatment ~ Date, scales="free_x", space="free") +
   xlab("variable") + ylab("aggregated CPMs") +
   theme(
      panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=0.75),
      axis.text.x=element_text(size=7, colour="black", angle=as.numeric(90), hjust=1),
      axis.text.y=element_text(size=7, colour="black"), 
      axis.title=element_text(family="Helvetica", size=14),
      plot.title = element_text(lineheight=1.2, face="bold", size=16),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      legend.key.size = unit(0.35, "cm"),
      legend.text = element_text(size=12, face="bold"),
      legend.title = element_text(size=12, face="bold"),
      legend.spacing = unit(1, "cm"),
      legend.position="left",
      strip.text.x = element_text(angle=90, vjust=0, size=9, face="bold"),
      strip.text.y = element_text(angle=0, hjust=0, size=9, face="bold"),
      strip.background =  element_blank(),
      panel.spacing = unit(0.3, "lines")
   )  + scale_fill_manual(values=(vColors)) #+ coord_cartesian(xlim = c(-6, 6)) # + scale_fill_gradientn(colors=colors) 
print(p)

## Now say we want to integrate the taxonomy to the Kegg annotations.
## Lets start again with some modifications.
# Load abundance
abundance = data.frame(fread(abundance_file, header=TRUE, sep="\t"), check.names=FALSE)
row.names(abundance) = abundance$V1
abundance$V1 = NULL
# Then integrate the KEGG orthologs with abundance matrix. Here we could chose another gene functions, for instance, PFAM, COGs, etc.
abundance = merge(abundance, annotations[,c("gene_id", "kegg_entry", "tax_family")], by.x="row.names", by.y="gene_id")
row.names(abundance) = abundance$Row.names
abundance$Row.names = NULL # when merging by row.names a spurious Row.names variables is added...

# Then, the magic happens here with dplyr.
abundance_KO = abundance %>%
   group_by(kegg_entry, tax_family) %>% # means that the following summarize function will be done by the kegg_entry variable.
   summarise_all(funs(sum)) %>%
   as.data.frame()

# Look at the df:
head(abundance_KO)
# then only keep interesting KOs
selection = c("K10954", "K11038", "K18862", "K11040")
abundance_KO2 = abundance_KO[abundance_KO$kegg_entry %in% selection,]
head(abundance_KO2)
# Then load mapping file
mapping = data.frame(fread(mapping_file, header=TRUE, sep="\t"), check.names=FALSE)

# Then the happy triad : melt-merge-ggplot
df = melt(abundance_KO2)
df = merge(df, mapping, by.x="variable", by.y="#SampleID")

vColors = c(
   "#0000CD", "#00FF00", "#FF0000", "#808080", "#000000", "#B22222", "#40E0D0", "#DAA520", "#DDA0DD", "#FF00FF","#00FFFF", "#4682B4", "#008000", "#E6E6FA", "#FF8C00", "#80008B", "#8FBC8F", "#00BFFF", "#FFFF00", "#808000", "#FFCCCC", "#FFE5CC", "#FFFFCC", "#E5FFCC", "#CCFFCC", "#CCFFE5", "#CCFFFF", "#CCE5FF", "#CCCCFF", "#E5CCFF", "#FFCCFF", "#FFCCE5", "#FFFFFF", "#990000", "#666600", "#006666","#330066","#A0A0A0","#99004C"
)

#unique(df$TimePoint)
#df$TimePoint = factor(df$TimePoint, levels=c("Day.2", "Day.8", "Day.64"))

# ggplot : don't forget to update the fill and facets parameters.
p <- ggplot(data=df, aes(x=variable, y=value, fill=kegg_entry)) + 
   geom_bar(stat="identity", alpha=1, width=1) + 
   facet_grid(Treatment ~ tax_family, scales="free_x", space="free") +
   xlab("variable") + ylab("aggregated CPMs") +
   theme(
      panel.border=element_rect(fill=NA, linetype="solid", colour = "black", size=0.75),
      axis.text.x=element_text(size=7, colour="black", angle=as.numeric(90), hjust=1),
      axis.text.y=element_text(size=7, colour="black"), 
      axis.title=element_text(family="Helvetica", size=14),
      plot.title = element_text(lineheight=1.2, face="bold", size=16),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      legend.key.size = unit(0.35, "cm"),
      legend.text = element_text(size=12, face="bold"),
      legend.title = element_text(size=12, face="bold"),
      legend.spacing = unit(1, "cm"),
      legend.position="left",
      strip.text.x = element_text(angle=90, vjust=1,hjust=0, size=9, face="bold"),
      strip.text.y = element_text(angle=0, hjust=0, size=9, face="bold"),
      strip.background =  element_blank(),
      panel.spacing = unit(0.3, "lines")
   )  + scale_fill_manual(values=(vColors)) #+ coord_cartesian(xlim = c(-6, 6)) # + scale_fill_gradientn(colors=colors) 
print(p)

## You could also visualize this as a heatmap.
library(pheatmap)

df2 = abundance_KO2
row.names(df2) = paste0(df2$kegg_entry, "-", df2$tax_family)
mapping_rows = data.frame(row.names=paste0(df2$kegg_entry, "-", df2$tax_family), tax_family=df2$tax_family)
df2$kegg_entry = NULL
df2$tax_family = NULL
head(df2)

# transform in log2 to increase contrast
df2 = log2(df2 + 1)

# Prepare metadata
row.names(mapping) = mapping$`#SampleID`
mapping$`#SampleID` = NULL
mapping2 = mapping[, c("Treatment", "Date"), drop=FALSE]
x = 1
curr_list = list()
for(j in 1:ncol(mapping2)){
   curr_col_name = names(mapping2)[j]
   curr_var_names = unique(mapping2[,j])
   curr_colors = vColors[x:(x+(length(curr_var_names)-1))]
   names(curr_colors) = curr_var_names
   x = length(curr_var_names) + 1 + x
   curr_list[[curr_col_name]] = curr_colors
}
print(curr_list)

pheatmap(
   main="Selected KOs aggregated CPM abundance (log2)", fontsize=7,
   df2, 
   #file="./example_heatmap.pdf",
   fontsize_row=9, 
   fontsize_col=3, 
   cellwidth=5,  
   cellheight=10,
   annotation=mapping2,
   annotation_row=mapping_rows,
   annotation_colors=curr_list,
   color=colorRampPalette(c("#2C397F", "#46B2E5", "#9FCE63", "#F0E921", "#EE3128", "#552E31"))(100),
   clustering_method="average"
)
