module PackageWebHelp

using Pkg 
using HTTP
using JSON
using DefaultApplication

export help,package_help

# Define the ModuleInfo type:
include("module_info.jl")

# Import the module data:
# (Maybe this should be an artifact, but this is way simpler...)
module_info = JSON.parsefile(joinpath(@__DIR__,"module_info.json"))

# Check validity of a URL with a short timeout:
function is_valid_url(url,timeout)
    valid = false
    try 
        resp = HTTP.get(url,connect_timeout=timeout)
        valid = (resp.status==200)
    catch
        valid = false
    end
    return valid 
end

# This is the workhorse.
function get_url(modu::String;timeout=5)
    @assert haskey(module_info,modu) "Module $(string(modu)) is not in the database"
    
    mi = ModuleInfo(module_info[modu])

    # Is there a documentation root to try?
    valid = false
    if !isempty(mi.doc_base)
        dep = filter(x->x[2].name==string(modu),Pkg.dependencies())
        # If the package is a dependency of the active project, get its version number and try the specific URL for it first.
        if isempty(dep)
            @warn "Module $(string(modu)) is not a project dependency; opening to latest version"
        elseif !isnothing(mi.version)
            ver = string(first(values(dep)).version)
            url = specific(mi,ver)
            valid = is_valid_url(url,timeout)
        end

        if !valid
            # Try the generic documentation URL:
            url = generic(mi)
            valid = is_valid_url(url,timeout)
            if !valid
                @warn "URL $url does not respond. Trying repository page instead."
            end
        end
    end

    # Fallback is the repo page:
    if !valid
        url = mi.repo_url
    end
    
    return url
end

# These are the only functions meant to be called directly at the REPL. 
"""
    help(module_name)
    help(module_name,timeout=nsec)

Attempt to open the default web browser to documentation for the package `module_name`, which is either a Symbol or a String. If the package is a dependency of the active project, the documentation for the active version is shown if known; otherwise, the function looks for the latest/stable version. If no documentation location is known, the repository page from the registry is opened.

If the `timeout=` argument is given, it defines the timeout in seconds used before giving up on a particular URL.

# Examples
```julia-repl
julia> help("DataFrames")
┌ Warning: Module DataFrames is not a project dependency; opening to latest version
└ @ PackageWebHelp ~/Dropbox/julia/PackageWebHelp/src/PackageWebHelp.jl:40
Process(`open https://dataframes.juliadata.org/stable/`, ProcessRunning)
```

```julia-repl
julia> help("Julia")
┌ Warning: Module Julia is not a project dependency; opening to latest version
└ @ PackageWebHelp ~/Dropbox/julia/PackageWebHelp/src/PackageWebHelp.jl:40
Process(`open https://docs.julialang.org/en/v1/`, ProcessRunning)
```
"""
help(s::String;kwargs...) = DefaultApplication.open(get_url(s;kwargs...))
help(m::Union{Symbol,Module};kwargs...) = help(string(m);kwargs...)
const package_help = help

end # module
