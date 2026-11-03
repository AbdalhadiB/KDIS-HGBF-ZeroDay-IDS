# KDIS / HGBF Reproducibility Package

This repository contains cleaned reproducibility assets for research on the **Knowledge-Driven Information System (KDIS)** and the **Hybrid Graph–Behavioral Framework (HGBF)** for explainable intrusion detection.

The repository currently supports two related experimental tracks:

1. the original KDIS/HGBF graph–behavioral protocol; and  
2. the frozen-policy windowed-flow evaluation and its post-review structural ablation analysis.

The original KDIS/HGBF assets document the earlier graph–behavioral experimental protocol developed within the broader doctoral research on knowledge-driven intrusion detection. These materials are retained as a historical and reproducibility record of the original experimental design and should not be interpreted as corresponding to a single fixed manuscript title.

The later frozen-policy windowed-flow assets support the current study:

> Albluwi et al. (2026). *Windowed Flow Operators for Intrusion Detection: Frozen-Policy Validation and Behavioral Corroboration Limits.*

Additional assets under `notebooks/ablation/`, `results/ablation/`, and `reproducibility/environments/` support the study:

> Albluwi et al. (2026). *Windowed Flow Operators for Intrusion Detection: Frozen-Policy Validation and Behavioral Corroboration Limits.*

---

## Repository Structure

```text
KDIS_GitHub_Package/
├── notebooks/
│   ├── KDIS_Protocol_Clean.ipynb
│   │   # Locked original Python/Colab KDIS/HGBF protocol
│   │
│   └── ablation/
│       ├── WTMC2021_Frozen_Validation_Ablation.ipynb
│       └── CSECICIDS2018_Frozen_Validation_Ablation.ipynb
│
├── protocol/
│   ├── KDIS_Experimental_Protocol_Clean.md
│   └── KDIS_experimental_protocol.pdf
│
├── results/
│   └── ablation/
│       ├── wtmc_structural_ablation_baselines.csv
│       ├── wtmc_structural_ablation_diagnostics.csv
│       ├── csecic2018_structural_ablation_baselines.csv
│       └── csecic2018_structural_ablation_diagnostics.csv
│
├── reproducibility/
│   └── environments/
│       ├── WTMC2021_ablation_runtime_environment.txt
│       └── CSECICIDS2018_ablation_runtime_environment.txt
│
├── figures/
│   └── extracted paper figures
│
├── queries/
│   ├── KDIS_Neo4j_Cypher_Cleaned.cypher
│   └── README_Neo4j.md
│
├── docs/
│   └── package_manifest.json
│
├── requirements.txt
├── LICENSE
├── .gitignore
└── README.md
```

---

## Scope

The repository separates the original KDIS/HGBF protocol from later confirmatory and diagnostic analyses so that the provenance of each experimental result remains explicit.

### 1. Original Python / Colab Protocol (`notebooks/KDIS_Protocol_Clean.ipynb`)

Implements the analytical logic of the original KDIS/HGBF framework:

- Behavioral anomaly extraction (`Flow_IAT_Max`, `Fwd_IAT_Std` P95 thresholding)
- Entity-level aggregation
- Structural threshold application (`S_out_p95` applied to Neo4j-exported out-degrees)
- Hybrid convergence gate (`S ∧ B`)
- RCI computation using the Jaccard coefficient between independently derived sets
- RF / IF / KDIS baseline comparison
- UNSW-NB15 boundary-condition validation

This notebook represents the locked original protocol and is not modified by the later ablation analysis.

### 2. Neo4j Cypher Layer (`queries/`)

Implements graph construction and raw centrality export:

- Schema setup and CSV import
- Directed graph construction over IP communication topology
- Degree / in-degree / out-degree computation
- Optional Graph Data Science (GDS) procedures where available
- Cypher-only fallbacks for Neo4j Aura Free deployments

### 3. Figures and Visual Assets (`figures/`)

Contains extracted publication figures and structural visualizations used in the research, including:

- Degree-distribution plots
- Structural convergence subgraphs
- Topological boundary-condition visualizations
- Framework architecture diagrams

**Note on architecture:** Threshold computation and threshold application are deliberately separated. Cypher produces raw out-degree values; the Python notebook applies the `S_out_p95` criterion to those values and merges the resulting structural set with the behavioral set. This separation makes the framework portable across graph databases such as Neo4j, Memgraph, and NetworkX without modifying the analytical logic.

---

## Frozen-Policy Windowed-Flow Analysis

The later windowed-flow study evaluates structural and behavioral detection at the source-hour level.

Its structural channel contains two transparent operators:

- `S_BV`: burst–volume detection based on jointly extreme active-span flow rate and flow count.
- `S_REP`: destination-repetition detection based on an extreme repetition ratio with an auxiliary flow-count guard.

Their union forms the structural channel:

```text
S_T = S_BV OR S_REP
```

The protocol uses a **frozen-policy** design. Operator definitions, feature identities, window duration, percentile policies, and fusion rules are fixed before external evaluation.

Numeric threshold values themselves are **not transferred unchanged between environments**. They are estimated from the declared calibration population of each environment using the frozen percentile policies.

Accordingly, this should not be interpreted as zero-calibration transfer or as direct portability of fixed numerical threshold values.

---

## Post-Review Structural Ablation

A post-review structural ablation analysis is provided under:

```text
notebooks/ablation/
results/ablation/
reproducibility/environments/
```

The purpose of this analysis is to determine whether the conjunctive structure of the frozen structural operators provides measurable value beyond the individual threshold components.

The following single-component baselines are evaluated:

- `COUNT_ONLY_P99`: flow count ≥ calibration P99
- `RATE_ONLY_P99`: active-span flow rate ≥ calibration P99
- `REP_ONLY_P99`: destination-repetition ratio ≥ calibration P99

These are compared against the original frozen-policy operators:

- `S_BV = RATE_ONLY_P99 AND COUNT_ONLY_P99`
- `S_REP = REP_ONLY_P99 AND flow-count P50 guard`
- `S_T = S_BV OR S_REP`

The same source-hour representation, calibration populations, ground-truth definitions, and evaluation metrics used in the main experiment are retained.

### Methodological Status

This ablation analysis is **post-hoc and diagnostic**.

It was not used to redesign, retune, or redefine `S_BV`, `S_REP`, or `S_T`, and it does not alter the original frozen-policy external evaluation.

The distinction is important: the ablation assesses the contribution of the constituent conditions after completion of the original external validation rather than retrospectively optimizing the detector on the validation environment.

### Main Ablation Findings

The ablation provides strong empirical support for the conjunctive design of `S_BV`.

On WTMC2021, `S_BV` reduced false positives relative to both the rate-only and count-only baselines while retaining the same true-positive count as the rate-only baseline.

On Improved CSE-CIC-IDS2018:

```text
RATE_ONLY_P99:
    Flagged = 8,439
    TP      = 50
    FP      = 8,389
    Precision = 0.0059

S_BV:
    Flagged = 198
    TP      = 50
    FP      = 148
    Precision = 0.2525
```

Thus, the burst–volume conjunction removed 8,241 false-positive source-hours relative to the rate-only rule without losing any of its 50 true positives.

The `S_REP` count guard exhibited a different pattern.

On Improved CSE-CIC-IDS2018, `REP_ONLY_P99` and `S_REP` produced identical detection results. On WTMC2021, the P50 count guard removed two true-positive windows without removing any false positives.

The ablation therefore indicates that the principal discriminative contribution of `S_REP` arises from the extreme destination-repetition criterion, whereas the auxiliary P50 flow-count guard did not demonstrate independent selectivity in the evaluated environments.

The original `S_REP` definition is nevertheless retained unchanged to preserve the integrity of the frozen-policy experiment.

---

## Reproducibility Environments

Runtime snapshots for the post-review reproducibility reruns are provided under:

```text
reproducibility/environments/
```

The snapshots record:

- Python version
- Operating-system and kernel information
- CPU architecture
- Available RAM
- Disk environment
- GPU/accelerator availability
- NumPy
- pandas
- SciPy
- scikit-learn
- DuckDB
- NetworkX
- PyArrow
- complete `pip freeze` output

These files document the runtime environments used for the later reproducibility reruns and ablation analyses.

They should **not** be interpreted as retrospective claims that every earlier development-stage experiment was executed under exactly the same software versions.

---

## Quick Start

### Prerequisites

For the original KDIS/HGBF protocol:

- Python 3.12+ with the dependencies listed in `requirements.txt`
- Google Colab or a local Jupyter environment
- Neo4j 5.x, either local, server-based, or Aura, with optional GDS support

The original reported experiments were performed under the environment documented for that protocol. Later ablation reruns use the environments recorded separately under `reproducibility/environments/`.

### Installation

```bash
git clone https://github.com/AbdalhadiB/KDIS-HGBF-ZeroDay-IDS.git
cd KDIS-HGBF-ZeroDay-IDS
pip install -r requirements.txt
```

### Reproducing the Original KDIS/HGBF Results

1. Obtain the required datasets:
   - **CIC-IDS2017**:  
     https://www.unb.ca/cic/datasets/ids-2017.html
   - **WTMC2021**: generated using the public relabeling code released by Engelen et al. (2021):  
     https://github.com/GintsEngelen/WTMC2021-Code
   - **UNSW-NB15**:  
     https://research.unsw.edu.au/projects/unsw-nb15-dataset

2. Update paths in:

```text
notebooks/KDIS_Protocol_Clean.ipynb
```

3. Run the notebook cells in order. The protocol is locked rather than exploratory.

4. Optionally deploy the structural graph channel using:

```text
queries/KDIS_Neo4j_Cypher_Cleaned.cypher
```

Export the resulting out-degree values and load them into the Python protocol for structural–behavioral convergence analysis.

### Reproducing the Structural Ablation

Run:

```text
notebooks/ablation/WTMC2021_Frozen_Validation_Ablation.ipynb
```

and:

```text
notebooks/ablation/CSECICIDS2018_Frozen_Validation_Ablation.ipynb
```

The generated ablation outputs corresponding to the reported results are retained under:

```text
results/ablation/
```

---

## Reproducibility Notes

### Original KDIS/HGBF Protocol

Within the original locked KDIS/HGBF protocol, ground-truth labels are withheld during inference-stage structural, behavioral, convergence, and RCI decisions and are introduced post-hoc for evaluation according to the protocol documented in:

```text
protocol/KDIS_Experimental_Protocol_Clean.md
```

### Frozen-Policy Windowed-Flow Study

The later windowed-flow experiment follows a different and explicitly documented calibration design.

WTMC2021 uses a temporally isolated benign calibration interval.

Improved CSE-CIC-IDS2018 uses a predeclared ordinary-benign calibration population constructed with label assistance. Labels are not used to modify external-evaluation operator definitions, percentile policies, fusion rules, or source-window decisions after the frozen policy has been established.

This distinction is intentional and prevents the original KDIS/HGBF reproducibility statement from being incorrectly generalized to the later frozen-policy experiment.

---

## Data Availability

Datasets are not redistributed in this repository. Users should obtain them from their original public providers.

- **CIC-IDS2017**  
  Sharafaldin, Lashkari, and Ghorbani (2018):  
  https://www.unb.ca/cic/datasets/ids-2017.html

- **WTMC2021 relabeling**  
  Engelen, Rimmer, and Joosen (2021):  
  https://github.com/GintsEngelen/WTMC2021-Code

- **Improved CSE-CIC-IDS2018**  
  Liu et al. (2022):  
  https://intrusion-detection.distrinet-research.be/CNS2022/CSECICIDS2018.html

- **UNSW-NB15**  
  UNSW Cyber Range Lab:  
  https://research.unsw.edu.au/projects/unsw-nb15-dataset

The datasets remain subject to the respective providers' licenses and usage conditions.

---

## Citation

If you use the original KDIS/HGBF code, protocol, or results, please cite the corresponding study when publication details become available.

```bibtex
@misc{albluwi2026kdisrepo,
  author       = {Albluwi, Abdulhadi},
  title        = {KDIS / HGBF Reproducibility Package},
  year         = {2026},
  howpublished = {GitHub repository},
  note         = {Reproducibility assets for knowledge-driven and hybrid graph--behavioral intrusion detection research}
}
```

For the frozen-policy windowed-flow analysis and structural ablation, please cite:

```bibtex
@article{albluwi2026windowed,
  title   = {Windowed Flow Operators for Intrusion Detection:
             Frozen-Policy Validation and Behavioral Corroboration Limits},
  author  = {Albluwi, Abdulhadi and Marie, Mohamed I. and Suleiman, Helal A.},
  journal = {[Target Journal]},
  year    = {2026},
  doi     = {[DOI placeholder]}
}
```

Where appropriate, related prior work includes:

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
```

```bibtex
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

This code is released under the MIT License. See `LICENSE` for full terms.

The MIT License applies only to the code contained in this repository. The underlying datasets remain subject to their respective providers' licenses and usage conditions.

---

## Contact

For methodological questions, replication issues, or reproducibility assistance, please open an issue on the repository's GitHub page.
