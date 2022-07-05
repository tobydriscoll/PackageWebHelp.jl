struct ModuleInfo
    repo_url::String
    doc_base::String 
    version::String
    current::String
    suffix::String
end

ModuleInfo(d::Dict) = ModuleInfo(
    d["repo_url"],d["doc_base"],d["version"],d["current"],d["suffix"]
    )
    
# This is how Documenter is usually set up:
ModuleInfo(repo,base) = ModuleInfo(repo,base,"minor","stable","")

# These functions construct different parts of the URLs.
base(mi::ModuleInfo) = "https://"*mi.doc_base
function version(mi::ModuleInfo,s::String)
    !startswith(s,"v") && (s = "v"*s )  # ensure it starts with 'v'
    v = split(s,'.')
    if mi.version=="major"
        return v[1]
    elseif mi.version=="minor"
        return join(v[1:2],'.')
    else  # "patch"
        return s
    end
end
suffix(mi::ModuleInfo) = mi.suffix

# These functions construct the two URLs to try in practice.
specific(mi::ModuleInfo,s::String) = join([base(mi),version(mi,s),suffix(mi)],'/')
generic(mi::ModuleInfo) = join([base(mi),mi.current,suffix(mi)],'/')
