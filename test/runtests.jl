using NetCDF: ncread
using ClimFlowsData: DYNAMICO_reader, DYNAMICO_meshfile
using CFDomains: VoronoiSphere

using Test

@testset "DYNAMICO" begin
    choices = (precision = Float64, meshname = "uni.1deg.mesh.nc", tol=1e-3)
    reader = DYNAMICO_reader(ncread, DYNAMICO_meshfile(choices.meshname))
    sphere = VoronoiSphere(reader; prec = choices.precision)
    @info sphere
    @test true
end

