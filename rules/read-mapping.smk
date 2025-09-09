

def get_forward_readfile(wildcards):
	return samples_data.loc[wildcards.sample, "forwardreads"]

def get_reverse_readfile(wildcards):
	return samples_data.loc[wildcards.sample, "reversereads"]

def get_assemblyfile(wildcards):
	return samples_data.loc[wildcards.sample, "assembly"]

rule create_index:
	input:
		get_assemblyfile 
	output:
		"results/{sample}/mapping/{sample}.index"
	container: "docker://reslp/bowtie2:2.3.5"
	shell:
		"""
		bowtie2-build {input} {output} -q
		touch {output}
		"""

rule map:
	input:
		index = rules.create_index.output,
		fr = get_forward_readfile,
		rr = get_reverse_readfile
	output:
		samfile = "results/{sample}/mapping/{sample}_raw.sam"
	container: "docker://reslp/bowtie2:2.3.5"
	params: 
		threads = 12
	shell:
		"""
		bowtie2 -p {params.threads} -q --phred33 --fr -x {input.index} -1 {input.fr} -2 {input.rr} -S {output.samfile} --quiet
		"""
rule sam2bam:
	input:
		samfile = rules.map.output.samfile
	output:
		bamfile = "results/{sample}/mapping/{sample}.bam"
	container: "docker://reslp/samtools:1.9"
	shell:
		"""
		samtools view -bS {input.samfile} -o {output.bamfile}	
		samtools sort -o {output.bamfile} {output.bamfile}
		samtools index {output.bamfile}
		"""


