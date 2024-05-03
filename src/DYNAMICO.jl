"""
    using NetCDF: ncread
    using ClimFlowsData: DYNAMICO_reader
    using CFDomains: VoronoiSphere
    sphere = VoronoiSphere(DYNAMICO_reader(ncread, "uni.1deg.mesh.nc") ; prec=Float32)
"""
function DYNAMICO_reader(ncread, meshname)
    meshfile = Base.Filesystem.joinpath(artifact"VoronoiMeshes", "VoronoiMeshes", meshname)
    function reader(name)
        readvar(varname) = ncread(meshfile, varname)
        if name == :primal_num
            return length(readvar("primal_deg"))
        elseif name == :dual_num
            return length(readvar("dual_deg"))
        elseif name == :edge_num
            return length(readvar("trisk_deg"))
        elseif name == :le_de
            ## the DYNAMICO mesh file contains 'le' and 'de' separately
            le = readvar("le")
            de = readvar("de")
            return le ./ de
        elseif name == :primal_perot_cov
            return perot_cov!(
                (
                    readvar(name) for
                    name in ("primal_perot", "le", "de", "primal_deg", "primal_edge")
                )...,
            )
        else
            return readvar(String(name))
        end
    end

    @info "Ready to read DYNAMICO mesh file $meshfile"
    return reader
end

function perot_cov!(perot, le, de, degree, edge)
    ## the Perot weights found in the DYNAMICO mesh file
    ## assume *contravariant* components as inputs
    ## we want to apply them to covariant data (momentum)
    ## => multiply weights by le/de
    for ij in eachindex(degree)
        deg = degree[ij]
        for e = 1:deg
            le_de = le[edge[e, ij]] * inv(de[edge[e, ij]])
            perot[e, ij, 1] *= le_de
            perot[e, ij, 2] *= le_de
            perot[e, ij, 3] *= le_de
        end
    end
    return perot
end
