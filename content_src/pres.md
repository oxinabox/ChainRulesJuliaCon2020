# ChainRules
<br>
.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]
<br>
<br>
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
using Plots, GraphRecipes, LightGraphs, Random
gr(format=:png)

function index(names)
    indexes = ntuple(identity, length(names))
    return (; (names .=> indexes) ...)
end

rule_definers = [:ChainRules, :DistributionsDiff, :Hankel, :DiffEqBase, :OtherPackages]
ads = [:Zygote, :ForwardDiff2, :OtherADs]
theoretical = [:OtherADs, :OtherPackages]

links = [
    :ChainRulesCore .=> rule_definers;
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
Random.seed!(4)
dep_graph_plot = graphplot(
    dep_graph;
    method=:tree,
    shape=:circle,
    nodesize=0.4,
    axis_buffer=0.15,
    names = string.(nodes),   
    nodestrokecolor = color.(nodes),
    nodecolor= ifelse.(nodes .∈ Ref(theoretical), :lightgrey, :white),
    nodestrokewidth=3,
    linewidth=3,
    size=(3000, 520),
    xlims=(-1, 7),
)
```
```@example pkggraph
dep_graph_plot  # hide
```

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

---

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

---

# What Rules exist:
 - Nabla.jl has ~300 rules
 - Zygote.jl has ~500 rules
 - ChainRules has ~200 rules so far
 - DiffRules has ~30 rules

<br>
.funfact[The intersection of Zygote and Nabla's rules is not much more than what both have from DiffRules.]
<br>
.unfunfact[A great way to get a lot of custom rules written is to throw errors (the _Zgyote Stratergy_)]


---

# ChainRules vs DiffRules:
**ChainRules** is the successor to **DiffRules**

 - **DiffRules** only handles _scalar rules_
 - Any rule defined in **DiffRules** can be define using the `@scalar_rule` macro in **ChainRules** without change.
 - **DiffRules** is _not designed_ to have rules added in packages. **ChainRulesCore** is.

---

# ChainRules vs ZygoteRules:
ZygoteRules is a effectively deprecated, and all new rules should be written using ChainRulesCore

 - **ChainRulesCore** and **ZygoteRules** are very similar
 - ChainRules wasn't quite ready when ZygoteRules was created.
 - ChainRules is not Zygote specific, it works with everything.
 - ChainRulesCore is a bit less macro-magic
 - You can't realy on Zygote being loaded when writing a chainrule, but you can when writing a ZygoteRule.
 - A macro is planned to allow the easy port of existing ZygoteRules to ChainRules

---

# What is a pullback?

---

# What is an `rrule` ?

---

# What is a pushforward ?

---

# What is a `frule`? 

.unfunfact[You can't fuse rrules/pullbacks, because you need the gradient of the step that comes after. Which in turn needs the primal output of this step.]

---

# How does Forward Mode AD work?

Forward-mode AD means replacing every function with a function that calculates the primal result and pushesforward the derivative.

--

How do we get such a function?
Either we have a `frule` giving us one,
or we open up the function and replace every function inside it with such a propagating function.


---

### Lets do AD by hand: forward-mode
```@setup hand
using ChainRules, ChainRulesCore
```

```@example hand
function foo(x)
    u = sin(x)
    v = 0.2 + u
    w = asin(v)
    return w
end
```

```@repl hand
x = π/4;
ẋ = 1;  # ∂x/∂x

u, u̇ = frule((NO_FIELDS, ẋ), sin, x)  # ∂u/∂x
v, v̇ = frule((NO_FIELDS, Zero(), u̇), +, 0.2, u)  # ∂v/∂x = ∂b/∂a⋅∂a/∂x

w, ẇ = frule((NO_FIELDS, v̇), asin, v)  # ∂w/∂x = ∂w/∂v⋅∂v/∂x = ∂f/∂x
ẇ
```

---


# How does Reverse Mode AD work?

Reverse-mode AD means replacing every function with a function that calculates the primal result and stores the pullback onto a tape, which it then composes backwards at the end to pull all the way back.

--

How do we get such a function that tells us the pullback?
Either we have a `rrule` giving us one,
or we open up the function and replace every function inside it with such a propagating function.


---

### Lets do AD by hand: reverse-mode

```julia
function foo(x)
    u = sin(x)
    v = 0.2 + u
    w = asin(v)
    return w
end
```

First the forward pass, recording pullbacks onto the tape
```@repl hand
x = π/4
u, u_pullback = rrule(sin, x)
v, v_pullback = rrule(+, 0.2, u)
w, w_pullback = rrule(asin, v)
```

---


### Lets do AD by hand: reverse-mode

```julia
function foo(x)
    u = sin(x)
    v = 0.2 + u
    w = asin(v)
    return w
end
```

Then the backward pass calculating gradients

```@repl hand
w̅ = 1;  # ∂w/∂w
_, v̅ = w_pullback(w̅)     # ∂w/∂v
_, _, u̅ = v_pullback(v̅)  # ∂w/∂u
_, x̄ = u_pullback(u̅)     # ∂w/∂x = ∂f/∂x
x̄
```
