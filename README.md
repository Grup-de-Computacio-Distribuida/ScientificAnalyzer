# Scientific Analyzer

This projects aims to analyze scientific papers and extract relevant information.

| Research Group           | University               |
|--------------------------|--------------------------|
| 🔬 **Grup de Computació Distribuïda** | 🎓 *Universitat de Lleida*         |

**Authors**:

- 👤 [Sergi Lopez](https://github.com/slopez1)  

## Table of Contents

- [Usage](#usage)
- [TODO](#todo)

## Usage

### Search terms

```bash
make INI=2010 END=2019 TERMS="machine learning" TAG="ml" search
```

where:

- `INI` is the initial year
- `END` is the final year
- `TERMS` is the search terms
- `TAG` is the tag to be used as container name and data folder

### Load data

```bash
make TAG="ml" parse
```

where:

- `TAG` is the tag to be used as container name and data folder

### Visualize data

```bash
make TAG="ml" visualize
```

where:

- `TAG` is the tag to be used as container name and data folder

## TODO

- Persist logs after container deletion
- Notify when job is done
- Update repo automatically [@DONE]
  - Cron job to check for updates
  - Update repo (git pull)
  - Rebuild images