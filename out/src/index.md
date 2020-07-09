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

# Thanks also
.row[
.col[&#8203;
 - Wessel Bruinsma
 - Takafumi Arakaki
 - Simon Etter
 - Shashi Gowda
 - Rory Finnegan
 - Roger Luo
 - Mike Innes
 - Michael Abbott
 - Mason Protter
]
.col[&#8203;
 - Kristoffer Carlsson
 - Jeffrey Sarnoff
 - James Bradbury
 - Eric Davies
 - Curtis Vogt
 - Christopher Rackauckas
 - Anton Isopoussu
 - Antoine Levitt
 - Andrew Fitzgibbon
]
]


---

# How does Forward Mode AD work?

Forward-mode AD means replacing every function with a function that calculates the primal result and pushesforward the derivative.

dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws

How do we get such a function?
Either we have a `frule` giving us one,
or we open up the function and replace every function inside it with such a propagating function.


---

## Lets do AD by hand: forward-mode
```@setup hand
using ChainRules, ChainRulesCore
```

```@example hand
function foo(x)
    u = sin(x)
    v = asin(u)
    return v
end
```
.row[
.col[

```@repl hand
x = π/4;
ẋ = 1.0;
u, u̇ = frule((NO_FIELDS, ẋ), sin, x)
v, v̇ = frule((NO_FIELDS, u̇), asin, u)
v̇
```
]

.col[
$$\dot{x}=\textcolor{blue}{\dfrac{\partial x}{\partial x}}$$  <br><br>
$$\dot{u}=
\textcolor{green}{\dfrac{\partial u}{\partial x}}
=\textcolor{blue}{\dfrac{\partial x}{\partial x}}
\dfrac{\partial u}{\partial x}$$<br><br>
$$\dot{v}=
\textcolor{purple}{\dfrac{\partial v}{\partial x}}
=\dfrac{\partial v}{\partial u} 
\textcolor{green}{\dfrac{\partial u}{\partial x}}$$
]

]

---


# How does Reverse Mode AD work?

Reverse-mode AD means replacing every function with a function that calculates the primal result and stores the pullback onto a tape, which it then composes backwards at the end to pull all the way back.

dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws

How do we get such a function that tells us the pullback?
Either we have a `rrule` giving us one,
or we open up the function and replace every function inside it with such a propagating function.


---

## Lets do AD by hand: reverse-mode

```julia
function foo(x)
    u = sin(x)
    v = asin(u)
    return v
end
```

First the forward pass, computing the pullbacks, which we would record onto the tape
```@repl hand
x = π/4
u, u_pullback = rrule(sin, x)
v, v_pullback = rrule(asin, u)
```

---


## Lets do AD by hand: reverse-mode

```julia
function foo(x)
    u = sin(x)
    v = asin(u)
    return v
end
```

Then the backward pass calculating gradients

.row[
.col[

```@repl hand
v̅ = 1;
_, u̅ = v_pullback(v̅)
_, x̄ = u_pullback(u̅)
x̄
```
]

.col[
$$\bar{v}=\textcolor{blue}{\dfrac{\partial v}{\partial v}}$$  <br><br>
$$\bar{u}=\textcolor{green}{\dfrac{\partial v}{\partial u}}
=\dfrac{\partial v}{\partial u}
\textcolor{blue}{\dfrac{\partial v}{\partial v}}$$  <br><br>
$$\bar{x}=
\textcolor{purple}{\dfrac{\partial v}{\partial x}}
=\textcolor{green}{\dfrac{\partial v}{\partial u}}
\dfrac{\partial u}{\partial x}$$  <br><br>

]

]

---

<br>
<br>
.row[
.col[
# A series of needs
<br>
.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]
]
]

---

# What does AD Need ?

 - Ability to break things down into primative operations that is has **rules** for.
 - Ability to recompose those rules and the results to get overall derivatives.
 - A collection of those **rules**: ChainRules

---

# Why does AD need rules:
 - Fundermentally need rules for the instruction set: `+`, `*`, etc.
 - Insert domain-knowledge about best way to find it. Extreme example: _QuadGK + Fundermental Theorem of Calculus._ it is the identity.
 - Need rules to handle things the AD can't deal with (e.g. Zygotes current lack of mutation support)

.funfact[
    Instruction set size varies a lot across ADs.
    E.g. PyTorch, Jax, MxNet have an instruction set that is $\approx~\text{Numpy's API}$.
    Enzyme has an instruction set that is the LLVM instruction set.
]

---

# What does ChainRules Need?

dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws

### An AD Agnostic System for Writing Rules
ChainRulesCore.jl

dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws

### An inventory of actual rules, e.g. for Base
ChainRules.jl

dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws

### A way to test they are right
ChainRulesTestUtils.jl

---


# The ChainRules project fills those needs

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


# What does ChainRulesCore Need?
A way to express what the rule is
for a given method: i.e. function + argument types.
`frule` `rrule`, methods that are upon the type of the function.

# What does a rule need?
propagate deriviatives.
Pullback / pushforward.

# What does a pushforward need?

---

# What does a pullback need?


--- 

# What do we need to represent the types of the tangents + co-tangents?
.row[
.col[
**Primal** <br>
`Float64` <br>
`Matrix{Float64}` <br>
`String` <br>
```julia
struct Foo
    a::Matrix{Float64}
    b::String
end
```
]

.col[
**Differential**<br>
`Float64`<br>
`Matrix{Float64}`<br>
`DoesNotExist` <br>
```julia
Composite{Foo}
# With properties:
    a::Matrix{Float64}
    b::DoesNotExist
```
]

]

.funfact[
    There are multiple correct differentials for many types and which to use is context dependent.
]


dbukaemhhkngunpvitbpiqitujgmusfmbatdzdwhzjfgvtscws
# What do differential types need?
Basically they are elements of almost vector spaces.
Conceptually, **every differential represents the difference between two primals**

---

# What do differential types need? `zero`

They need a **zero**, since primals can equal to themselves, and constants exist.

.funfact[
There is thus the trival differential. `Zero()`,
which can be added to anything and it won't change.
Its a valid differential for all primals.
]

---

# What do differential types need? `+`

They need to be able to be added to each other.

For $u = \sin(x)$, $v = \cos(x)$, $y = u + v$

$$\dfrac{\partial y}{\partial x} = \dfrac{\partial u}{\partial x} + \dfrac{\partial v}{\partial x}$$

.funfact[
An advantage of ChainRule's differentiable types over Zygotes use of `NamedTuples` (Chainrule's `Composite`) and `Nothing` (ChainRule's `AbstractZero`) is that they actually overload `+`
]

---

# What do differential types need? `+` to primal

They need to be able to be added to a  corresponding **primal** value, to get back another **primal** value.

Firstly, because this is what it means to be a _difference_.

Secondly, because this makes it possible to do gradient based optimization.

.funfact[
The differential for `DateTime` is `Period` (e.g. `Millisecond`).
It is my favorite example of a differential for a primal that is *not* a vector space. 
]


---

# What do differential types need? `*` with scalar
Again, this makes it possible to do gradient based optimization.

Also it is so easy to define via _limits of addition_ that it seems wrong to not have it.

.funfact[ We are currently thinking about rewriting **FiniteDifferences.jl** to represent differences with differentials, rather than projecting everything to and from a vector. ]

---


---

<br>
<br>
.row[
.col[
# What is out there?
<br>
.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]
]
]

---

# How many AD systems do we have?

.row[
.col[
**Reverse Mode:**
 - AutoGrad
 - Nabla
 - ReverseDiff
 - Tracker
 - Yota
 - Zygote
]

.col[
**Forward Mode:**
 - ForwardDiff
 - ForwardDiff2
 - Zygote
]
]

.unfunfact[
Julia suffers from the LISP Curse.
It is too easy to make an AD. 
]

---


# What Rules exist:
 - Nabla.jl has ~300 rules
 - Zygote.jl has ~500 rules
 - ChainRules.jl has ~200 rules so far
 - DiffRules.jl has ~50 rules

<br>
.funfact[The intersection of Zygote and Nabla's rules is not much more than what both have from DiffRules.]
<br>
.unfunfact[A great way to get a lot of custom rules written is to throw errors (the _Zygote Strategy_)]


---

# ChainRules vs DiffRules:
**ChainRules** is the successor to **DiffRules**

 - **DiffRules** only handles _scalar rules_
 - Any rule defined in **DiffRules** can be define using the `@scalar_rule` macro in **ChainRules** without change.
 - **DiffRules** is _not designed_ to have its list of rules extended by other packages. **ChainRulesCore** is.

---

# ChainRules vs ZygoteRules:
ZygoteRules is a effectively deprecated, and all new rules should be written using ChainRulesCore

 - **ChainRulesCore** and **ZygoteRules** are very similar
 - ChainRules wasn't quite ready when ZygoteRules was created.
 - ChainRules is not Zygote specific, it works with everything.
 - A macro is planned to allow the easy port of existing ZygoteRules to ChainRules

---


<br>
<br>
.row[
.col[
# The Future
<br>
.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]
]
]

---


## Deeper Integration into Zygote.
 - Use in Forward Mode
 - Use ChainRule's differential types
     - `nothing` -> `AbstractZero`
     - `NamedTuple` -> `Composite`

---

# More Integrations

## ReverseDiff 🔜

Need to improve support for generating overloads from rules.
Vs using Cassette to directly subsitute.
Will also solve inference related issues.

## Nabla

Its going to be similar to ReverseDiff.
We want to retire Nabla, and doing so safely means knowing we have removed all its rules into ChainRules and still pass tests.


---

## ForwardDiff  🤷
_maybe_

Its so stable.

ForwardDiff2 might take its place.

.funfact[
ForwardDiff was released on 13 April 2013.
Julia v0.2 was released 19 November 2013.
31 weeks later.
Which included such features as Pkg2,  keyword arguments, and suffixing mutating functions with `!`.
]

---

## Calling back into AD
```julia
function rrule(::typeof(map), f, x)
    res = map(xi->rrule(f, xi), x)
    ys, pullbacks = unzip(res) 
    function map_pullback(ȳ)
        s̄elf, x̄ = unzip(map(pullbacks, ȳ) do pullback_i, ȳi
            pullback_i(ȳi)
        end
        return NO_FIELDS, s̄elf, x̄
    end
    return y, map_pullback
end
```

**But this calls `rrule(f, xi)` which might not be defined**.
May need to use an AD to find it. 

Could hard-code a given AD, but probably you want to keep using the one you are already using when  you called `rrule(map, f, x)`

---

## ChainRules as an interface for AD

So we need to provide an interface by which one specifies how to call back into AD from a ChainRule.
Probably by providing a method that exactly matches the behavour of `rrule` / `frule`.

But once we make sure every AD package provides a method following that API, then that becomes a common API for all AutoDiff.

We will thus have a easy way to say _use a rule if we have one, or use AD if not_.

This means we are not far from being able to provide generic interface for *Optim.jl* etc.
Where you can either define a `rrule` or it will use AD if one is loaded.

---

# RuleD Everywhere

Just like **TimeZones.jl** depends on **RecipesBase.jl** to make `ZonedDateTimes` plot-able.

Packages like **DiffEqBase** depends on **ChainRulesCore.jl**
and provide rules to make their functions differentiable, where required or where there are smart domain-knowledge ways to make it faster.

The future is more packages doing that.

---

# How to get involved
 - Write rules for Base etc in ChainRules
 - Write rules for your package with ChainRulesCore
 - Incorporate ChainRules support in to your favourate AD

.funfact[There are 500 rules in Zygote that need migrating.]

---

# Summary
 - AD needs rules
 - There will always be more AD systems.
 - One set of rules to rule them all
.row[
.col[
<br>
.image-30[![ChainRules](https://camo.githubusercontent.com/c516876cff07da365db715346109a22f490945ef/68747470733a2f2f72617763646e2e6769746861636b2e636f6d2f4a756c6961446966662f436861696e52756c6573436f72652e6a6c2f623062386462663236383037663866366263316133633037336236373230623864393061386364342f646f63732f7372632f6173736574732f6c6f676f2e737667)]
]
]
