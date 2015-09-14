# UCE_divergence_times v 1.0.0
Given an outgroup among your UCE data, and a fossil calibration for the split between your outgroup and ingroup, this program estimates the MRCA of your ingroup based on sequence divergence. To roughly account for  rate variation among the taxa (and incomplete lineage sorting!), if the divergence between the ingroup species is greater than that between the outgroup/ingroup species, these loci are ditched i.e. only loci where "divergence between ingroup species" < "divergence between ingroup and outgroup species" are used, because these should be loci that are evolving in a more clock-like manner (which is what we are assuming by not explicitly accounting for rate variation between lineages/gene-tree and species-tree discordance, as this is a tree-free approach). Because of this, your ingroup and outgroup also need to be reciprocally monophyletic, and no additional out-outgroups should be included. See section below on removing unwanted sequences...

This program is designed to be run inside a folder that has a separate *.fasta or *.nex file for each of your UCE loci. Within that folder you should place your UCE_divergence.settings file (described below), UCE_divergence.sh, shortennames.R (the library stringr needs to have previously been installed as an R-dependency using install.packages("stringr")), and UCE_divergence.R. You can then execute UCE_divergence_times by bash UCE_divergence.sh.

#Setting up your UCE_divergence.settings file
First line:
Your UCE_divergence.settings file is just a simple text file with a different option on each line. The first of these is whether your data is *.fasta or *.nexus. If it is *.nexus, is the extension *.nexus or *.nex (some of the programs care about the specific extension name)? First line = fasta, nexus or nex e.g.
```
nexus
```

Second line:
Your next option is which program you would rather use to estimate the pairwise divergences between your UCE loci: fastphylo or paup. 
-- fastphylo has a correction for saturation of sequences which paup doesn't have, which can be specified by "F". I have tested a few values and 0.95 seems to give the best minimum clade age estimates. However, it is more limited in distance models than paup: (possible values=JC, K2P, TN93, HAMMING,K2P)
-- paup has a lot of options for distances. For the distance model itself you have JC, F81, TAJNEI, K2P, F84, HKY85, K3P, TAMNEI, GTR, ML, LOGDET, UPHOLT, NEILI. You can have RATES=EQUAL RATES=GAMMA. GAMMA rates not allowed with LOGDET. You can have SHAPE = real-value, PINVAR = real-value, and many more options as specified in paup (http://www.ucl.ac.uk/cecd/downloads/PAUP%20command%20reference%20manual.pdf)
```
nexus
fastphylo
```

If you select paup, make sure you have it installed and within your path. If you select fastphylo, make sure you have this installed and within your path. Additionally, if you are starting from *.nexus (or *.nex = same thing, different extension name) files, and want to use fastphylo, make sure you have seqmagick installed and in your path  (this is going to convert from the *.nexus to *.fasta files that fastphylo can deal with). You also need to make sure that the path to the seqmagick python libs are in your PYTHONPATH e.g.
PYTHONPATH="${PYTHONPATH}:/home/a499a400/bin/seqmagick/lib/python"
export PYTHONPATH

Third line:
Specifying the options that you want to use with whatever evolutionary distance program you have selected

Paup options example:
DISTANCE=NEILI RATES=GAMMA SHAPE=300 MISSDIST=IGNORE

fastphylo options example:
-D HAMMING -F 0.95

Note: I believe that the MISSDIST=IGNORE option in Paup is probably critical for this pipeline to run correctly if you have missing data.

```
nexus
fastphylo
-D HAMMING -F 0.95
```

Fourth line: 
Here you need your fossil calibration in whatever units you want the final estimate of TMRCA of your ingroup in.

```
nexus
fastphylo
-D HAMMING -F 0.95
85
```

Fifth line and onwards:
Here, you need to specify the outgroups that are present in your sequence (*.fasta, *.nexus) files. If you have multiple outgroups, each of these should go on a separate line e.g.
```
nexus
fastphylo
-D HAMMING -F 0.95
85
mantheyus_phuwanensis_fmnh255495b
mantheyus_phuwanensis_fmnh262580
```

#Removing unwanted sequences

If you've got multiple non-monophyletic outgroups, you'll need to jettison these for the program to run correctly. To do this, you'll need to run step 3) from https://github.com/laninsky/Phase_hybrid_from_next_gen/tree/master/post-processing

This code works on fasta files, so if you are coming from *.nex or *.nexus files you'll need to run the first two blocks of the following code before you can run the remove_uncertains.R code. For your species_assignments file (see link above for more detail), you don't need to worry about designating any species as 'hybrid' for our application here, but do make sure the sequences you want to get rid of are labelled as uncertain.

```
if [ "$filetype" = "nexus" ]; then
for f in `ls *.nexus`; do 
newname=`echo $f | sed "1s/.nexus//"`
mv $newname.nexus $newname.nex
done
fi

if [ "$filetype" != "fasta" ]; then
for f in `ls *.nex*`; do 
newname=`echo $f | sed "1s/.nex//"`
seqmagick convert --alphabet dna-ambiguous $newname.nex $newname.fasta
done
fi

unset i
for i in `ls *.fasta`;
do mv $i temp;
Rscript remove_uncertains.R
mv temp.fa $i;
rm -rf temp;
done;
```

Once you have done this, your sequences are now in *.fasta format, so make sure you change the first line in your UCE_divergence.settings file to reflect this before attempting to run the UCE_divergence_times pipeline.

#Programs that UCE_divergence_times depends on
You should cite any of these awesome programs that you use (depending on the options you specify in your UCE_divergence.settings file)

R: R Core Team.  2015.  R: A language and environment for statistical computing. URL http://www.R-project.org/. R Foundation for Statistical Computing, Vienna, Austria. https://www.r-project.org/

PAUP: Swofford, David L. "{PAUP*. Phylogenetic analysis using parsimony (* and other methods). Version 4.}." (2003). http://people.sc.fsu.edu/~dswofford/paup_test/

Fastphylo: Khan, Mehmood A., Isaac Elias, Erik Sjölund, Kristina Nylander, Roman V. Guimera, Richard Schobesberger, Peter Schmitzberger, Jens Lagergren, and Lars Arvestad. "Fastphylo: Fast tools for phylogenetics." BMC bioinformatics 14, no. 1 (2013): 334. http://fastphylo.sourceforge.net/

Seqmagick: seqmagick is written and maintained by the Matsen Group at the Fred Hutchinson Cancer Research Center. http://seqmagick.readthedocs.org/en/latest/
