"""Tendencies du,dv,dη of

        ∂u/∂t = qhv - ∂(1/2*(u²+v²) + gη)/∂x + Fx
        ∂v/∂t = -qhu - ∂(1/2*(u²+v²) + gη)/∂y + Fy
        ∂η/∂t =  -∂(uh)/∂x - ∂(vh)/∂y + γ(η_ref-η) + Fηt*Fη

where non-linear terms

        q, (u²+v²)

of the mom eq. are only updated outside the function (slowly varying terms)."""
function rhs_nonlin!(du,dv,dη,u,v,η,Fx,Fy,f_u,f_v,f_q,H,η_ref,Fη,t,
            dvdx,dudy,dpdx,dpdy,
            p,u²,v²,KEu,KEv,dUdx,dVdy,
            h,h_u,h_v,h_q,U,V,U_v,V_u,u_v,v_u,
            qhv,qhu,q,q_u,q_v,
            qα,qβ,qγ,qδ)

    # layer thickness
    thickness!(h,η,H)
    Ix!(h_u,h)
    Iy!(h_v,h)

    # mass or volume flux U,V = uh,vh
    Uflux!(U,u,h_u)
    Vflux!(V,v,h_v)

    # divergence of mass flux
    ∂x!(dUdx,U)
    ∂y!(dVdy,V)

    if nstep_advcor == 0    # evaluate every RK substep
        rhs_advcor!(u,v,η,H,h,h_q,dvdx,dudy,u²,v²,KEu,KEv,
                        q,f_q,qhv,qhu,qα,qβ,qγ,qδ,q_u,q_v)
    end

    # Bernoulli potential - recalculate for new η, KEu,KEv are only updated outside
    Bernoulli!(p,KEu,KEv,η)
    ∂x!(dpdx,p)
    ∂y!(dpdy,p)

    # Potential vorticity and advection thereof
    # PV is only updated outside
    PV_adv!(qhv,qhu,q,qα,qβ,qγ,qδ,q_u,q_v,U,V,V_u,U_v)

    # adding the terms
    momentum_u!(du,qhv,dpdx,Fx)
    momentum_v!(dv,qhu,dpdy,Fy)
    continuity!(dη,dUdx,dVdy,η,η_ref,Fη,t)
end

"""Tendencies du,dv,dη of

        ∂u/∂t = gv - g∂η/∂x + Fx
        ∂v/∂t = -fu - g∂η/∂y
        ∂η/∂t =  -∂(uH)/∂x - ∂(vH)/∂y + γ(η_ref-η) + Fηt*Fη,

the linear shallow water equations."""
function rhs_lin!(du,dv,dη,u,v,η,Fx,Fy,f_u,f_v,f_q,H,η_ref,Fη,t,
            dvdx,dudy,dpdx,dpdy,
            p,u²,v²,KEu,KEv,dUdx,dVdy,
            h,h_u,h_v,h_q,U,V,U_v,V_u,u_v,v_u,
            qhv,qhu,q,q_u,q_v,
            qα,qβ,qγ,qδ)

    # mass or volume flux U,V = uH,vH; h_u, h_v are actually H_u, H_v
    Uflux!(U,u,h_u)
    Vflux!(V,v,h_v)

    # divergence of mass flux
    ∂x!(dUdx,U)
    ∂y!(dVdy,V)

    # Pressure gradient
    ∂x!(dpdx,g*η)
    ∂y!(dpdy,g*η)

    # Coriolis force
    Ixy!(v_u,v)
    Ixy!(u_v,u)
    fv!(qhv,f_u,v_u)
    fu!(qhu,f_v,u_v)

    # adding the terms
    momentum_u!(du,qhv,dpdx,Fx)
    momentum_v!(dv,qhu,dpdy,Fy)
    continuity!(dη,dUdx,dVdy,η,η_ref,Fη,t)
end

"""Tendencies du,dv,dη of

        ∂u/∂t = gv - g∂η/∂x + Fx
        ∂v/∂t = -fu - g∂η/∂y
        ∂η/∂t =  -∂(uh)/∂x - ∂(vh)/∂y + γ(η_ref-η) + Fηt*Fη,

the shallow water equations which are linear in momentum but non-linear in continuity."""
function rhs_linmom!(du,dv,dη,u,v,η,Fx,Fy,f_u,f_v,f_q,H,η_ref,Fη,t,
            dvdx,dudy,dpdx,dpdy,
            p,KEu,KEv,dUdx,dVdy,
            h,h_u,h_v,h_q,U,V,U_v,V_u,u_v,v_u,
            qhv,qhu,q,q_u,q_v,
            qα,qβ,qγ,qδ)

    # layer thickness
    thickness!(h,η,H)
    Ix!(h_u,h)
    Iy!(h_v,h)

    # mass or volume flux U,V = uh,vh; - the continuity eq. is non-linear.
    Uflux!(U,u,h_u)
    Vflux!(V,v,h_v)

    # divergence of mass flux
    ∂x!(dUdx,U)
    ∂y!(dVdy,V)

    # Pressure gradient
    ∂x!(dpdx,g*η)
    ∂y!(dpdy,g*η)

    # Coriolis force
    Ixy!(v_u,v)
    Ixy!(u_v,u)
    fv!(qhv,f_u,v_u)
    fu!(qhu,f_v,u_v)

    # adding the terms
    momentum_u!(du,qhv,dpdx,Fx)
    momentum_v!(dv,qhu,dpdy,Fy)
    continuity!(dη,dUdx,dVdy,η,η_ref,Fη,t)
end

""" Update advective and Coriolis tendencies."""
function rhs_advcor!(u,v,η,H,h,h_q,dvdx,dudy,u²,v²,KEu,KEv,
                    q,f_q,qhv,qhu,qα,qβ,qγ,qδ,q_u,q_v)

    thickness!(h,η,H)
    Ixy!(h_q,h)

    # off-diagonals of stress tensor ∇(u,v)
    ∂x!(dvdx,v)
    ∂y!(dudy,u)

    # non-linear part of the Bernoulli potential
    speed!(u²,v²,u,v)
    Ix!(KEu,u²)
    Iy!(KEv,v²)

    # Potential vorticity update
    PV!(q,f_q,dvdx,dudy,h_q)

    # Linear combinations of the PV q
    if adv_scheme == "Sadourny"
        Iy!(q_u,q)
        Ix!(q_v,q)
    elseif adv_scheme == "ArakawaHsu"
        AHα!(qα,q)
        AHβ!(qβ,q)
        AHγ!(qγ,q)
        AHδ!(qδ,q)
    end
end

"""Layer thickness h obtained by adding sea surface height η to bottom height H."""
function thickness!(h,η,H)
    m,n = size(h)
    @boundscheck (m,n) == size(η) || throw(BoundsError())
    @boundscheck (m,n) == size(H) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            h[i,j] = η[i,j] + H[i,j]
        end
    end
end

"""Zonal mass flux U = uh."""
function Uflux!(U,u,h_u)
    m,n = size(U)
    @boundscheck (m,n) == size(h_u) || throw(BoundsError())
    @boundscheck (m+2+ep,n+2) == size(u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            U[i,j] = u[1+ep+i,1+j]*h_u[i,j]
        end
    end
end

"""Meridional mass flux V = vh."""
function Vflux!(V,v,h_v)
    m,n = size(V)
    @boundscheck (m,n) == size(h_v) || throw(BoundsError())
    @boundscheck (m+2,n+2) == size(v) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            V[i,j] = v[i+1,j+1]*h_v[i,j]
        end
    end
end

"""Squared velocities u²,v²."""
function speed!(u²,v²,u,v)
    # u squared
    m,n = size(u²)
    @boundscheck (m,n) == size(u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            u²[i,j] = u[i,j]^2
        end
    end

    # v squared
    m,n = size(v²)
    @boundscheck (m,n) == size(v) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            v²[i,j] = v[i,j]^2
        end
    end
end

"""Bernoulli potential p = 1/2*(u² + v²) + gη."""
function Bernoulli!(p,KEu,KEv,η)
    m,n = size(p)
    @boundscheck (m+ep,n+2) == size(KEu) || throw(BoundsError())
    @boundscheck (m+2,n) == size(KEv) || throw(BoundsError())
    @boundscheck (m,n) == size(η) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            p[i,j] = one_half*(KEu[i+ep,j+1] + KEv[i+1,j]) + g*η[i,j]
        end
    end
end

"""Sum up the tendencies of the non-diffusive right-hand side for the u-component."""
function momentum_u!(du,qhv,dpdx,Fx)
    m,n = size(du) .- (2*halo,2*halo) # cut off the halo
    @boundscheck (m,n) == size(qhv) || throw(BoundsError())
    @boundscheck (m+2-ep,n+2) == size(dpdx) || throw(BoundsError())
    @boundscheck (m,n) == size(Fx) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            du[i+2,j+2] = qhv[i,j] - dpdx[i+1-ep,j+1] + Fx[i,j]
        end
    end
end

"""Sum up the tendencies of the non-diffusive right-hand side for the v-component."""
function momentum_v!(dv,qhu,dpdy,Fy)
    m,n = size(dv) .- (2*halo,2*halo) # cut off the halo
    @boundscheck (m,n) == size(qhu) || throw(BoundsError())
    @boundscheck (m+2,n+2) == size(dpdy) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
             dv[i+2,j+2] = -qhu[i,j] - dpdy[i+1,j+1] + Fy[i,j]
        end
    end
end

if dynamics == "linear"
    rhs! = rhs_lin!
elseif dynamics == "nonlinear"
    rhs! = rhs_nonlin!
else
    throw(error("Dynamics linear/nonlinear incorrectly specified."))
end
