# UCE_divergence_times v 0.0.0 [i.e. not ready for public consumption]
Given an outgroup among your UCE data, and a fossil calibration for the split between your outgroup and ingroup, this program estimates the MRCA of your ingroup based on sequence divergence. To roughly account for  rate variation among the taxa, if the divergence between the ingroup species is greater than that between the outgroup/ingroup species, these loci are ditched i.e. only loci where "divergence between ingroup species" < "divergence between ingroup and outgroup species" are used, because these should be loci that are evolving in a more clock-like manner (which is what we are assuming by not explicitly accounting for rate variation between lineages as this is a tree-free approach).

This program is designed to be run inside a folder that has a separate *.fasta or *.uce file for each of your UCE loci. Within that folder you should place your UCE_divergence.settings file (described below), UCE_divergence.sh, shortennames.R, and UCE_divergence.R. You can then execute UCE_divergence_times by bash UCE_divergence.sh.

#Setting up your UCE_divergence.settings file
First line:
There are a number of options for how you run this script that you will set in the UCE_divergence.settings file (example below). This is just a simple text file with a different option on each line. The first of these is whether your data is *.fasta or *.nexus. If it is *.nexus, is the extension *.nexus or *.nex (some of the programs care about the specific extension name? First line = fasta, nexus or nex e.g.
```
nexus
```

Second line:
Your next option is which program you would rather use to estimate the pairwise divergences between your UCE loci: fastphylo or paup. 
-- fastphylo has a correction for saturation of sequences which paup doesn't have, which can be specified by "F". I have tested a few values and 0.95 seems to give the best minimum clade age estimates. However, it is more limited in distance models than paup: (possible values=JC, K2P, TN93, HAMMING,K2P)
-- paup has a lot of options for distances. For the distance model itself you have JC, F81, TAJNEI, K2P, F84, HKY85, K3P, TAMNEI, GTR, ML, LOGDET, UPHOLT, NEILI. You can have RATES=EQUAL RATES=GAMMA. GAMMA rates not allowed with LOGDET. You can have SHAPE = real-value, PINVAR = real-value, and many more options as specified in paup (http://www.ucl.ac.uk/cecd/downloads/PAUP%20command%20reference%20manual.pdf) e.g.
```
nexus
fastphylo
```

If you select paup, make sure you have it installed and within your path. If you select fastphylo, make sure you have this installed and within your path. Additionally, if you are starting from *.nexus (==*.nex) files, and want to use fastphylo, make sure you have seqmagick installed and in your path  (this is going to convert from the *.nexus to *.fasta files that fastphylo can deal with). You also need to make sure that the path to the seqmagick python libs are in your PYTHONPATH e.g.
PYTHONPATH="${PYTHONPATH}:/home/a499a400/bin/seqmagick/lib/python"
export PYTHONPATH

Third line:
Specifying the options that you want to use with whatever evolutionary distance program you have selected

Paup options example:
DISTANCE=NEILI RATES=GAMMA SHAPE=300 MISSDIST=IGNORE

fastphylo options example:
-D HAMMING -F 0.95

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
