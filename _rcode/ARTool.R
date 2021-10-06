#!/usr/bin/env Rscript
fn <- commandArgs(trailingOnly = TRUE)
cat(fn, sep = "\n")

library(ARTool)
library(matlab)
library(dplyr)

# load the data
# fn <- "/Users/chris/chris-lab/projects/gain_opto/_stats/gain_SOM.csv"
df <- read.csv(fn)
df$contrast <- as.factor(df$contrast)
df$led <- as.factor(df$led)

# aligned rank transform plus ANOVA
m <- art(gain ~ contrast * led + (1|neuron),data=df)
a <- anova(m)

# save anova output for matlab
fp <- fileparts(fn)
fout <- paste(paste(fp[1],fp[2],sep="/"),"_anova.csv",sep="")
capture.output(a,file = fout)

# save pvalues
fout <- paste(paste(fp[1],fp[2],sep="/"),"_pv.csv",sep="")
capture.output(a$`Pr(>F)`,file = fout)

# save post-hoc output
fout <- paste(paste(fp[1],fp[2],sep="/"),"_posthoc.csv",sep="")
a <- art.con(m, "contrast:led", adjust="holm") %>%  # run ART-C for X1 × X2
     summary() %>%  # add significance stars to the output
     mutate(sig. = symnum(p.value, corr=FALSE, na=FALSE,
                       cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                       symbols = c("***", "**", "*", ".", " ")))
capture.output(a,file = fout)
