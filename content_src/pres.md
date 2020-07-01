# ChainRules

.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]

.row[
.col[**Lyndon White**]
.col[Research Software Engineer]
] 

.row[
.image-30[![JuliaDiff](https://avatars3.githubusercontent.com/u/7750915?s=200&v=4)]
.col[JuliaCon 2020]
.image-50[![InveniaLabs](https://www.invenia.ca/wp-content/themes/relish_theme/img/labs-logo.png)]
]

---

# Ya Humans
.row[
.image-60[![lyndon](humans/lyndon.png)]
.image-60[![will](humans/will.png)]
.image-60[![nick](humans/nick.png)]
.image-60[![matt](humans/matt.png)]
]

.row[
.col[.image-50[![jarret](humans/jarret.jpg)] Jarret Revels]
.col[.image-50[![alex](humans/alex.png)] Alex Arslan]
.col[.image-50[![seth](humans/seth.jpg)] Seth Axen]
]
.row[
.col[.image-40[![simeon](humans/simeon.png)] Simeon Schaub]
.col[.image-40[![yingbo](humans/yingbo.png)] Yingbo Ma]
]

---

# Package Graph

```@setup pkggraph
using Plots, GraphRecipes, LightGraphs
gr(format=:png)

function index(names)
    indexes = ntuple(identity, length(names))
    return (; (names .=> indexes) ...)
end

rule_definers = [:ChainRules, :DistributionsDiff, :Hankel, :DiffEqBase, :OtherPackages]
ads = [:Zygote, :ForwardDiff2, :OtherADs]
theoretical = [:OtherADs, :OtherPackages]

links = [
    :FiniteDifferences => :ChainRulesTestUtils;
    :ChainRulesTestUtils .=> [:ChainRules, :Hankel, :OtherPackages];
    :ChainRulesCore .=> [:ChainRulesTestUtils; rule_definers];
    :ChainRules .=> ads;
]

nodes = union(first.(links), last.(links))
node_index = index(nodes)

function color(x)
    x in ads ? :red :
    x in rule_definers ? :purple :
    :green
end 

dep_graph = SimpleDiGraph([Edge(node_index[s], node_index[d]) for (s, d) in links])
dep_graph_plot = graphplot(
    dep_graph;
    method=:tree,
    shape=:circle,
    nodesize=0.15,
    axis_buffer=0.15,
    names = string.(nodes),   
    nodestrokecolor = color.(nodes),
    nodecolor= ifelse.(nodes .∈ Ref(theoretical), :lightgrey, :white),
    nodestrokewidth=3,
    linewidth=3,
    size=(1000,520),
)
```
```@example pkggraph
dep_graph_plot  # hide
```