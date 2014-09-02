# "Commands used to create the neonectria directory structure, copy accross the sequence files and a preassembled genome in spades, and run a pipeline for sigP/RxLR prediction and a pipeline for identifying homologs within the genome to genes on PHIbase."


vi /home/armita/git_repos/emr_repos/tools/seq_tools/directory_structure/neonectria_galligena.csv

#	Used vim to create the following file:
#	nucleic_acid,library_type,species,strain
#	dna,paired,neonectria_galligena,NG-R0905
#

cd /home/groups/harrisonlab/project_files
/home/armita/git_repos/emr_repos/tools/seq_tools/directory_structure/build_dir.pl /home/armita/git_repos/emr_repos/tools/seq_tools/directory_structure/neonectria_galligena
cd neonectria_galligena/

mkdir assembly/spades
cp -r assembly/prog1/* assembly/spades/.
cp ../neonectria/sorted_contigs.fa assembly/spades/neonectria_galligena/NG-R0905/.

mkdir -p analysis/blast_homology/PHIbase
mv ../fusarium/analysis/blast_homology/PHIbase/PHI_36_accessions.fa analysis/blast_homology/PHIbase/.
qsub /home/armita/git_repos/emr_repos/tools/pathogen/blast/blast_pipe.sh analysis/blast_homology/PHIbase/PHI_36_accessions.fa protein assembly/spades/neonectria_galligena/NG-R0905/sorted_contigs.fa

qsub /home/armita/git_repos/emr_repos/tools/pathogen/blast/blast_pipe.sh analysis/blast_homology/PHIbase/PHI_36_accessions.fa protein assembly/spades/neonectria_galligena/NG-R0905/assembly_v1/sorted_contigs.fa

 
