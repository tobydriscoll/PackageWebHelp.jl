using HTTP,TOML,EzXML
using Logging
Logging.disable_logging(Logging.Warn)

module_info = Dict( :Pkg => ModuleInfo("","pkgdocs.julialang.org","minor","v1","") )
for letter in 'T':'Z'
    regdir = joinpath(homedir(),".julia","registries","General",string(letter))
    for (root,dirs,files) in walkdir(regdir)
        for file in filter(startswith("Package.toml"),files)
            tom = TOML.parsefile(joinpath(root,file))
            repo = replace(tom["repo"],".git"=>"")
            println("\n\nLooking for $(tom["name"]) at $repo")
            failed = false
            readme = []
            try
                readme = HTTP.get(repo,timeout=8)
                failed = readme.status != 200
            catch
                failed = true
            end
            failed && continue
            # s = String(readme.body)
            print("   Got readme.")
            doc = parsehtml(readme.body)
            base_url,current = "",""
            for link in filter(x->haskey(x,"href"),findall("//a",EzXML.root(doc)))
                s = link["href"]
                current = "stable"
                m = match(Regex("https://(.*)/$current"),s)
                if isnothing(m)
                    current = "latest"
                    m = match(Regex("https://(.*)/$current"),s)
                end
                if !isnothing(m)
                    base_url = m.captures[1]
                    print(" Found a doc link.")
                    break 
                end
            end 
            # our best guess
            module_info[Symbol(tom["name"])] = ModuleInfo(repo,base_url,"minor",current,"")

            # keep Github from throttling?
            sleep(2)
        end
    end
    open("module_info.json","w") do io 
        JSON.print(io,sort(module_info),2)
    end
end