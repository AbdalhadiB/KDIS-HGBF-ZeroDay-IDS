# KDIS / HGBF Clean Experimental Protocol

## Purpose

This document summarizes the cleaned experimental protocol implemented in `KDIS_Protocol_Clean.ipynb`. It is designed for thesis appendices, article supplementary material, and supervisory review. The aim is to separate the final locked experimental procedure from exploratory notebook work, failed cells, temporary debugging, and obsolete baseline variants.

## Protocol Lock

The experimental protocol is fixed as follows:

1. **Label withholding**: ground-truth labels are not used in threshold derivation, alert generation, convergence computation, or RCI calculation. Labels are introduced only after inference for post-hoc validation.
2. **Behavioral channel**: behavioral anomaly is defined using temporal indicators, primarily `Flow_IAT_Max` and `Fwd_IAT_Std`.
3. **Structural channel**: structural prominence is operationalized using source out-degree at the 95th percentile of the nonzero out-degree distribution (`S_out_p95`).
4. **Entity mapping**: source IP identity is used as the common entity-resolution key for behavioral aggregation and structural convergence.
5. **Evaluation space**: entity-level validation is performed over the full all-node graph entity space: `Src IP ∪ Dst IP`.
6. **Primary configurations**:
   - `B_src`: entity-level behavioral-only candidate set.
   - `S_out_p95`: structural-only prominent source set.
   - `B_src ∧ S_out_p95`: hybrid convergence gate.
7. **Baselines**:
   - Random Forest trained on CIC-IDS2017 and evaluated on WTMC2021 using 57 common features.
   - Isolation Forest evaluated on the same 57-feature common space.
8. **Sensitivity analysis**: P90, P95, P97, and `B_P95 ∧ S_out_μ+2σ` are evaluated.
9. **External boundary test**: UNSW-NB15 is treated as a controlled topological boundary-condition test, not as a full external benchmark replication.

## Experimental Structure

### Stage 1 — CIC-IDS2017 Flow-Level Behavioral Validation

Dataset: CIC-IDS2017 consolidated Parquet file.

Purpose: validate the behavioral channel at individual-flow level.

Key reported outputs:

| Metric | Expected value |
|---|---:|
| Total flows | 2,830,743 |
| Precision | ≈ 0.84 |
| Recall | ≈ 0.25 |
| FPR | ≈ 0.011 |

Interpretation: the behavioral channel is intentionally selective. Low flow-level recall is expected because the detector targets extreme temporal deviations rather than exhaustive attack recovery.

### Stage 2 — WTMC2021 Entity-Level Convergence Validation

Dataset: five WorkingHours CSV files preserving source and destination IP identities.

Purpose: evaluate behavioral aggregation, structural source out-degree prominence, and hybrid convergence at entity level.

Primary reported outputs:

| Configuration | Flagged | TP | FP | Precision | Recall | Lift |
|---|---:|---:|---:|---:|---:|---:|
| B-only | 19 | 8 | 11 | 0.421 | 1.000 | ≈1,003× |
| S-only | 3 | 3 | 0 | 1.000 | 0.375 | ≈2,383× |
| Hybrid | 3 | 3 | 0 | 1.000 | 0.375 | ≈2,383× |

Interpretation: the hybrid gate does not improve over S-only in classification terms. Its contribution is epistemological: it verifies that structurally prominent entities are independently corroborated by behavioral abnormality.

### Stage 3 — Threshold Sensitivity Analysis

Purpose: test whether convergence is an artifact of a single threshold choice.

Policies:

- P90
- P95
- P97
- `B_P95 ∧ S_out_μ+2σ`

Key interpretation: the subset relationship `S ⊂ B` persists across all evaluated policies, showing that the convergence property is not merely a P95 artifact.

### Stage 4 — RF / IF / KDIS Cross-Method Baseline Stability

Purpose: evaluate whether the final convergent entity subset depends on the behavioral detection paradigm.

Behavioral methods:

- KDIS temporal thresholds: 2 features, label-free.
- Random Forest: supervised, trained on CIC-IDS2017, evaluated on WTMC2021 with 57 common features.
- Isolation Forest: unsupervised, evaluated over the same 57 common features.

Primary result:

| Method | Flagged before S | FP before S | Precision before S | After `∧ S_out_p95` |
|---|---:|---:|---:|---|
| KDIS B-only | 19 | 11 | 0.421 | 3 TP, 0 FP |
| RF-only | 22 | 14 | 0.364 | 3 TP, 0 FP |
| IF-only | 28 | 20 | 0.286 | 3 TP, 0 FP |

Interpretation: the structural channel functions as a method-agnostic precision filter under the evaluated entity-level protocol.

### Stage 5 — UNSW-NB15 Topological Boundary Test

Purpose: empirically test the ex-ante theoretical prediction that the structural channel's discriminative capacity is conditioned on the presence of measurable out-degree separation between communication hubs and peripheral nodes.

Role: controlled boundary-condition characterization, not full external validation. UNSW-NB15 is structurally informative for this test because its traffic was generated synthetically through the IXIA PerfectStorm platform using a limited number of source machines, producing a near-uniform out-degree distribution that contrasts with the discontinuous distribution observed in WTMC2021.

Observed interpretation:

- UNSW evaluation graph exhibits low entity diversity (47 source entities).
- Source out-degree is near-uniform (all flagged entities at P95 exhibit out-degree ≈ 10).
- Hybrid precision drops substantially (≈ 0.211) while recall remains 1.000.
- RCI may remain high, but high RCI alone does not guarantee high precision when graph-topological differentiability is weak.

Conclusion: the framework requires sufficient graph-topological heterogeneity for the structural channel to function as a high-precision epistemic filter. This is a substantive theoretical finding, not a deferred validation task. Subsequent cross-dataset work should prioritize topologically heterogeneous environments rather than additional synthetically generated benchmarks that share UNSW-NB15's generative properties.

## Removed from the Working Notebook

The clean protocol excludes:

- Failed `wget` downloads and 404 errors.
- Path-discovery cells used only for debugging.
- Incorrect UNSW header-loading attempt.
- Obsolete structural experiments based on small sampled NetworkX graphs.
- Earlier entity-space versions that incorrectly used only source IPs or collapsed the graph entity space.
- Redundant Isolation Forest experiments using inconsistent feature spaces.
- Console outputs, temporary checks, and exploratory cells not part of the final locked protocol.

## Recommended Use

### In the thesis

Use this protocol as an appendix or supplementary methodological artifact. The thesis should cite the protocol as evidence of reproducibility but should not include the entire code body in the main chapter.

### In the paper

Use the notebook as supplementary material. The paper should cite only the locked protocol logic, thresholds, formulas, and final result tables.

### In supervisory discussion

Use the protocol to demonstrate that the experimental results are not ad hoc: the workflow fixes datasets, thresholds, entity mapping, baselines, evaluation logic, and post-hoc validation policy.
