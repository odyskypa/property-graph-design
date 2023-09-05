# Property Graph Design for data about Research Publications
Project of Semantic Data Management (SDM) Course for the `Master in Data Science` Program of Universitat Politècnica de Catalunya (UPC)

***

## Modeling, Loading, Evolving

### Modeling

The following text includes the design requirements which must be fullfiled by the `Property Graph` design.

```
We want to create a graph modeling research publications. In this domain, authors write research articles that can be published as scientific papers (papers for short) in the proceedings of a conference/workshop (a conference is a well-established forum while a workshop is typically associated to new trends still being explored), or in a journal. A proceeding is a published record which includes all the papers presented in the conference/workshop. A conference/workshop is organized in terms of editions. Each edition of a conference/workshop is held in a given city (venue) at a specific period of time of a given year. Oppositely, journals do not hold joint meeting events and, like a magazine, a journal publishes accepted papers in terms of volumes. There can be various volumes of a journal per year. A paper can be written by many authors, however only one of them acts as corresponding author. A paper can be cited by another paper (meaning their content is related). A paper relates to one or more topics through the concept of keywords (e.g., property graph, graph processing, data quality, etc.). Keywords are used by readers to quickly identify the main topics discussed in the paper. To this end, any scientific communication must contain an abstract (i.e., a summary of its content). Finally, we also want to include in the graph the concept of review. When a paper is submitted to a conference or a journal, the conference chair or the journal editor assigns a set of reviewers (typically three) to each paper. Reviewers are scientists and therefore they are relevant authors (i.e., published many papers in relevant conferences or journals). Obviously, the author of a certain paper cannot be reviewer of her own paper.
```

In addition the `Queries` below must be taken into account in order to efficiently design the `Property Graph`.

1. Find the top 3 most cited papers of each conference.
2. For each conference find its community: i.e., those authors that have published papers on that conference in, at least, 4 different editions.
3. Find the `impact factors` of the journals in your graph (see https://en.wikipedia.org/wiki/Impact_factor, for the definition of the impact factor).
4. Find the `h-indexes` of the authors in your graph (see https://en.wikipedia.org/wiki/H-index, for a definition of the h-index metric).

After careful consideration of the design requirements and the future queries provided, the following design was implemented:

![Initial Design of Property Graph](/images/initial-design.png)

### Instantiating / Loading

In this chapter, the preprocessing of the data and the loading process to Neo4j[^1] Graph Database Management System are presented. As it was recommended to use real data for the solution of this assignment, the data for the scientific publications were gathered from DBLP[^2]. Due to the complex structure of the data provided by DBLP, we conducted research online and found the representation of the data, in JSON format, from the aminer.org[^3] webpage. The latest version of the data offered from aminer.org was used (V14, updated in 2023). Due to the fact that the provided archive was very large in size (14 GBs), we randomly selected 70000 papers from it. A script for preprocessing and transforming the data into a suitable format for loading the property graph database was implemented. The steps followed during the preprocessing and loading of the data are described here and more details can be found in the [preprocessing_loading.ipynb](preprocessing_loading.ipynb) of the repository.

For each node and relationship of the graph, the appropriate structure of a `CSV` was generated and saved into the project's directory. In that way, bulk loading queries were applied, in order to instantiate the graph and load the preprocessed data. More details about the structure of the `CSV` files and the loading queries can be found in [preprocessing_loading.ipynb](preprocessing_loading.ipynb) file as well.


### Evolving
One key aspect of graph databases is their flexibility to absorb changes in the data coming into the system. Based on the new specifications and demands presented below, the initial graph needed to be updated:

```
In the model and instances you created you were asked to identify the reviewers of a certain paper. Now, we want to change such modeling to store the review sent by each reviewer. A review, apart from its content (i.e., a textual description) has a suggested decision. A paper is accepted for publication if a majority of reviewers supported acceptance. Typically, the
number of reviewers is 3 but every conference or journal may have a different policy on the number of reviewers per paper. Furthermore, we also want to extend the model to store the afiliation of the author. That is an author is afiliated to an organization which can be a university or company.
```
After taking into account the above information, the final design proposed is the following one:

![Updated Design of Property Graph](/images/updated-design.png)

The new schema allows for monitoring information of a `review` as well as the `affiliation` (labeled `org`) of every `Author`. The information, about the `affiliation` and the paper’s `year` of writing, was already provided by our data source, so we just had to update the data instances by merging them. As opposed, synthetic new review decisions and descriptions were generated before updating the graph. More details can be found in [evolving_property_graph.ipynb](evolving_property_graph.ipynb).

***

## Querying
As it was stated in the [Modeling](#modeling) section, it was requested to exploit the property graph by implementing the 4 mentioned queries. The goal was to implement eficient `Cypher queries` (i.e., queries that minimize the number of disk accesses required and the size of intermediate results generated). The final solution can be found in the respective [file](/queries.cypher).

***

## Recommender
The goal of this section is to create a `reviewer recommender` for editors and chairs. The idea is to be able to identify potential reviewers for the ***database*** community. For that, we need to further update the graph with step-wise inferred information to embed the recommendation information for future use. The updated graph can be found in the following figure.

![recommender_design](/images/recommender.png)

Steps on how this solution was developed can be found in the respective [file](/recommender_system.ipynb).

***

## Graph Algorithms
Beyond regular queries, graphs allow the exploitation of graph theory and the use of well-known graph algorithms. For experimenting with this feature, it is presented here an application of `Dijkstra's shortest path finding algorithm` and `Node similarity algorithm`.

### Dijkstra’s Shortest Path
This algorithm is a graph traversal algorithm that finds the shortest path between a starting node and all other nodes in a weighted graph. It works by maintaining a set of visited nodes and a priority queue of unvisited nodes, selecting the node with the smallest tentative distance, and relaxing the adjacent nodes until the destination is reached.

In the specific graph, it is applied to find the lowest cost in terms of citations hops between any two `Paper` nodes. Details about the implementation can be found in the respective [file](/graph_algorithms.ipynb)

### Node Similarity
The Node Similarity algorithm in Neo4j is a similarity measure algorithm that allows to compare nodes based on their relationships with other nodes in the graph. It can be used to identify nodes that are similar to each other in terms of their connectivity patterns. The algorithm works by first creating a matrix that represents the similarity between each pair of nodes in the graph. The matrix is initialized with zeros and then updated with values that reflect the strength of the relationships between nodes. By iterating over the matrix, it compares each pair of nodes and updates the similarity score for each pair based on the similarity scores of their neighbors. The algorithm uses a weighted measure of the similarity between each node's neighbors to compute the overall similarity score between the two nodes. The Node Similarity algorithm is based on the concept of the Jaccard similarity coefficient, which is a measure of the similarity between two sets. In the context of the Node Similarity algorithm, the sets are the sets of neighboring nodes for each pair of nodes being compared.

Details about the specific solution can be found again in the [graph algorithms file](/graph_algorithms.ipynb)

***
Finally, both the project's statement as well as the report of the generated solution can be found [here](/docs/).

[^1]: [https://neo4j.com/](https://neo4j.com/)
[^2]: [https://dblp.uni-trier.de/](https://dblp.uni-trier.de/)
[^3]: [https://www.aminer.org/citation](https://www.aminer.org/citation)

