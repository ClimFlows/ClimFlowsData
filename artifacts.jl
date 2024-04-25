using Pkg; Pkg.activate(@__DIR__)
using Tar, Inflate, SHA

function analyze(name)
    filename = "$name.tar.gz"
    url = "https://github.com/ClimFlows/ClimFlowsData/raw/data/$filename"
    SHA256 = bytes2hex(open(sha256, filename))
    sha1 = Tar.tree_hash(IOBuffer(inflate_gzip(filename)))
    println("""
    [$name]
    git-tree-sha1 = "$sha1"
    lazy = true
    [[$name.download]]
    url = "$url"
    sha256 = "$SHA256"

    """)
end

analyze("VoronoiMeshes")
