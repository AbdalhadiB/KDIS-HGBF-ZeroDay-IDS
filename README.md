# KDIS / HGBF Reproducibility Package

This repository contains the cleaned reproducibility assets for the **Knowledge-Driven Information System (KDIS)** / **Hybrid Graph–Behavioral Framework (HGBF)** experiments, supporting the paper:

> Albluwi et al. (2026). *Cross-Representational Corroborative Reasoning for Explainable Zero-Day Intrusion Detection: A Knowledge-Driven Hybrid Graph–Behavioral Framework.*

---

## Repository Structure

```text
KDIS_GitHub_Package/
├── notebooks/
│   └── KDIS_Protocol_Clean.ipynb         # Locked Python/Colab protocol
├── protocol/
│   ├── KDIS_Experimental_Protocol_Clean.md
│   └── KDIS_experimental_protocol.pdf
├── figures/
│   └── extracted paper figures
├── queries/
│   ├── KDIS_Neo4j_Cypher_Cleaned.cypher  # Graph construction & raw metrics
│   └── README_Neo4j.md
├── docs/
│   └── package_manifest.json
├── requirements.txt
├── LICENSE
├── .gitignore
└── README.md
```

---

## Scope

The package separates two complementary components, each handling a distinct
analytical concern:

### 1. Python / Colab Protocol (`notebooks/`)

Implements the analytical logic of the framework:

- Behavioral anomaly extraction (Flow_IAT_Max, Fwd_IAT_Std P95 thresholding)
- Entity-level aggregation
- **Structural threshold application** (S_out_p95 applied to Neo4j-exported out-degrees)
- Hybrid convergence gate (S ∧ B)
- RCI computation (Jaccard coefficient between independently derived sets)
- RF / IF / KDIS baseline comparison
- UNSW-NB15 boundary test (topological boundary-condition validation)

### 2. Neo4j Cypher Layer (`queries/`)

Implements graph construction and raw centrality export:

- Schema setup and CSV import
- Directed graph construction over IP communication topology
- Degree / in-degree / out-degree computation
- Optional Graph Data Science (GDS) procedures where available
- Cypher-only fallbacks for Neo4j Aura Free deployments

### 3. Figures and Visual Assets (`figures/`)

Contains extracted publication figures and structural visualizations used in the paper, including:

- Degree distribution plots
- Structural convergence subgraphs
- Topological boundary-condition visualizations
- Framework architecture diagrams

**Note on architecture**: Threshold *computation* and threshold *application*
are deliberately separated. Cypher produces raw out-degree values; the
Python notebook applies the S_out_p95 criterion to those values and merges
the resulting structural set with the behavioral set. This separation makes
the framework portable across graph databases (Neo4j, Memgraph, NetworkX)
without modifying the analytical logic.

---

## Quick Start

### Prerequisites

- Python 3.12+ with the dependencies listed in `requirements.txt`
  (the paper's results were produced under Python 3.12.13 in Google Colab)
- Google Colab or local Jupyter environment
- Neo4j 5.x (local desktop, server, or Aura) with optional GDS plugin

### Installation

```bash
git clone https://github.com/ِAbdalhadiB/KDIS-HGBF-ZeroDay-IDS.git
cd KDIS-HGBF-ZeroDay-IDS
pip install -r requirements.txt
```

### Reproducing the Results

1. **Obtain the datasets** (not redistributed in this repository):
   - **CIC-IDS2017**: https://www.unb.ca/cic/datasets/ids-2017.html
   - **WTMC2021 (relabeled CIC-IDS2017)**: Generated using the public code
     of Engelen et al. (2021) at https://github.com/GintsEngelen/WTMC2021-Code

2. **Update paths** in `notebooks/KDIS_Protocol_Clean.ipynb` to point to your
   local dataset locations (the notebook currently uses Google Drive paths).

3. **Run the notebook** cells in order. The protocol is locked, not exploratory.

4. **(Optional) Deploy the structural channel** by executing
   `queries/KDIS_Neo4j_Cypher_Cleaned.cypher` in Neo4j Browser. Export the
   out-degree results to CSV and load them into the notebook for the
   structural-behavioral convergence step.

---

## Reproducibility Note

Ground-truth labels are **withheld** during:

- Behavioral threshold derivation
- Alert generation
- Convergence computation
- RCI computation
- Structural threshold derivation

Labels are introduced **only after inference** for post-hoc validation. This
protocol is implemented uniformly in `KDIS_Protocol_Clean.ipynb` and detailed
formally in `protocol/KDIS_Experimental_Protocol_Clean.md`.

---

## Data Availability

Datasets are not redistributed in this repository. Users should obtain the
original datasets from their public providers:

- **CIC-IDS2017** (Sharafaldin, Lashkari, & Ghorbani, 2018):
  https://www.unb.ca/cic/datasets/ids-2017.html — subject to the dataset's
  usage agreement.
- **WTMC2021 relabeling** (Engelen, Rimmer, & Joosen, 2021):
  https://github.com/GintsEngelen/WTMC2021-Code — apply the relabeling code
  to raw CIC-IDS2017 PCAP files.
- **UNSW-NB15** (Moustafa & Slay, 2015): available from UNSW Cyber Range
  Lab at https://research.unsw.edu.au/projects/unsw-nb15-dataset

---

## Citation

If you use this code, protocol, or results in your research, please cite the
accompanying paper:

```bibtex
@article{albluwi2026kdis,
  title   = {Cross-Representational Corroborative Reasoning for Explainable 
             Zero-Day Intrusion Detection: A Knowledge-Driven Hybrid 
             Graph--Behavioral Framework},
  author  = {Albluwi, Abdulhadi and [co-authors]},
  journal = {[Target Journal]},
  year    = {2026},
  doi     = {[DOI placeholder]}
}
```

And, where appropriate, the prior author work referenced by this framework:

```bibtex
@article{albluwi2025dns,
  title   = {A DNS Threat Awareness Practical Framework Using Knowledge Graph},
  author  = {Albluwi, Abdulhadi and Albalawi, Ubaid and Elfaki, Abdelrahman Osman},
  journal = {Journal of Information Science and Engineering},
  volume  = {41},
  number  = {5},
  pages   = {1239--1261},
  year    = {2025},
  doi     = {10.6688/JISE.202509_41(5).0011}
}

@article{elfaki2026firewall,
  title   = {Explainable Logic-Driven Firewall Anomaly Detection with Knowledge 
             Graph Visualization and Machine Learning Validation},
  author  = {Elfaki, Abdelrahman Osman and Albluwi, Abdulhadi and Aljaedi, Amer 
             and Nerma, Mohamed H. M.},
  journal = {Electronics},
  volume  = {15},
  number  = {8},
  pages   = {1714},
  year    = {2026},
  doi     = {10.3390/electronics15081714}
}
```

---


## License

This code is released under the MIT License — see `LICENSE` for full terms.
Note that this license applies **only to the code in this repository**.
The underlying datasets remain subject to their respective providers' usage
terms.

---

## Contact

For methodological questions or replication assistance, please open an issue
on the repository's GitHub page.
