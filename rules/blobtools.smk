rule diamond:
	input:
		db = config["diamonddb"],
		assembly = get_assemblyfile
	output:
		diamond_results = "results/{sample}/blobtools/diamond/{sample}_diamond_matches"
	container: "docker://reslp/diamond/2.0.7"
	params:
		threads = 12
	shell:
		"""
		db="${{{input.db}%.*}}"
		diamond blastx -d $db -q {input.assembly} -o {output.diamond_results} -p {params.threads}
		"""

rule matchtaxid:
	input:
		idfile = config["prot2taxid"],
		diamond_results = rules.diamond.output.diamond_results
	output:
		renamed_diamond_results = "results/{sample}/blobtools/diamond/{sample}_diamond_matches_formatted"
	container: "docker://reslp/get_taxids"
	shell:
		"""
		get_taxids.py {input.idfile} {input.diamond_results} > {output.renamed_diamond_results}
		"""


rule blobology:
	input:
		bamfile = rules.sam2bam.output.bamfile,
		assembly = get_assemblyfile,
		diamond_results = rules.matchtaxid.output.renamed_diamond_results
	output:
		donefile = "results/{sample}/blobtools/blobology.done"
	container: "docker://reslp/metabat:2.13"
	params: 
		outprefix = "results/{sample}/blobtools"
	shell:
		"""
		mkdir -p {params.outprefix}
		blobtools create -i {input.assembly} -b {input.bamfile} -t {input.diamond_results} -o {params.outprefix}/{wildcards.sample}
		
		blobtools view -i {params.outprefix}/{wildcards.sample}.blobDB.json -o {params.outprefix}/
		blobtools plot -i {params.outprefix}/{wildcards.sample}.blobDB.json -o {params.outprefix}/

		touch {output.donefile}
		"""

rule blobtools:
	input:
		b = rules.blobology.output.donefile,
		assembly = get_assemblyfile
	output: "results/{sample}/blobtools/blobtools.done"
	container: "docker://reslp/extract_contigs"
	shell:
		"""	
		/usr/bin/extract_contigs_from_blobtools.py {input.assembly} results/{wildcards.sample}/blobtools/{wildcards.sample}.blobDB.table.txt
		touch {output}
		"""
	
