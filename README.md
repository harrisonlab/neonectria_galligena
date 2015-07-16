neonectria_galligena
====================

Commands used during analysis of the neonectria_galligena genome. Note - all this work was performed in the directory: /home/groups/harrisonlab/project_files/neonectria_galligena

The following is a summary of the work presented in this Readme:
Data organisation:
  * Preparing data  
Draft Genome assembly
  * Data qc
  * Genome assembly
  * Repeatmasking
  * Gene prediction
  * Functional annotation
Genome analysis
  * Homology between predicted genes & published effectors


#Data organisation

Data was copied from the raw_data repository to a local directory for assembly
and annotation.

```bash
  cd /home/groups/harrisonlab/project_files/neonectria_galligena
  Species=N.galligena
  Strain=NG-R0905
  mkdir -p raw_dna/paired/$Species/$Strain/F
  mkdir -p raw_dna/paired/$Species/$Strain/R
  cp /home/groups/harrisonlab/project_files/neonectria/NG-R0905_S4_L001_R1_001.fastq raw_dna/paired/$Species/$Strain/F/.
  cp /home/groups/harrisonlab/project_files/neonectria/NG-R0905_S4_L001_R2_001.fastq raw_dna/paired/$Species/$Strain/R/.
  gzip raw_dna/paired/N.galligena/NG-R0905/F/NG-R0905_S4_L001_R1_001.fastq
  gzip raw_dna/paired/N.galligena/NG-R0905/R/NG-R0905_S4_L001_R2_001.fastq
```


#Data qc

programs: fastqc fastq-mcf kmc

Data quality was visualised using fastqc:

```bash
  for RawData in raw_dna/paired/*/*/*/*.fastq*?; do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      echo $RawData;
      qsub $ProgDir/run_fastqc.sh $RawData
  done
```

Trimming was performed on data to trim adapters from sequences and remove poor quality data.
This was done with fastq-mcf


```bash
  for StrainPath in raw_dna/paired/*/*; do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/rna_qc
      IlluminaAdapters=/home/armita/git_repos/emr_repos/tools/seq_tools/illumina_full_adapters.fa
      ReadsF=$(ls $StrainPath/F/*.fastq*)
      ReadsR=$(ls $StrainPath/R/*.fastq*)
      echo $ReadsF
      echo $ReadsR
      qsub $ProgDir/rna_qc_fastq-mcf.sh $ReadsF $ReadsR $IlluminaAdapters DNA
  done
```

Data quality was visualised once again following trimming:

```bash
  for RawData in qc_dna/paired/*/*/*/*.fastq*; do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      echo $RawData;
      qsub $ProgDir/run_fastqc.sh $RawData
  done
```


kmer counting was performed using kmc.
This allowed estimation of sequencing depth and total genome size:

```bash
  for TrimPath in qc_dna/paired/*/*; do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      TrimF=$(ls $TrimPath/F/*.fastq*)
      TrimR=$(ls $TrimPath/R/*.fastq*)
      echo $TrimF
      echo $TrimR
      qsub $ProgDir/kmc_kmer_counting.sh $TrimF $TrimR
  done
```

** Estimated Genome Size is: **

** Esimated Coverage is: **

#Assembly
Assembly was performed using: Velvet / Abyss / Spades

A range of hash lengths were used and the best assembly selected for subsequent analysis


```bash
  mkdir -p assembly/spades/N.galligena/NG-R0905
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/assemblers/spades
  F_Read=raw_dna/paired/N.galligena/NG-R0905/F/NG-R0905_S4_L001_R1_001.fastq.gz
  R_Read=raw_dna/paired/N.galligena/NG-R0905/R/NG-R0905_S4_L001_R2_001.fastq.gz
  Outdir=assembly/spades/N.galligena/NG-R0905
  qsub $ProgDir/submit_SPAdes.sh $F_Read $R_Read $Outdir correct

```

Assemblies were summarised to allow the best assembly to be determined by eye.

** Assembly stats are:
  * Assembly size:
  * N50:
  * N80:
  * N20:
  * Longest contig:
  **

# Repeatmasking

Repeat masking was performed and used the following programs: Repeatmasker Repeatmodeler

The best assembly was used to perform repeatmasking

```bash

```

** % bases maked by repeatmasker: **

** % bases masked by transposon psi: **


# Gene Prediction
Gene prediction followed two steps:
Pre-gene prediction - Quality of genome assemblies were assessed using Cegma to see how many core eukaryotic genes can be identified.
Gene models were used to predict genes in the Neonectria genome. This used results from CEGMA as hints for gene models.

## Pre-gene prediction
Quality of genome assemblies was assessed by looking for the gene space in the assemblies.

```bash

```

** Number of cegma genes present and complete: **
** Number of cegma genes present and partial: **

##Gene prediction

Gene prediction was performed for the neonectria genome.
CEGMA genes were used as Hints for the location of CDS.

```bash

```

** Number of genes predicted: **

#Functional annotation

Interproscan was used to give gene models functional annotations.

```bash

```


#Genomic analysis
The first analysis was based upon BLAST searches for genes known to be involved in toxin production


##Genes with homology to PHIbase
Predicted gene models were searched against the PHIbase database using tBLASTx.

```bash

```

Top BLAST hits were used to annotate gene models.

```bash

```

** Blast results of note: **
  * 'Result A'
