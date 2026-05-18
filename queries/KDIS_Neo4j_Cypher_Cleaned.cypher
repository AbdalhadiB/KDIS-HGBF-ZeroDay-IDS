// ============================================================================
// KDIS / HGBF Neo4j Cypher Research Queries
// Purpose: Graph construction and structural analysis for zero-day IDS research
// Compatibility: Neo4j 5.x / Neo4j Aura Free where noted
// Relationship model: (:IPNode)-[:COMMUNICATES]->(:IPNode)
//
// Architecture note:
//   This Cypher layer handles graph construction and raw centrality export
//   only. Threshold computation (S_out_p95) and threshold application
//   (structural prominence flagging) are performed in the accompanying
//   Python notebook (KDIS_Protocol_Clean.ipynb) on the out-degree values
//   exported from Neo4j. This separation keeps the analytical logic
//   portable across graph backends (Neo4j, Memgraph, NetworkX).
// ============================================================================


// ============================================================================
// 00_RESET_DATABASE_OPTIONAL.cypher
// WARNING: destructive. Use only on an empty/rebuildable database.
// ============================================================================
MATCH (n) DETACH DELETE n;


// ============================================================================
// 01_SCHEMA_AND_INDEXES.cypher
// Run before importing large datasets when possible.
// ============================================================================
CREATE CONSTRAINT ipnode_id_unique IF NOT EXISTS
FOR (n:IPNode)
REQUIRE n.id IS UNIQUE;

CREATE INDEX ipnode_ip_index IF NOT EXISTS
FOR (n:IPNode)
ON (n.ip);


// ============================================================================
// 02_IMPORT_NODES.cypher
// Expected CSV: nodes.csv
// Required columns: id, ip
// Neo4j Aura: upload nodes.csv through Import, then use file:///nodes.csv.
// ============================================================================
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (n:IPNode {id: toInteger(row.id)})
SET n.ip = row.ip;


// ============================================================================
// 03_IMPORT_EDGES.cypher
// Expected CSV: edges.csv
// Required columns: src_id, dst_id
// Optional columns: source_port, destination_port, protocol
// ============================================================================
LOAD CSV WITH HEADERS FROM 'file:///edges.csv' AS row
MATCH (a:IPNode {id: toInteger(row.src_id)})
MATCH (b:IPNode {id: toInteger(row.dst_id)})
MERGE (a)-[r:COMMUNICATES]->(b)
SET
  r.src_port = row.source_port,
  r.dst_port = row.destination_port,
  r.protocol = row.protocol;


// ============================================================================
// 04_DATA_SANITY_CHECKS.cypher
// Use these to verify graph import completeness.
// ============================================================================
MATCH (n:IPNode)
RETURN count(n) AS ip_nodes;

MATCH (:IPNode)-[r:COMMUNICATES]->(:IPNode)
RETURN count(r) AS communicates_relationships;

MATCH (a:IPNode)-[r:COMMUNICATES]->(b:IPNode)
RETURN a.ip AS source_ip, b.ip AS target_ip, r.protocol AS protocol
LIMIT 20;


// ============================================================================
// 05_DEGREE_CENTRALITY_NEO4J5_AURA.cypher
// Undirected degree: incoming + outgoing.
// Neo4j 5-compatible replacement for deprecated/invalid size((n)--()) pattern.
// ============================================================================
MATCH (n:IPNode)
WITH n, COUNT { (n)--() } AS degree
RETURN n.ip AS ip, degree
ORDER BY degree DESC
LIMIT 20;


// ============================================================================
// 06_OUT_DEGREE.cypher
// Structural prominence candidate extraction based on outgoing communication.
// ============================================================================
MATCH (src:IPNode)-[:COMMUNICATES]->(dst:IPNode)
WITH src, count(dst) AS out_degree
RETURN src.ip AS source_ip, out_degree
ORDER BY out_degree DESC
LIMIT 20;


// ============================================================================
// 07_IN_DEGREE.cypher
// Target/server prominence or inbound concentration.
// ============================================================================
MATCH (src:IPNode)-[:COMMUNICATES]->(dst:IPNode)
WITH dst, count(src) AS in_degree
RETURN dst.ip AS target_ip, in_degree
ORDER BY in_degree DESC
LIMIT 20;


// ============================================================================
// 08_LOCAL_NEIGHBOR_PROFILE.cypher
// Local-domain neighbor profile. Adjust prefix if dataset uses another subnet.
// ============================================================================
MATCH (a:IPNode)-[:COMMUNICATES]->(b:IPNode)
WHERE a.ip STARTS WITH '192.168.' AND b.ip STARTS WITH '192.168.'
WITH a, collect(DISTINCT b.ip) AS neighbors
RETURN
  a.ip AS node,
  size(neighbors) AS neighbor_count,
  neighbors[0..10] AS sample_neighbors
ORDER BY neighbor_count DESC
LIMIT 20;


// ============================================================================
// 09_SHARED_NEIGHBOR_COMMUNITY_CANDIDATES.cypher
// Cypher-only community approximation for Aura Free without GDS.
// threshold_shared_neighbors should be adjusted empirically.
// ============================================================================
MATCH (a:IPNode)-[:COMMUNICATES]->(b:IPNode)<-[:COMMUNICATES]-(c:IPNode)
WHERE a <> c
  AND a.ip STARTS WITH '192.168.'
  AND c.ip STARTS WITH '192.168.'
WITH a, c, count(DISTINCT b) AS shared_neighbors
WHERE shared_neighbors > 10
RETURN
  a.ip AS node_1,
  c.ip AS node_2,
  shared_neighbors
ORDER BY shared_neighbors DESC
LIMIT 50;


// ============================================================================
// 10_CREATE_SAME_COMMUNITY_RELATIONSHIPS_OPTIONAL.cypher
// Optional visualization-only relationship. Do not use as raw evidence unless
// documented as a derived relationship.
// ============================================================================
MATCH (a:IPNode)-[:COMMUNICATES]->(b:IPNode)<-[:COMMUNICATES]-(c:IPNode)
WHERE a <> c
  AND a.ip STARTS WITH '192.168.'
  AND c.ip STARTS WITH '192.168.'
WITH a, c, count(DISTINCT b) AS shared_neighbors
WHERE shared_neighbors > 10
MERGE (a)-[r:SAME_COMMUNITY]->(c)
SET r.weight = shared_neighbors;


// ============================================================================
// 11_VIEW_SAME_COMMUNITY.cypher
// ============================================================================
MATCH (n:IPNode)-[r:SAME_COMMUNITY]->(m:IPNode)
RETURN n, r, m
LIMIT 200;


// ============================================================================
// 12_SIMPLE_STRUCTURAL_OUTLIER_SCREEN.cypher
// Heuristic only. Not equivalent to zero-day detection.
// Use only as an exploratory structural screen.
// ============================================================================
MATCH (n:IPNode)-[r:COMMUNICATES]->()
WITH
  n,
  count(r) AS out_degree,
  collect(DISTINCT r.protocol) AS protocols
WHERE out_degree < 3 OR size(protocols) > 5
RETURN
  n.ip AS suspicious_ip,
  out_degree,
  protocols
ORDER BY out_degree ASC
LIMIT 20;


// ============================================================================
// 13_SCHEMA_VISUALIZATION.cypher
// ============================================================================
CALL db.schema.visualization();


// ============================================================================
// 14_GDS_OPTIONAL_PROJECT_GRAPH.cypher
// Requires Neo4j Graph Data Science plugin.
// Not available in many Aura Free deployments.
// ============================================================================
CALL gds.graph.drop('nids_graph', false);

CALL gds.graph.project(
  'nids_graph',
  'IPNode',
  {
    COMMUNICATES: {
      type: 'COMMUNICATES',
      orientation: 'UNDIRECTED'
    }
  }
);


// ============================================================================
// 15_GDS_OPTIONAL_DEGREE.cypher
// Requires GDS.
// ============================================================================
CALL gds.degree.stream('nids_graph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).ip AS ip, score AS degree
ORDER BY degree DESC
LIMIT 20;


// ============================================================================
// 16_GDS_OPTIONAL_PAGERANK.cypher
// Requires GDS.
// ============================================================================
CALL gds.pageRank.stream('nids_graph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).ip AS ip, score AS pagerank
ORDER BY pagerank DESC
LIMIT 20;


// ============================================================================
// 17_GDS_OPTIONAL_LOUVAIN.cypher
// Requires GDS.
// ============================================================================
CALL gds.louvain.stream('nids_graph')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).ip AS ip, communityId
ORDER BY communityId, ip
LIMIT 50;
