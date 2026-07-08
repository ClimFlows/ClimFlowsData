println(""" 
It is recommended to clone the ClimFlowsData repo into two local repos:
one for the `main` branch (default) and one for the `data` branch (`git checkout data`) 

Adding a new artifact:

- On branch `data`
  - add a tar.gz file at the root or in a subdirectory
  - commit and push (to the upstream "data" branch)
  - from the root directory, execute `julia build/artifacts.jl BASENAME`
    where `BASENAME` is the path to the artifact file, without the `tar.gz` extension
  - copy the output

- on branch 'main'
  - checkout a new branch
  - edit Artifacts.toml: append the output of `julia build/artifacts.jl BASENAME`
  - edit Project.toml: increase patch version
  - commit and push
  - on GitHub: create a pull request and merge it

If `Project.toml` has been edited as explained above, 
merging the pull request automatically registers 
the new version of ClimFlowsData into `JuliaRegistry`.
In a Julia project, the new artifacts become available
by updating `ClimFlowsData`.

Overwriting an existing artifact

`url` points to the exact commit within which the existing artifact 
was created. This url remains valid even as commits are added 
to the `data` branch. It is therefore possible to replace an existing artifact 
with a new version which corrects an issue or adds new data. For this, follow
the above procedure and replace the existing entry in `Artifacts.toml`.
""")

using Pkg; Pkg.activate(@__DIR__)
using Tar, Inflate, SHA, LibGit2, Downloads

function analyze(name)
    filename = "$name.tar.gz"
    isfile(filename) || error("Missing artifact archive: $filename")
    url = "https://github.com/ClimFlows/ClimFlowsData/raw/$commit/$filename"
    # check url
    response = Downloads.request(url; method="HEAD")
    response.status == 200 || error("HTTP status: ", response.status)
    # compute SHA
    SHA256 = bytes2hex(open(sha256, filename))
    sha1 = Tar.tree_hash(IOBuffer(inflate_gzip(filename)))
    # generate TOML to be pasted into Artifacts.toml
    println("""

    # copy-paste this into Artifacts.toml

    [$name]
    git-tree-sha1 = "$sha1"
    lazy = true
    [[$name.download]]
    url = "$url"
    sha256 = "$SHA256"

    """)
end

repo = LibGit2.GitRepo(dirname(@__DIR__))
LibGit2.isdirty(repo) && error("Repository has uncommitted changes.")
commit = string(LibGit2.GitHash(LibGit2.head(repo)))

length(ARGS)==1 || error("Provide exactly one argument: artifact file name, without the .tar.gz extension")
analyze(ARGS[1])
