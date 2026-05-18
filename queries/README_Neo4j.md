# KDIS / HGBF Neo4j Cypher Queries

This package organizes the Neo4j Cypher queries used for the graph-structural layer of the KDIS/HGBF experimental workflow.

## Scope

The script covers:

1. Database reset
2. Node and edge import
3. Constraints and indexes
4. Import sanity checks
5. Degree, in-degree, and out-degree analysis
6. Cypher-only community approximation for Neo4j Aura Free
7. Optional derived `SAME_COMMUNITY` relationships for visualization
8. Exploratory structural outlier screening
9. Optional Graph Data Science (GDS) queries for deployments where GDS is available

## Expected graph model

```cypher
(:IPNode {id, ip})-[:COMMUNICATES {src_port, dst_port, protocol}]->(:IPNode {id, ip})
```

## Expected CSV files

### nodes.csv
Required columns:

- `id`
- `ip`

### edges.csv
Required columns:

- `src_id`
- `dst_id`

Optional columns:

- `source_port`
- `destination_port`
- `protocol`

## Neo4j Aura Free note

Some Aura Free environments do not include the Graph Data Science plugin. In that case, use the Cypher-only queries:

- `05_DEGREE_CENTRALITY_NEO4J5_AURA`
- `06_OUT_DEGREE`
- `07_IN_DEGREE`
- `08_LOCAL_NEIGHBOR_PROFILE`
- `09_SHARED_NEIGHBOR_COMMUNITY_CANDIDATES`

The GDS queries are included only as optional alternatives.

## Methodological caution

These queries operationalize the graph-structural layer only. They do not by themselves implement the full KDIS/HGBF detection protocol. The full protocol still requires:

- behavioral anomaly extraction,
- entity-level mapping,
- convergence gate logic,
- RCI computation,
- post-hoc label validation,
- and dataset-specific preprocessing documentation.
