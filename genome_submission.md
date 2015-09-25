# Submission Commands

Submisison of annotations with an assembly appears to be a complex process.
If a genome is to be submitted without annotation then all that is needed is the
fasta file containing the assembled contigs. If an annotated genome is to be
submitted then a number of processing steps are required before submission. The
fasta file of contigs and the gff file of annotations must be combined to form a
.asn file. The program that does this conversion (tbl2asn) requires the fasta
files and gff files to be formatted correctly. In the case of the gff file, this
means parsing it to a .tbl file.

The commands used to parse these files and prepare the N. ditissima genome for
submisson are shown below.


```bash
mkdir -p collaboration/genome_submission

```

The genbank submission template tool was used at:
http://www.ncbi.nlm.nih.gov/WebSub/template.cgi

This produce a templete file detailing the submission. The contents of this file
were:

```
  Submit-block ::= {
    contact {
      contact {
        name name {
          last "Armitage",
          first "Andrew"
        },
        affil std {
          affil "East Malling Research",
          div "Genetics for Crop Improvement",
          city "East Malling",
          sub "Kent",
          country "UK",
          street "New Road",
          email "Andrew.Armitage@EMR.ac.uk",
          fax "",
          phone "0044-1732-523729 (International), 01732 523729 (UK)",
          postal-code "ME19 6BJ"
        }
      }
    },
    cit {
      authors {
        names std {
          {
            name name {
              last "G##mez-Corteceroa",
              first "Antonio",
              initials "A.",
              suffix ""
            }
          },
          {
            name name {
              last "Harrison",
              first "Richard",
              initials "R.J.",
              suffix ""
            }
          },
          {
            name name {
              last "Armitage",
              first "Andrew",
              initials "A.D.",
              suffix ""
            }
          }
        },
        affil std {
          affil "East Malling Research",
          div "Genetics for Crop Improvement",
          city "East Malling",
          sub "Kent",
          country "UK",
          street "New Road",
          postal-code "ME19 6BJ"
        }
      }
    },
    subtype new
  }

  Seqdesc ::= pub {
    pub {
      gen {
        cit "unpublished",
        authors {
          names std {
            {
              name name {
                last "G##mez-Corteceroa",
                first "Antonio",
                initials "A.",
                suffix ""
              }
            },
            {
              name name {
                last "Harrison",
                first "Richard",
                initials "R.J.",
                suffix ""
              }
            },
            {
              name name {
                last "Armitage",
                first "Andrew",
                initials "A.D.",
                suffix ""
              }
            }
          },
          affil std {
            affil "East Malling Research",
            div "Genetics for Crop Improvement",
            city "East Malling",
            sub "Kent",
            country "UK",
            street "New Road",
            postal-code "ME19 6BJ"
          }
        },
        title "Draft genome of a European isolate of the apple canker pathogen
   Neonectria ditissima"
      }
    }
  }

  Seqdesc ::= user {
    type str "DBLink",
    data {
      {
        label str "BioProject",
        num 1,
        data strs {
          "PRJNA292426"
        }
      },
      {
        label str "BioSample",
        num 1,
        data strs {
          "SAMN03975979"
        }
      }
    }
  }
```

This file was moved to the newly created directory:

```bash
  mv $File collaboration/genome_submission/.
```

## Step2 - Converting gff files to gb files

The script gff2gb.pl was written to convert Augustus gff output into genbank
format files that can be later converted to require .tbl format.

<!-- ```bash
  ProgDir=/home/armita/git_repos/emr_repos/tools/genbank_submission/downloaded_scripts
  Assembly=../../assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa
  GffFile=../../gene_pred/augustus/N.ditissima/R0905_v2/R0905_v2_EMR_aug_preds.gff
  $ProgDir/gff2gb.pl $Assembly $GffFile outfile.gb
``` -->

These commands were not run in favour of the tool GAG (Genome Annotation
Generator).

```bash
  Assembly=../../assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa
  GffFile=../../gene_pred/augustus/N.ditissima/R0905_v2/R0905_v2_EMR_aug_preds.gff
  cat $GffFile | sed 's/transcript/mRNA/g' > GffMRNA.gff
  gag.py -f $Assembly -g GffMRNA.gff -o Nd_GAG_modified --fix_start_stop
```


## Step 3 - Converting gb gene models to .tbl annotations

<!--
The script gbk2tbl.py was run. This script was not written by myself. As part of
its running, it requires a modifiers file.

Possible modifiers are shown at:
http://www.ncbi.nlm.nih.gov/Sequin/modifiers.html

A modifiers file was made using the command:

```bash
  echo '[organism=Badger Badger Badger] [sub-species=Mushroom] [strain=Snake]' > modifiers.txt
```

```bash
  # Genbank_file=GCA_000149955.2_ASM14995v2_genomic.gbff
  Genbank_file=outfile.gb
  ProgDir=~/git_repos/emr_repos/tools/genbank_submission/downloaded_scripts
  cat $Genbank_file | python $ProgDir/gbk2tbl.py --modifiers modifiers.txt --prefix Nd
``` -->

Due to GAG outputting a .tbl the gbk2tbl.py script didnt need to be run.

## Step 4 - converting .tbl annotations to asn annotations

```bash
  cd /home/groups/harrisonlab/project_files/neonectria_ditissima/collaboration/genome_submission/tbl2asn_out
  cp ../Nd_GAG_modified/genome.gff .
  cp ../Nd_GAG_modified/genome.tbl .
  cp ../temp genome.sbt
  cp ../Nd_GAG_modified/genome.fasta genome.fsa
  mkdir tbl2asn_output
  tbl2asn -p. -t genome.sbt -r tbl2asn_output -M n -Z discrepancy_rep.log -c f
```

This produced a discrepancy report in file: discrepancy_rep.log

The contents of this file indicated a lot of problems with the input data.

1) locus tags should be preceeded by the bioprojects unique ID.
our registered number is AK830

```bash
  cat genome.tbl | sed 's/|g/|AK830_g/g' > genome_mod.tbl
  cat genome_mod.tbl | sed -E 's/locus_tag\tg/locus_tag\tAK830_g/g' > genome_mod2.tbl
  mv genome.tbl genome_unmod.tbl
  cp genome_mod2.tbl genome.tbl
  tbl2asn -p. -t genome.sbt -r tbl2asn_output -a s -V v -c f -Z discrepancy_rep2.log -c f -j "[organism=Neonectria ditissima] [strain=R09/05]"
```

The output file was looked at:
```bash
  less tbl2asn_output/errorsummary.val
```

    26 ERROR:   SEQ_FEAT.InternalStop
     2 ERROR:   SEQ_FEAT.NoStop
    26 ERROR:   SEQ_INST.StopInProtein
    30 WARNING: SEQ_FEAT.PartialProblem
   211 WARNING: SEQ_FEAT.ShortExon
    18 WARNING: SEQ_FEAT.SuspiciousFrame

The 26 sequences with internal stop sites were identified

Gene g161 was edited to add an additional line to underneath the gene ID and
underneath the CDS product.



```bash
  nano genome.tbl
```

```
  470355  467125  gene
                          locus_tag       AK830_g161
  +                        pseudo
  470355  470299  CDS
  470142  469395
  469301  469288
  469217  468958
  468887  468568
  468296  468034
  467971  467640
  467581  467256
  467201  467125
                          codon_start     1
  -                        product hypothetical protein
  +                        pseudo
                          protein_id      gnl|ncbi|AK830_g161.t1
                          transcript_id   gnl|ncbi|AK830_g161.t1_mrna
```

A python script was written to perform these modifications.

```bash
  ProgDir=~/git_repos/emr_repos/tools/genbank_submission/edit_tbl_file
  $ProgDir/mark_pseudo.py --inp_tbl genome.tbl --inp_val tbl2asn_output/genome.val --edits stop pseudo --out_tbl genome2.tbl
```

The analysis was repeated using the newly modified tbl file

```bash
  mkdir tbl2asn_output2
  cp genome2.tbl tbl2asn_output2/.
  cp genome.fsa tbl2asn_output2/genome2.fsa
  cp genome.sbt tbl2asn_output2/genome2.sbt
  tbl2asn -p tbl2asn_output2 -t tbl2asn_output2/genome2.sbt -r tbl2asn_output2 -a s -V v -c f -Z discrepancy_rep2.log -c f -j "[organism=Neonectria ditissima] [strain=R09/05]"
```

As the .val file no longer contains any messages with the ERROR state a
final output was made for genbank submission:

```bash
  mkdir -p for_submisison
  cp genome2.tbl for_submission/N.ditissima_R0905.tbl
  cp genome.fsa for_submission/N.ditissima_R0905.fsa
  cp genome.sbt for_submission/N.ditissima_R0905.sbt
  tbl2asn -p for_submission -t for_submission/N.ditissima_R0905.sbt -r for_submission -M n -Z discrep -j "[organism=Neonectria ditissima] [strain=R09/05]"
```

# Revision after submission to ncbi


After submission to ncbi, the following issues were noted:
* mRNA was not provided for the submission - This shall be addressed by
re-running augustus with '--print_utr=on'
* All annotations were marked as 'hypothetical protein', ncbi will not accept a
submission with all genes listed as hypothetical protein - This shall be
addressed by providing interproscan annotations for the proteins.

## Step3 - Extract functional annotations

Interproscan annotations were extracted using annie, the ANNotation Information
Extractor.

```bash
  InterProTab=../../../neonectria_galligena/gene_pred/interproscan/spades/N.ditissima/N.ditissima_interproscan.tsv
  SwissProtBlast=/home/groups/harrisonlab/project_files/neonectria_galligena/uniprot/uniprot_hits.tbl
  SwissProtFasta=/home/groups/harrisonlab/uniprot/swissprot/uniprot_sprot.fasta
  GffFile=../../gene_pred/augustus/N.ditissima/R0905_v2/R0905_v2_EMR_aug_preds.gff
  GeneGff=GffMRNA.gff
  cat $GffFile | sed 's/transcript/mRNA/g' > $GeneGff
  ProgDir=/home/armita/prog/annie/genomeannotation-annie-c1e848b
  python3 $ProgDir/annie.py -ipr $InterProTab -g $GeneGff -b $SwissProtBlast -db $SwissProtFasta -o annie_output.csv --fix_bad_products
  ProgDir=~/git_repos/emr_repos/tools/genbank_submission/edit_tbl_file
  $ProgDir/annie_corrector.py --inp_csv annie_output.csv --out_csv annie_corrected_output.csv

```

## Step4 - build .tbl file including functional annotation

GAG (Genome Annotation Generator) was re-run including the functional annotation
table from annie

```bash
  mkdir Nd_GAG_annotation
  Assembly=../../assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa
  gag.py -f $Assembly -g GffMRNA.gff -a annie_corrected_output.csv -o Nd_GAG_annotation --fix_start_stop
  gag.py -f $Assembly -g Nd_GAG_annotation/genome.gff -o Nd_GAG_annotation3
  sed -i 's/Dbxref/db_xref/g' Nd_GAG_annotation3/genome.tbl
```
tbl2asn was re-run following the addition of annotations.

```bash
  cp Nd_GAG_annotation/genome.fasta Nd_GAG_annotation3/genome.fsa
  cp tbl2asn_out/genome2.sbt Nd_GAG_annotation3/genome.sbt
  tbl2asn -p Nd_GAG_annotation3/. -t Nd_GAG_annotation/genome.sbt -r tmp -M n -Z discrep -j "[organism=Neonectria ditissima] [strain=R09/05]"
```


## Step 5 - Ensure mRNA is contained in the .tbl file

The final .tbl file does not contain mRNA features. From the following forum
threads I suspect that this is due to exon features not being represented in the
gff file.
https://www.biostars.org/p/101225/
http://gmod.827538.n3.nabble.com/gff3-format-issue-correction-td4037428.html

I am going to attempt to use genometools to build a correct gff3 input file...

This proved unsuccessful: Genometools renames and re-orders features in the
gff file. THis is not done in a thoughtful manner and will complicate
downstream analysis.

<!-- ```bash
  GffFile=Nd_GAG_annotation/genome.gff
  # gt gff3 -tidy -retainids -checkids -addids -o tmp.gff -force $GffFile
  cat $GffFile \
  | gt gff3 -tidy -retainids \
  | gt dupfeat -dest exon -source CDS \
  # | gt dupfeat -dest exon -source three_prime_UTR \
  # | gt dupfeat -dest exon -source five_prime_UTR \
  # | gt mergefeat \
    -o tmp.gff -force
  # Assembly=../../assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa
  # gag.py -f $Assembly -g tmp.gff -o Nd_GAG_annotation4 --fix_start_stop
``` -->

As such, parsers were written in perl and python to correct gff files. Biopython
was avoided as it will run slowly. The gff modules of bioperl either expected
all features to already be correctly formatted or missed those features that
were incorrectly formatted.

```bash
  GffFile=../../gene_pred/augustus/N.ditissima/R0905_v2/R0905_v2_EMR_aug_preds.gff
  cat $GffFile | sed 's/transcript/mRNA/g' > GffMRNA.gff
  ProgDir=~/git_repos/emr_repos/tools/genbank_submission/generate_tbl_file
  $ProgDir/exon_generator.pl GffMRNA.gff > corrected_exons.gff
  $ProgDir/gff_add_id.py --inp_gff corrected_exons.gff --out_gff corrected_exons_id.gff
  # $ProgDir/gff_correct_mRNA_boundaries.py corrected_exons_id.gff > corrected_exons_id_mRNA.gff
  Assembly=../../assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa
  # gag.py -f $Assembly -g corrected_exons_id.gff -o Nd_GAG_corrected_annotation

  # gag.py -f $Assembly -g corrected_exons_id_mRNA.gff -a annie_corrected_output.csv -o Nd_GAG_corrected_annotation
  gag.py -f $Assembly -g corrected_exons_id.gff -a annie_corrected_output.csv -o Nd_GAG_corrected_annotation
  sed -i 's/Dbxref/db_xref/g' Nd_GAG_corrected_annotation/genome.tbl
  cp Nd_GAG_annotation/genome.fasta Nd_GAG_corrected_annotation/genome.fsa
  cp tbl2asn_out/genome.sbt Nd_GAG_corrected_annotation/genome.sbt
  tbl2asn -p Nd_GAG_corrected_annotation/. -t Nd_GAG_corrected_annotation/genome.sbt -r tmp -M n -Z discrep -j "[organism=Neonectria ditissima] [strain=R09/05]"
  mkdir -p Nd_GAG_corrected_annotation2
  ProgDir=~/git_repos/emr_repos/tools/genbank_submission/edit_tbl_file
  GeneSource='ab initio prediction:Augustus:3.1'
  IDSource='similar to AA sequence:SwissProt:2015_09'
  $ProgDir/ncbi_tbl_corrector.py --inp_tbl Nd_GAG_corrected_annotation/genome.tbl --inp_val tmp/genome.val --locus_tag AK830 --lab_id ArmitageEMR --gene_id remove --add_inference "$GeneSource" "$IDSource" --edits stop pseudo unknown_UTR --out_tbl Nd_GAG_corrected_annotation2/genome.tbl
  mkdir -p tmp2
  cp Nd_GAG_corrected_annotation/genome.fsa Nd_GAG_corrected_annotation2/genome.fsa
  cp Nd_GAG_corrected_annotation/genome.sbt Nd_GAG_corrected_annotation2/genome.sbt
  tbl2asn -p Nd_GAG_corrected_annotation2/. -t Nd_GAG_corrected_annotation2/genome.sbt -r tmp2 -M n -Z discrep -j "[organism=Neonectria ditissima] [strain=R09/05]"
```

# Final Submission

These commands were used in the final submission of the N. ditissima genome:


## Output directory
An output and working directory was made for genome submission:

```bash
  cd /home/groups/harrisonlab/project_files/neonectria_galligena
  OutDir="genome_submission/N.ditissima/R0905"
  mkdir -p $OutDir
  ProjDir=/home/groups/harrisonlab/project_files/neonectria_ditissima
```

## SbtFile
The genbank submission template tool was used at:
http://www.ncbi.nlm.nih.gov/WebSub/template.cgi
This produce a template file detailing the submission.

## Setting varibales
Vairables containing locations of files and options for scripts were set:

```bash
  # Program locations:
  AnnieDir="/home/armita/prog/annie/genomeannotation-annie-c1e848b"
  ProgDir="/home/armita/git_repos/emr_repos/tools/genbank_submission"
  # File locations:
  SbtFile="/home/groups/harrisonlab/project_files/neonectria_ditissima/collaboration/genome_submission/tbl2asn_out/genome.sbt"
  Assembly="/home/groups/harrisonlab/project_files/neonectria_ditissima/assembly/spades/N.ditissima/R0905_v2/filtered_contigs/contigs_min_500bp_10x_filtered_renamed.fa"
  InterProTab="gene_pred/interproscan/spades/N.ditissima/N.ditissima_interproscan.tsv"
  SwissProtBlast="gene_pred/uniprot/N.ditissima/R0905/swissprot_v2015_09_hits.tbl"
  SwissProtFasta="/home/groups/harrisonlab/uniprot/swissprot/uniprot_sprot.fasta"
  GffFile="gene_pred/augustus/N.ditissima/R0905_v2/R0905_v2_EMR_aug_preds.gff"
  # tbl2asn options:
  Organism="Neonectria ditissima"
  Strain="R09/05"
  # ncbi_tbl_corrector script options:
  SubmissionID="AK830"
  LabID="ArmitageEMR"
  GeneSource='ab initio prediction:Augustus:3.1'
  IDSource='similar to AA sequence:SwissProt:2015_09'
  # Final submisison file name:
  FinalName="Nd_Gomez_2015"
```

## Preparing Gff input file

Parse the Augustus Gff file.
Transcripts should be renamed as mRNA features. Exons should be added to the
Gff and unique IDs should be given to all features in the file.

```bash
  cat $GffFile | sed 's/transcript/mRNA/g' > $OutDir/GffMRNA.gff
  $ProgDir/generate_tbl_file/exon_generator.pl $OutDir/GffMRNA.gff > $OutDir/corrected_exons.gff
  $ProgDir/generate_tbl_file/gff_add_id.py --inp_gff $OutDir/corrected_exons.gff --out_gff $OutDir/corrected_exons_id.gff
```

## Generating .tbl file (GAG)

The Genome Annotation Generator (GAG.py) can be used to convert gff files into
.tbl format, for use by tbl2asn.

It can also add annotations to features as provided by Annie the Annotation
extractor.

### Extracting annotations (Annie)

Interproscan and Swissprot annotations were extracted using annie, the
ANNotation Information Extractor. The output of Annie was filtered to
keep only annotations with references to ncbi approved databases.
Note - It is important that transcripts have been re-labelled as mRNA by this
point.

```bash
  python3 $AnnieDir/annie.py -ipr $InterProTab -g $OutDir/corrected_exons_id.gff -b $SwissProtBlast -db $SwissProtFasta -o $OutDir/annie_output.csv --fix_bad_products
  $ProgDir/edit_tbl_file/annie_corrector.py --inp_csv $OutDir/annie_output.csv --out_csv $OutDir/annie_corrected_output.csv
```

### Running GAG

Gag was run using the modified gff file as well as the annie annotation file.
Gag was noted to output database references incorrectly, so these were modified.

```bash
  mkdir -p $OutDir/gag/round1
  gag.py -f $Assembly -g $OutDir/corrected_exons_id.gff -a $OutDir/annie_corrected_output.csv -o $OutDir/gag/round1
  sed -i 's/Dbxref/db_xref/g' $OutDir/gag/round1/genome.tbl
```

## tbl2asn round 1

tbl2asn was run an initial time to collect error reports on the current
formatting of the .tbl file.
Note - all input files for tbl2asn need to be in the same directory and have the
same basename.

```bash
  cp $Assembly $OutDir/gag/round1/genome.fsa  
  cp $SbtFile $OutDir/gag/round1/genome.sbt
  mkdir -p $OutDir/tbl2asn/round1
  tbl2asn -p $OutDir/gag/round1/. -t $OutDir/gag/round1/genome.sbt -r $OutDir/tbl2asn/round1 -M n -Z discrep -j "[organism=$Organism] [strain=$Strain]"
```

## Editing .tbl file

The tbl2asn .val output files were observed and errors corrected. THis was done
with an in house script. The .val file indicated that some cds had premature
stops, so these were marked as pseudogenes ('pseudo' - SEQ_FEAT.InternalStop)
and that some genes had cds coordinates that did not match the end of the gene
if the protein was hanging off a contig ('stop' - SEQ_FEAT.NoStop).
Furthermore a number of other edits were made to bring the .tbl file in line
with ncbi guidelines. This included: Marking the source of gene
predictions and annotations ('add_inference'); Correcting locus_tags to use the
given ncbi_id ('locus_tag'); Correcting the protein and transcript_ids to
include the locus_tag and reference to submitter/lab id ('lab_id'), removal of
annotated names of genes if you don't have high confidence in their validity
(--gene_id 'remove'). If 5'-UTR and 3'-UTR were not predicted during gene
annotation then genes, mRNA and exon features need to reflect this by marking
them as incomplete ('unknown_UTR').

```bash
  mkdir -p $OutDir/gag/edited
  $ProgDir/edit_tbl_file/ncbi_tbl_corrector.py --inp_tbl $OutDir/gag/round1/genome.tbl --inp_val $OutDir/tbl2asn/round1/genome.val --locus_tag $SubmissionID --lab_id $LabID --gene_id "remove" --add_inference "$GeneSource" "$IDSource" --edits stop pseudo unknown_UTR --out_tbl $OutDir/gag/edited/genome.tbl
```

## Final run of tbl2asn

Following correction of the GAG .tbl file, tbl2asn was re-run to provide the
final genbank submission file.

```bash
  cp $Assembly $OutDir/gag/edited/genome.fsa
  cp $SbtFile $OutDir/gag/edited/genome.sbt
  mkdir $OutDir/tbl2asn/final
  tbl2asn -p $OutDir/gag/edited/. -t $OutDir/gag/edited/genome.sbt -r $OutDir/tbl2asn/final -M n -Z discrep -j "[organism=$Organism] [strain=$Strain]"
  cp $OutDir/tbl2asn/final/genome.sqn $OutDir/tbl2asn/final/$FinalName.sqn
```

The final error report contained the following warnings. These were judged to be
legitimate concerns but biologically explainable.

67 WARNING: SEQ_FEAT.PartialProblem
 5 WARNING: SEQ_FEAT.ProteinNameEndsInBracket
211 WARNING: SEQ_FEAT.ShortExon
18 WARNING: SEQ_FEAT.SuspiciousFrame
 5 INFO:    SEQ_FEAT.PartialProblem

 Note -
 *SEQ_FEAT.partial problem. In this case, upon investigation these genes were hannging
 off the end of a contig but did not have an mRNA feature that went off of the
 end of the contig. This was occuring due to an intron being predicted hanging
 off the contig. An example on the ncbi guidelines here shows this to be
 acceptable:
 http://www.ncbi.nlm.nih.gov/genbank/eukaryotic_genome_submission_annotation#Partialcodingregionsinincompletegenomes
 *SEQ_FEAT.ProteinNameEndsInBracket. These gene names include brackets for good
 reason
