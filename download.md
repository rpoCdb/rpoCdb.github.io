---
title: Downloads
layout: home
nav_order: 2
---

# rpoC Database Downloads

## Preformatted Databases

A custom database for your preferred pipeline isn't here? [Open an issue](https://github.com/rpoCdb/rpoCdatabase/issues) on our github page and we will try to get one added!

### 📊 DADA2 Reference Sequences

```bash
# Download:
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/dada2/rpocDB_v2_dada2.fasta.zip

unzip rpocDB_v2_dada2.fasta.zip

# Usage in R:
# assignTaxonomy(..., refFasta="rpocDB_v2_dada2.fasta")
```

### 🦠 Kraken2 Custom Database

```bash
# Download and build:
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/kraken2/rpocDB_v2_kraken2.fasta.zip 

unzip rpocDB_v2_kraken2.fasta.zip

kraken2-build --add-to-library rpocDB_v2_kraken2.fasta --db rpocDB_v2_kraken2.db
```

### 🔬 mmseqs2 Custom Database

```bash
# Download database and taxonomic file:
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/mmseqs2/database.fasta.zip
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/mmseqs2/mapping.tsv

unzip database.fasta.zip 

# Create MMseqs2 sequence database:
   mmseqs createdb database.fasta seqTaxDB
# Annotate database with taxonomy:
   mmseqs createtaxdb seqTaxDB tmp --tax-mapping-file mapping.tsv --ncbi-tax-dump ncbi_taxdump
# Create index for faster searches:
   mmseqs createindex seqTaxDB tmp

# To run taxonomy assignment on a query FASTA file (e.g., query.fasta):
   mmseqs createdb query.fasta queryDB
   mmseqs taxonomy queryDB seqTaxDB taxonomyResult tmp --lca-ranks superkingdom,phylum,class,order,family,genus,species
   mmseqs createtsv queryDB taxonomyResult taxonomy.tsv
   mmseqs taxonomyreport seqTaxDB taxonomyResult report.html --report-mode 1
```

### 🧫 Mothur Custom Database

```bash
# Download database and taxonomy:
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/mothur/rpoCdb_v2_mothur.fasta.zip
wget https://github.com/rpoCdb/rpoCdatabase/blob/main/02-releases/version_2.0/mothur/rpoCdb_v2_mothur.taxonomy

unzip rpoCdb_v2_mothur.fasta.zip
```

### 🧬 QIIME2-Compatible (.qza/.fasta)

Coming soon!

## Metadata

[Click here access the taxonomy browser](https://aemann01.shinyapps.io/rpocdb_tax_browser/)

[Download the full metadata file (including ///////) here!]()

## Version History

| Version | Release Date   | Changes                         | Sequence Count |
|---------|---------------|----------------------------------|----------------|
| v2.0    | ////////////  | //////////////                   | 65,156        |
| v1.1    | May 16, 2024  | Updated using GTDB               | 42,941        |
| v1.0    | July 10, 2023 | Initial release                  | 15,690        |


[Click here to access previous versions of the database!](https://github.com/rpoCdb/rpoCdatabase/tree/main/02-releases)

