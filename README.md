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
  for RawData in $(ls raw_dna/paired/*/*/*/*.fastq*?); do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      echo $RawData;
      qsub $ProgDir/run_fastqc.sh $RawData
  done
```

Trimming was performed on data to trim adapters from sequences and remove poor quality data.
This was done with fastq-mcf


```bash
  for StrainPath in $(ls -d raw_dna/paired/*/*); do
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
  for RawData in $(ls qc_dna/paired/*/*/*/*.fastq*); do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      echo $RawData;
      qsub $ProgDir/run_fastqc.sh $RawData
  done
```


kmer counting was performed using kmc.
This allowed estimation of sequencing depth and total genome size:

```bash
  for TrimPath in $(ls -d qc_dna/paired/*/*); do
      ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/dna_qc
      TrimF=$(ls $TrimPath/F/*.fastq.gz)
      TrimR=$(ls $TrimPath/R/*.fastq.gz )
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


<!-- ```bash
  mkdir -p assembly/spades/N.galligena/NG-R0905
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/assemblers/spades
  F_Read=raw_dna/paired/N.galligena/NG-R0905/F/NG-R0905_S4_L001_R1_001.fastq.gz
  R_Read=raw_dna/paired/N.galligena/NG-R0905/R/NG-R0905_S4_L001_R2_001.fastq.gz
  Outdir=assembly/spades/N.galligena/NG-R0905
  qsub $ProgDir/submit_SPAdes.sh $F_Read $R_Read $Outdir correct

``` -->
```bash
  mkdir -p assembly/spades/N.galligena/R0905_v2
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/assemblers/spades
  F_Read=assembly/spades/N.ditissima/NG-R0905/corrected/NG-R0905_qc_F.fastq.00.0_0.cor.fastq.gz
  R_Read=assembly/spades/N.ditissima/NG-R0905/corrected/NG-R0905_qc_R.fastq.00.0_0.cor.fastq.gz
  OutDir=assembly/spades/N.galligena/R0905_v2
  qsub $ProgDir/submit_SPAdes.sh $F_Read $R_Read $OutDir only-assembler
```

```bash
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/assemblers/assembly_qc
  Assembly=assembly/spades/N.galligena/R0905_v2/filtered_contigs/contigs_min_500bp.fasta
  Outdir=assembly/spades/N.galligena/R0905_v2/filtered_contigs
  qsub $ProgDir/sub_quast.sh $Assembly $OutDir
```


Assemblies were summarised to allow the best assembly to be determined by eye.

** Assembly stats are:
  * Assembly size:
  * N50:
  * N80:
  * N20:
  * Longest contig:
  **

The assembled contigs were filtered to remove all contigs shorter than 1kb from
the assembly. This was done using the following commands:

```
  mkdir -p assembly/spades/N.galligena/NG-R0905_filtered
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/assemblers/abyss
  Assembly=assembly/spades/N.galligena/NG-R0905/scaffolds.fasta
  AssFiltered=assembly/spades/N.galligena/NG-R0905/scaffolds_filtered_500.fasta
  $ProgDir/filter_abyss_contigs.py $Assembly 500 > $AssFiltered
  AssFiltered=assembly/spades/N.galligena/NG-R0905/scaffolds_filtered_1000.fasta
  $ProgDir/filter_abyss_contigs.py $Assembly 1000 > $AssFiltered
```  



# Repeatmasking

Repeat masking was performed and used the following programs: Repeatmasker Repeatmodeler

The best assembly was used to perform repeatmasking

```bash
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/repeat_masking
  BestAss=<PATH_TO_BEST_ASSEMBLY.fa>
  qsub $ProgDir/rep_modeling.sh $BestAss
  qsub $ProgDir/transposonPSI.sh $BestAss
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
  ProgDir=/home/armita/git_repos/emr_repos/tools/gene_prediction/cegma
  Assembly=<PATH_TO_UNMASKED_ASSEMBLY.fa>
  qsub $ProgDir/sub_cegma.sh $Genome dna
```
The cegma completeness report gave an indication of the number of genes core
eukaryotic genes were present:
** Number of cegma genes present and complete: **
** Number of cegma genes present and partial: **

##Gene prediction

Gene prediction was performed for the neonectria genome.
CEGMA genes could be used as hints for the location of CDS.

For the moment we shall just use the gene model trained to F. gramminearum.
This model is from a closely related organism that is also plant pathogen.

```bash
  ProgDir=/home/armita/git_repos/emr_repos/tools/gene_prediction/augustus
  Assembly=<PATH_TO_UNMASKED_ASSEMBLY.fa>
  GeneModel=fusarium_graminearum
  qsub $ProgDir/submit_augustus.sh $GeneModel $Assembly
```

** Number of genes predicted: **

#Functional annotation

Interproscan was used to give gene models functional annotations. Annotation was
 run using the commands below:

Note: This is a long-running script. As such, these commands were run using
 'screen' to allow jobs to be submitted and monitored in the background.
 This allows the session to be disconnected and reconnected over time.

Screen ouput detailing the progress of submission of interporscan jobs was
redirected to a temporary output file named interproscan_submission.log .


```bash
  screen -a
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/feature_annotation/interproscan/
  Genes=<PATH_TO_AUGUSTUS GENES.aa>
  $ProgDir/sub_interproscan.sh $Genes
```

Following interproscan annotation split files were combined using the following commands:

```bash
  ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/feature_annotation/interproscan
  PredGenes=<PATH_TO_AUGUSTUS GENES.aa>
  InterProRaw=gene_pred/interproscan/<ORGANISM>/<STRAIN>/raw
  $ProgDir/append_interpro.sh $PredGenes $InterProRaw
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
