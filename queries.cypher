// Find the top 3 most cited papers of each conference
MATCH (c:Conference)<-[:published_in_conference]-(p:Paper)
OPTIONAL MATCH (p)<-[:cites]-(cp:Paper)
WITH c, p, COUNT(DISTINCT cp) AS citation_count
ORDER BY c.name, citation_count DESC
WITH c, COLLECT(p)[..3] AS top_papers
RETURN c.name AS conference_name, [paper IN top_papers | paper.title] AS top_paper_titles;

// For each conference find its community: i.e., those authors that have published papers on that conference in, at least, 4 different editions
MATCH (a:Author)-[:wrote]->(p:Paper)-[pub:published_in_conference]
->(c:Conference)
WITH c, a, collect(DISTINCT pub.city + pub.year) as edition
WHERE size(edition) >= 4
RETURN c.name AS conference, collect(DISTINCT a.name) AS community, edition;


// Find the impact factors of the journals
MATCH (j:Journal)
OPTIONAL MATCH (p:Paper)-[pub:published_in_journal]->(j:Journal)
WHERE pub.year = $year_2 OR pub.year = $year_1
OPTIONAL MATCH (p)<-[:cites]-(cp1:Paper{year:$year})
WITH j, p, COUNT(DISTINCT cp1) AS citation_count
WITH j, COUNT(DISTINCT p) AS paper_count, SUM(citation_count) AS citation_sum
RETURN j.name AS journal_name,
CASE WHEN paper_count = 0 THEN 0 ELSE citation_sum/paper_count END AS impact_factor 
ORDER BY impact_factor desc;


// Find the h-indexes of the authors
MATCH (a:Author)-[:wrote]->(p:Paper)<-[:cites]-(c:Paper)
WITH a, p, COUNT(DISTINCT c) AS citations
WITH a, COLLECT({paper: p, citations: citations}) AS papers
WITH a, REDUCE(s = {index: 0, h: 0}, x IN papers | 
CASE WHEN x.citations >= s.index THEN {index: s.index + 1, h: s.index + 1} 
ELSE s END) AS hIndex
RETURN a.name AS author_name, hIndex.h AS h_index ORDER BY h_index DESC;

