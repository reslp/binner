binner
=========

binner is a wrapper script to run several metagenome binning programs using Docker.


Supported Binners
===========

Currently binner supports these metagenome binning programs:

CONCOCT: https://github.com/BinPro/CONCOCT

MaxBin2: https://sourceforge.net/projects/maxbin2/

MetaBat: https://bitbucket.org/berkeleylab/metabat/src/master/

blobtools: https://github.com/DRL/blobtools


REQUIREMENTS
============

- MacOS X or other Unix like operating system
- Docker: https://www.docker.com/get-started


INSTALLATION
=======
Assuming Docker is installed and configured properly, it is straightforward to install binner:

```
$ git clone git clone https://github.com/reslp/binner.git
$ cd binner
$ chmod +x binner
$ ./binner -h
Welcome to binner. A script to quickly run metagenomic binning software using Docker.

Usage: binner [-v] [-a <assembly_file>] [-f <read_file1>] [-r <read_file2>] [-m maxbin,metabat,blobtools,concoct] [-t nthreads] [[--diamonddb=/path/to/diamonddb --protid=/path/to/prot.accession2taxid]] [-q] [-b [--buscosets=set1,set2]]

Options:
	-a <assembly_file> Assembly file in FASTA format (needs to be in current folder)
	-f <read_file1> Forward read file in FASTQ format (can be gzipped)
	-r <read_file2> Reverse read file in FASTQ format (can be gzipped)
		IMPORTANT: Currently the assembly and read files need to be in the same directory which has to the directory in which binner is run.
	-m <maxbin,metabat,blobtools,concoct> specify binning software to run.
	   Seperate multiple options by a , (eg. -o maxbin,blobtools).
	-t number of threads for multi-threaded parts
	-q run QUAST on the binned sets of contigs
	-b run BUSCO on the binned sets of contigs. See additional details below.
	--multiqc Run multiqc after all binning steps to create a summary report on all the bins. This should be used together with -q, -b or both.

	-v Display program version

Options specific to blobtools:
	The blobtools container used here uses diamond instead of blast to increase speed.
	Options needed when blobtools should be run. The blobtools container used here uses diamond instead of blast to increase speed.
  	--diamonddb=	full (absolute) path to diamond database
  	--protid= 	full (absolute) path to prot.accession2taxid file provided by NCBI

Options needed when BUSCO analysis of contigs should be performed:
	The blobtools container used here uses diamond instead of blast to increase speed.
	Options needed when blobtools should be run. The blobtools container used here uses diamond instead of blast to increase speed.
		--buscosets=	BUSCO sets which should be tested. This will be run for each set of contigs. Individual sets should be comma
				separated. eg. --buscosets=fungi_odb9,bacteria_odb9,insects_odb9 .
				Running this assumes that folders with the busco sets exist in the current working directory. They should have
				the same name as passed to the --buscosets command. If they are not found binner will try to download them
				from the BUSCO website.

```




USAGE EXAMPLES
========

binner can run multiple binning software. The components of different binners are contained as individual Docker containers. It is not necessary to install them individually. Most metagenomic binners need an assembly and the associated read files used to create the assembly. Binner expects that the Assembly to filter is provided in FASTA format and the read files in FASTQ format. Assembly and reads should be in the same directory. binner should be executed in this directory.

Additionally binner can perform downstream analyses to evaluate (with BUSCO and QUAST) and aggregate (with multiqc) binning results.

**Running MetaBat with binner:**

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m metabat```

**Running MaxBin with binner:**

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m maxbin```

**Running CONCOCT with binner:**

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m concoct```

**Running blobtools with binner:**

Blobtools requires blast results to get the taxonomic identity (by using NCBI taxids) of individual contigs in the assembly. binner creates these blast results with diamond blastx. However you will need a diamond based sequence database (typically the NCBI nr database). If you don't already have one you can set it up like this.

```
$ wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz
$ docker run --rm reslp/diamond diamond makedb --in nr.gz -d nr
```

Using this command has the advantage that the database is compatible with the used diamond Docker container used in binner which is reslp/binner.

Because diamond cannot output taxids directly binner maps the ids retrieved by diamond blastx to NCBI taxids. This is done using the file `prot.accession2taxid` provided by NCBI. If you don't have this file already download by running the following commands:

```
$ wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
$ gunzip prot.accession2taxid.gz
```

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m blobtools -b /path/to/diamonddb -p /path/to/prot.accession2taxid```

**Run multiple binners**

binner can also run multiple binners in one go:

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m metabat,maxbin,concoct,blobtools -b /path/to/diamonddb -p /path/to/prot.accession2taxid```

**Analyze bins with QUAST and BUSCO**

It is possible to analyze the created bins with QUAST and BUSCO directly with binner to identify interesting sets of bins. Output for this will be produced in the directory containing the bins.

This can be done with two commandline flags `-q` for quast and `-b`for busco. Here are some example commands:

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m concoct -q```

This command will run concoct to create bins and QUAST to evaluate the individual bins.

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m maxbin -b --buscosets=fungi_odb9,dikarya_odb9```

The above command will run maxbin to identify bins of contigs and will run BUSCO the specified busco analyses `--buscosets=fungi_odb9,dikarya_odb9` on each set of bins. Names of the used busco sets should refer to the names on the BUSCO website. The folders for each BUSCO set should be placed in the working directory. If they are not found, binner will try to download them directly from the BUSCO website.

**Aggregate results with multiqc**

To include multiqc into your binner run use a command like this:

```$ binner -a metagenome.fasta -f forward_readfile.fq -r reverse_readfile.fq -m maxbin,blobtools,concoct -b -q --buscosets=fungi_odb9,dikarya_odb9 -b /path/to/diamonddb -p /path/to/prot.accession2taxid --multiqc```

This command will run binning with maxbin,blobtools and concoct and perform downstream analyses with BUSCO and QUAST and will aggregate results with multiqc.



COPYRIGTH AND LICENSE
=====================

Copyright (C) 2019 Philipp Resl

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program in the file LICENSE. If not, see http://www.gnu.org/licenses/.
