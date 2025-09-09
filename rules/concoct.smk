rule concoct:
	input:
		bamfile = rules.sam2bam.output.bamfile,
		assembly = get_assemblyfile
	output:
		donefile = "results/{sample}/concoct/concoct.done"
	container: "docker://reslp/concoct:1.1"
	params: 
		threads = 12,
		outprefix = "results/{sample}/concoct/bins",
		outdir = "results/{sample}/concoct"
	shell:
		"""
		mkdir -p {params.outprefix}
		cut_up_fasta.py {input.assembly} -c 10000 -o 0 --merge_last -b {params.outdir}/{wildcards.sample}_contigs_10K.bed > {params.outdir}/{wildcards.sample}_contigs_10K.fa
		concoct_coverage_table.py {params.outdir}/{wildcards.sample}_contigs_10K.bed {input.bamfile} > {params.outdir}/{wildcards.sample}_concoct_coverage_table.tsv
		concoct --composition_file {params.outdir}/{wildcards.sample}_contigs_10K.fa --coverage_file {params.outdir}/{wildcards.sample}_concoct_coverage_table.tsv -b {params.outdir}/{wildcards.sample}_concoct --threads $THREADS
		merge_cutup_clustering.py {params.outdir}/{wildcards.sample}_concoct_clustering_gt1000.csv > {params.outdir}/{wildcards.sample}_concoct_clustering_merged.csv
		extract_fasta_bins.py {input.assembly} {params.outdir}/{wildcards.sample}_concoct_clustering_merged.csv --output_path {params.outprefix}
		for file in $(find {params.outprefix}/*.fa); do name=$(basename $file); echo $file {params.outprefix}/concoct_$name; done
		touch {output.donefile}
		"""
