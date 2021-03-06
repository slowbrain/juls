"""Coriolis parameter [s^-1] at central latitude."""
function coriolis_at_lat(ϕ::Real)
    return 2*ω*sind(ϕ)
end

"""Coriolis derivative wrt latitude [(ms)^-1]."""
function β_at_lat(ϕ)
    return 2*ω/R*cosd(ϕ)
end

"""Returns the coriolis parameter on the all grids for β-plane approximation."""
function coriolis_parameter()

    if bc_x == "periodic"
        # points on the right edge needed too
        xx_q,yy_q = meshgrid(x_q_halo[3:end-1],y_q_halo[3:end-2])
    else
        xx_q,yy_q = meshgrid(x_q,y_q)
    end

    xx_u,yy_u = meshgrid(x_u,y_u)
    xx_v,yy_v = meshgrid(x_v,y_v)

    # retrieve Coriolis parameter and derivative
    f₀ = coriolis_at_lat(ϕ)
    β = β_at_lat(ϕ)

    # for non-dimensional gradient operators f contains the grid spacing Δ
    f_u = Numtype.(Δ*(f₀ .+ β*(yy_u .- Ly/2)))
    f_v = Numtype.(Δ*(f₀ .+ β*(yy_v .- Ly/2)))
    f_q = Numtype.(Δ*(f₀ .+ β*(yy_q .- Ly/2)))

    return f_u,f_v,f_q
end

"""Coriolis term f*v. """
function fv!(qhv,f_u,v_u)
    m,n = size(qhv)
    @boundscheck (m,n) == size(f_u) || throw(BoundsError())
    @boundscheck (m+4-ep,n+2) == size(v_u) || throw(BoundsError())

    for j ∈ 1:n
        for i ∈ 1:m
            qhv[i,j] = f_u[i,j]*v_u[i+2-ep,j+1]
        end
    end
end

"""Coriolis term f*u. """
function fu!(qhu,f_v,u_v)
    m,n = size(qhu)
    @boundscheck (m,n) == size(f_v) || throw(BoundsError())
    @boundscheck (m+2+ep,n+4) == size(u_v) || throw(BoundsError())

    for j ∈ 1:n
        for i ∈ 1:m
            qhu[i,j] = f_v[i,j]*u_v[i+1+ep,j+2]
        end
    end
end
