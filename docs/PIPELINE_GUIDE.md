# AMR Profiling Pipeline Guide

## Pipeline Overview
```
Genome Assembly --> Gene Detection (CARD/ResFinder) --> AMR Gene Profiling --> Virulence Factor Analysis --> Clinical Report
```

## Interpreting Results
| Resistance Gene | Antibiotic Class | Clinical Impact |
|----------------|-----------------|----------------|
| blaKPC | Carbapenems | Critical - last resort ABx |
| blaNDM | Carbapenems | Critical - very limited options |
| blaOXA-48 | Carbapenems | High - requires combination therapy |
| mcr-1 | Colistin | Critical - last line resistance |

## Key Databases
- **CARD**: Comprehensive Antibiotic Resistance Database
- **ResFinder**: Acquired resistance gene detection
- **VFDB**: Virulence Factor Database

## Clinical Significance
K. pneumoniae with carbapenem resistance (KPC/NDM) is classified as an **urgent threat** by CDC.
This pipeline helps identify resistance mechanisms for targeted treatment.