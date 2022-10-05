set -x

mkdir -p $1
pushd $1

ls /usr/share/data-minor-bioinf/assembly/* | xargs -n 1 ln -s

export SEED=${SEED:=239}
export N=${N:=5000000}
export M=${M:=1500000}
export FULL=${FULL:=full}
export TRIM=${TRIM:=trim}

seqtk sample -s $SEED oil_R1.fastq $N > subPE1.fq
seqtk sample -s $SEED oil_R2.fastq $N > subPE2.fq
seqtk sample -s $SEED oilMP_S4_L001_R1_001.fastq $M > subMP1.fq
seqtk sample -s $SEED oilMP_S4_L001_R2_001.fastq $M > subMP2.fq

rm oil*

mkdir -p $FULL/fastqc
ls sub* | xargs -n 1 fastqc -o $FULL/fastqc
multiqc -o $FULL $FULL/fastqc

platanus_trim subPE*
platanus_internal_trim subMP*

rm *fq

mkdir -p $TRIM/fastqc
ls sub* | xargs -n 1 fastqc -o $TRIM/fastqc
multiqc -o $TRIM $TRIM/fastqc

platanus assemble -o oil -f subPE* -t 6 2> assemble.log

platanus scaffold -o oil -c oil_contig.fa -IP1 subPE* -OP2 subMP* -t 6 2> scaffold.log

platanus gap_close -o oil -c oil_scaffold.fa -IP1 subPE* -OP2 subMP* -t 6 2> gapclose.log

rm sub*

popd
