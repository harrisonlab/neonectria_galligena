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

# Step 1 - Making a template for tbl2asn


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
  gag.py -f $Assembly -g Nd_GAG_annotation/genome.gff -o Nd_GAG_annotation3 --fix_start_stop
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

I am going to attempt to use genometools to build a correct gff3 input file.

```bash
  $GffFile=Nd_GAG_annotation/genome.gff
  cat $GffFile \
  | gt dupfeat -dest exon -source CDS \
  | gt dupfeat -dest exon -source three_prime_UTR \
  | gt dupfeat -dest exon -source five_prime_UTR \
  | gt mergefeat \

    | gt gff3 -retainids -sort -tidy -o your.new.gff3
```
