rule extract_coverage_data:
	input:
		bamfile = rules.sam2bam.output.bamfile
	output:
		coverage = "results/{sample}/maxbin/coverage_data_{sample}.idxstats",
		counts = "results/{sample}/maxbin/{sample}.counts"
	container: "docker://reslp/samtools:1.9"
	shell:
		"""
		samtools idxstats {input.bamfile} > {output.coverage}
		cut -f 1,3 {output.coverage} > {output.counts}
		"""


rule maxbin:
	input:
		counts = rules.extract_coverage_data.output.counts,
		assembly = get_assemblyfile
	output:
		donefile = "results/{sample}/maxbin/maxbin.done"
	container: "docker://reslp/maxbin:2.2.6"
	params: 
		threads = 12,
		outprefix = "results/{sample}/maxbin/bins"
	shell:
		"""
		mkdir -p {params.outprefix}
		run_MaxBin.pl -contig {input.assembly} -abund {input.counts} -thread {params.threads} -out {params.outprefix}/maxbin
		touch {output.donefile}
		"""
