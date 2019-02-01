# NUMBER FORMAT OPTIONS
const Numtype = Float32
#const Numtype = Posit{16,2}
#const Numtype = Main.FiniteFloats.Finite16
#const Numtype = BigFloat
#setprecision(7)

# DOMAIN RESOLUTION AND RATIO
const nx = 400                      # number of grid cells in x-direction
const Lx = 10000e3                   # length of the domain in x-direction
const L_ratio = 2                   # Domain aspect ratio of Lx/Ly

# PHYSICAL CONSTANTS
const gravity = 0.032                # gravitational acceleration
const water_depth = 125.            # layer thickness at rest
const ρ = 1e3                       # density
const ϕ = 10.                       # central latitue of the domain (for coriolis)
const ω = 2π/(24*3600)              # Earth's angular frequency [s^-1]
const R = 6.371e6                   # Earth's radius [m]

# WIND FORCING OPTIONS
const wind_forcing = "constant"      # "channel", "double_gyre", "shear" or "none"
const Fx0 = 0.01                    # wind stress strength [Pa], default 0.12

# BOTTOM TOPOGRAPHY OPTIONS
const topography_feature = "flat"  # "ridge", "seamount", "flat", "ridges", "bathtub"
const topofeat_height = 50.         # height of seamount
const topofeat_width = 300e3        # horizontal scale [m] of the seamount

# NEWTONIAN COOLING OPTIONS
const surface_forcing = false       # or true
const t_relax = 100.                # time scale of the interface_relaxation [days]
const η_refh = 5.                   # height difference [m] of the interface relaxation profile
const η_refw = 100e3                # width [m] of the tangent used for the interface relaxation

# TIME STEPPING OPTIONS
const RKo = 4                       # Order of the RK time stepping scheme (3 or 4)
const cfl = 0.9                     # CFL number (1.0 recommended for RK4, 0.6 for RK3)
const Ndays = 600                   # number of days to integrate for
const nstep_diff = 1                # diffusive part every nstep_diff time steps.
const nstep_advcor = 1              # advection and coriolis every nstep_advcor time steps.

# BOUNDARY CONDITION OPTIONS
const bc_x = "nonperiodic"             # "periodic" or anything else for nonperiodic
const lbc = 1.                      # lateral boundary condition parameter
                                    # 0 free-slip, 0<lbc<2 partial-slip, 2 no-slip

# MOMENTUM ADVECTION OPTIONS
const adv_scheme = "ArakawaHsu"     # "Sadourny" or "ArakawaHsu"
const dynamics = "linear"        # "linear" or "nonlinear"

# BOTTOM FRICTION OPTIONS
const bottom_friction = "linear"    # "linear" or "quadratic"
const drag = 1e-5                   # bottom drag coefficient [dimensionless] for quadratic
const τdrag = 300.                  # bottom drag coefficient [days] for linear

# DIFFUSION OPTIONS
const diffusion = "Constant"        # "Smagorinsky" or "Constant", biharmonic in both cases
const ν_const = 1000.0               # [m^2/s] scaling constant for Constant biharmonic diffusion
const c_smag = 0.15                 # Smagorinsky coefficient [dimensionless]

# TRACER ADVECTION
const tracer_advection = false       # "true" or "false"
const tracer_relaxation = false     # "true" or "false"
const injection_region = "south"     # "west", "south" or "rect"
const sstrestart = false            # start from previous sst file
const Uadv = 0.5                    # Velocity scale [m/s] for tracer advection
const SSTmax = 30.                  # tracer (sea surface temperature) max for restoring
const SSTmin = 0.                   # tracer (sea surface temperature) min for restoring
const τSST = 500.                   # tracer restoring time scale [days]
const SSTw = 1000e3                 # width [m] of the tangent used for the IC and interface relaxation
const SSTϕ = 0.5                    # latitude/longitude ∈ [0,1] of sst edge

# OUTPUT OPTIONS
const output = true                 # for nc output
const output_tend = false            # ouput for tendencies as well?
const output_diagn = false           # output diagnostic variables as well?
const output_progn_vars = ["u","v","eta"]
const output_tend_vars = ["du","dv","deta","Bu","Bv","LLu1","LLu2","LLv1","LLv2",
                            "qhv","qhu","dpdx","dpdy","dUdx","dVdy"]
#const output_tend_vars = ["qhv","qhu","dpdx","dpdy","dUdx","dVdy"]
const output_diagn_vars = ["q","relvort"]#,"q","p","dudx","dvdy","dudy","dvdx","Lu","Lv","xd","yd"]

const output_dt = 24                 # output time step in hours
#const outpath = "/network/aopp/chaos/pred/kloewer/julsdata/ssthr/"
const outpath = "/Users/milan/phd/"

# INITIAL CONDITIONS
const initial_cond = "rest"       # "rest" or "ncfile"
const initpath = "/network/aopp/chaos/pred/kloewer/julsdata/ssthr/"

const init_run_id = 2               # only for starting from ncfile
