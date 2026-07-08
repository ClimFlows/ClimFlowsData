using NetCDF: ncread
using ClimFlowsData: DYNAMICO_reader, VoronoiMeshes, VoronoiLowRes
using VoronoiSpheres: VoronoiSphere

using Test

@testset "VoronoiLowRes" begin
    choices = (precision = Float64, meshname = "mesh4deg.nc", tol=1e-3)
    reader = DYNAMICO_reader(ncread, VoronoiLowRes(choices.meshname))
    sphere = VoronoiSphere(reader; prec = choices.precision)
    @info sphere
    @test true
end

@testset "VoronoiMeshes" begin
    choices = (precision = Float64, meshname = "uni.1deg.mesh.nc", tol=1e-3)
    reader = DYNAMICO_reader(ncread, VoronoiMeshes(choices.meshname))
    sphere = VoronoiSphere(reader; prec = choices.precision)
    @info sphere
    @test true
end

