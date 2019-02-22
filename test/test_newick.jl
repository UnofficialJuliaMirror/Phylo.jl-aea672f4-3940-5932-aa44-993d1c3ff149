module TestNewick

using Phylo
using Compat.Test

@testset "A few simple binary trees" begin
    @test length(nodeiter(parsenewick("((,),(,));"))) == 7
    @test ["where", "when it's good", "Not mine", "MyLeaf"] ⊆
        nodenameiter(parsenewick("""((MyLeaf,"when it's good"),
                                     ('Not mine',where));"""))
    tree = parsenewick("((MyLeaf[&Real=23,'Not real'={5,4}]:4.0,)Parent,(,));")
    branches = branchfilter(tree) do tree, branch
        return getnodename(tree, src(tree, branch)) == "Parent" &&
            getnodename(tree, dst(tree, branch)) == "MyLeaf"
    end
    @test length(branches) == 1
    @test getlength(tree, first(branches)) ≈ 4.0
    @test getnodedata(tree, "MyLeaf")["Real"] == 23
    @test 5 ∈ getnodedata(tree, "MyLeaf")["Not real"]
    @test 4 ∈ getnodedata(tree, "MyLeaf")["Not real"]
    if VERSION < v"0.7.0-"
        @test_warn "Tree ended but not finished" parsenewick("((,),(,));a")
    end
    @test_throws Exception parsenewick("((,),(,)));")
    @test_throws Exception parsenewick("((,),(,))")
    @test_throws Exception parsenewick("((,),(,);")
    @test_throws Exception parsenewick("((MyLeaf:-4.0,)Parent,(,));")
    tree = open(parsenewick, Phylo.path("H1N1.newick"))
    @test nleaves(tree) == 507
    @test ntrees(tree) == 1
    treex = open(parsenexus, Phylo.path("H1N1.trees"))
    @test nleaves(tree) == nleaves(treex) ==
          nleaves(treex["TREE1"]) == nleaves(treex["TREE2"])
    @test ntrees(treex) == 2
end

@testset "A few simple polytomous trees" begin
    @test nnodes(parsenewick("((,),(,,));", NamedPolytomousTree)) == 8
    @test ["where", "when it's good", "Not mine", "MyLeaf", "next"] ⊆
        nodenameiter(parsenewick("""((MyLeaf,"when it's good",next),
                                     ('Not mine',where));""", NamedPolytomousTree))
    tree = parsenewick("((MyLeaf:4.0,)Parent,());", NamedPolytomousTree)
    branches = branchfilter(tree) do tree, branch
        return getnodename(tree, src(tree, branch)) == "Parent" &&
            getnodename(tree, dst(tree, branch)) == "MyLeaf"
    end
    @test length(branches) == 1
    @test getlength(tree, first(branches)) ≈ 4.0
    @test_throws Exception parsenewick("((,),(,)));", NamedPolytomousTree)
    @test_throws Exception parsenewick("((,),(,))", NamedPolytomousTree)
    @test_throws Exception parsenewick("((,),(,);", NamedPolytomousTree)
end

end
