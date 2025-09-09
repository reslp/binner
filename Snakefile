import pandas as pd
import yaml

configfile: "data/config.yaml"
samples_data = pd.read_csv(config["samples"], sep="\t").set_index("name", drop=False)
samples = [sample.replace(" ", "_") for sample in samples_data["name"].tolist()]
print(samples)

def get_forward_readfile(wildcards):
	return samples_data.loc[wildcards.sample, "forwardreads"]

def get_reverse_readfile(wildcards):
	return samples_data.loc[wildcards.sample, "reversereads"]

def get_assemblyfile(wildcards):
	return samples_data.loc[wildcards.sample, "assembly"]

include: "rules/read-mapping.smk"
include: "rules/metabat.smk"
include: "rules/maxbin.smk"
include: "rules/concoct.smk"
include: "rules/blobtools.smk"

def determine_output(wildcards):
	l = []
	for sample in samples:
		for method in config["methods"].split(","):
			l.append("results/" + sample + "/" + method + "/" + method + ".done")	
	return l
		
rule read_mapping:
	input:
		expand("results/{sample}/mapping/{sample}.bam", sample=samples)

rule binner:
	input: 
		determine_output
