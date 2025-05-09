---
title: Downloads
layout: home
nav_order: 2
---

# rpoC Database Downloads

## Preformatted Databases

### 🧬 QIIME2-Compatible (.qza/.fasta)
**Files:**  
- `rpoC_db_v1.0_qiime2.qza` (QIIME2 artifact)  
- `rpoC_db_v1.0_qiime2.fasta` (raw sequences)  

```bash
# Download:
wget https://example.com/rpoC_db_v1.0_qiime2.qza
wget https://example.com/rpoC_db_v1.0_qiime2.fasta

# Import into QIIME2:
qiime tools import \
  --input-path rpoC_db_v1.0_qiime2.fasta \
  --output-path rpoC_db.qza \
  --type 'FeatureData[Sequence]'
```

### 🦠 Kraken2 Custom Database
**Files:**
- `rpoC_db_v1.0_kraken2.tar.gz` (compressed database)

```bash
# Download and build:
wget https://example.com/rpoC_db_v1.0_kraken2.tar.gz
tar -xzvf rpoC_db_v1.0_kraken2.tar.gz
kraken2-build --add-to-library rpoC_db.fasta --db rpoC_kraken_db
```

### 📊 DADA2 Reference Sequences
**Files:**
- `rpoC_db_v1.0_dada2.fasta`

```bash
# Download:
wget https://example.com/rpoC_db_v1.0_dada2.fasta

# Usage in R:
# assignTaxonomy(..., refFasta="rpoC_db_v1.0_dada2.fasta")
```

### 🧪 Raw Data
**Files:**
- `rpoC_db_v1.0_raw.fasta` (all sequences)
- `rpoC_db_v1.0_metadata.tsv` (annotations)

```bash
wget https://example.com/rpoC_db_v1.0_raw.fasta
wget https://example.com/rpoC_db_v1.0_metadata.tsv
```

## Metadata Columns

| Column Name       | Type    | Description                                                                 |
|-------------------|---------|-----------------------------------------------------------------------------|
| `sequence_id`     | String  | Unique identifier (e.g., "rpoC_00001")                                     |
| `accession`       | String  | GenBank/RefSeq accession number (e.g., "NR_123456.1")                      |
| `taxonomy`        | String  | NCBI taxonomy (e.g., "k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria")|
| `source`          | String  | Isolation source (e.g., "Human gut")                                       |
| `length`          | Integer | Sequence length in bp                                                      |
| `qc_status`       | String  | Quality control flag ("PASS", "WARN", or "FAIL")                           |

## Version History

| Version | Release Date   | Changes                         | Sequence Count |
|---------|---------------|----------------------------------|----------------|
| v1.0    | July 10, 2023 | Initial release                 | ///////        |
| v1.1    | May 16, 2024  | Updated using GTDB               | ///////        |
| v2.0    | ////////////  | //////////////                   | ///////        |



