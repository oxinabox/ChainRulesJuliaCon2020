
# What is ChainRules?

 - The ChainRules Project
    - Make an **AD engine agnostic** collection of rules
    - and to see it deployed in all **AD engines**
 - The **ChainRulesCore.jl** Package:
    - Logic for defining rules
    - Packages defining rules only need this.
 - The **ChainRules.jl** Package:
    - The rules for **Base** + **StdLibs**
    - only **AD engines** need this



# What is a `frule`? 

.unfunfact[You can't fuse rrules/pullbacks, because you need the gradient of the step that comes after. Which in turn needs the primal output of this step.]

---



# ChainRulesTestUtils Graph

```@setup pkggraph

test_links = [
    :ChainRulesCore .=> :ChainRulesTestUtils;
    :FiniteDifferences .=> :ChainRulesTestUtils;
    [:ChainRulesCore, :ChainRulesTestUtils] .=> :ChainRules;
#    [:ChainRulesCore, :ChainRulesTestUtils] .=> :OtherPackages;
]

test_nodes = union(first.(test_links), last.(test_links))

test_graph = SimpleDiGraph([Edge(index(test_nodes)[s], index(test_nodes)[d]) for (s, d) in test_links])
Random.seed!(4)
test_graph_plot = graphplot(
    test_graph;
    method=:tree,
    shape=:circle,
    nodesize=0.24,
    axis_buffer=0.15,
    names = string.(test_nodes),   
    nodestrokecolor = color.(test_nodes),
    nodecolor= ifelse.(test_nodes .∈ Ref(theoretical), :lightgrey, :white),
    nodestrokewidth=3,
    linewidth=3,
    size=(3000, 520),
    xlims=(-1, 7),
)
```
```@example pkggraph
test_graph_plot  # hide
```


## ChainRules as an interface for AD

So we need to provide an interface by which one specifies how to call back into AD from a ChainRule.
Probably by providing a method that exactly matches the behavour of `rrule` / `frule`.

But once we make sure every AD package provides a method following that API, then that becomes a common API for all AutoDiff.

We will thus have a easy way to say _use a rule if we have one, or use AD if not_.

---

This means we are not far from being able to provide generic interface for *Optim.jl* etc.
Where you can either define a `rrule` or it will use AD if one is loaded.
