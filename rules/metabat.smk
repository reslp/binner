rule metabat:
	input:
		bamfile = rules.sam2bam.output.bamfile,
		assembly = get_assemblyfile
	output:
		depthfile = "results/{sample}/metabat/metabat_depth.txt",
		pairedfile = "results/{sample}/metabat/metabat_paired.txt",
		donefile = "results/{sample}/metabat/metabat.done"
	container: "docker://reslp/metabat:2.13"
	params: 
		outprefix = "results/{sample}/metabat/bins"
	shell:
		"""
		mkdir -p {params.outprefix}
		jgi_summarize_bam_contig_depths --outputDepth {output.depthfile} --pairedContigs {output.pairedfile} {input.bamfile}
		metabat2 -i {input.assembly} -a {output.depthfile} -o {params.outprefix}/metabat --sensitive
		"""
