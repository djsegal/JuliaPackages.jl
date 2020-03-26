function package_paths(general_db, decibans_db)
    cur_paths = vcat(
        collect(zip(decibans_db.package, lowercase.(join.(zip(decibans_db.owner, join.(vcat.(decibans_db.package, ".jl"))), "/")))),
        collect(zip(general_db.package, lowercase.(join.(zip(general_db.owner, join.(vcat.(general_db.package, ".jl"))), "/"))))
    )

    cur_paths = unique(cur_paths)

    return cur_paths
end
