function package_paths(general_db, decibans_db)
    cur_paths = vcat(
        collect(zip(decibans_db.package, lowercase.(join.(zip(decibans_db.owner, join.(vcat.(decibans_db.package, ".jl"))), "/")))),
        collect(zip(general_db.package, lowercase.(join.(zip(general_db.owner, join.(vcat.(general_db.package, ".jl"))), "/"))))
    )

    cur_paths = sort(
      unique(cur_paths),
      by = (cur_path) -> lowercase(first(cur_path))
    )

    return cur_paths
end
