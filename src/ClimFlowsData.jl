module ClimFlowsData

using LazyArtifacts

VoronoiLowRes(name) = Base.Filesystem.joinpath(artifact"VoronoiLowRes", "VoronoiLowRes", name)
VoronoiMeshes(name) = Base.Filesystem.joinpath(artifact"VoronoiMeshes", "VoronoiMeshes", name)

include("DYNAMICO.jl")

end # module ClimFlowsData
