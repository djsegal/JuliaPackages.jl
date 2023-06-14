function __init__()

  global general_db = nothing
  global decibans_db = nothing
  global packages_db = nothing
  global trending_db = nothing

  decibans_file, decibans_db = custom_get_database("decibans")
  general_file, general_db = custom_get_database("general")

  general_db, decibans_db = combine_datasets(general_db, decibans_db)
  general_csv = deepcopy(general_db)

  select!(general_csv, Not(:shallow_depending))
  select!(general_csv, Not(:deep_depending))

  general_csv[!, :shallow_depending] = replace.(string.(general_db.shallow_depending), '"' => "'")
  general_csv[!, :deep_depending] = replace.(string.(general_db.deep_depending), '"' => "'")

  select!(general_csv, Not(:shallow_dependents))
  select!(general_csv, Not(:deep_dependents))

  general_csv[!, :shallow_dependents] = replace.(string.(general_db.shallow_dependents), '"' => "'")
  general_csv[!, :deep_dependents] = replace.(string.(general_db.deep_dependents), '"' => "'")

  CSV.write(general_file, general_csv)
  CSV.write(decibans_file, decibans_db)

  if isfile("data/searched_paths.csv")
    searched_paths_db = CSV.read("data/searched_paths.csv", DataFrame)
    searched_paths = collect(zip(searched_paths_db.package, searched_paths_db.path))
  else
    searched_paths = hit_search_api()
  end

  trending_file, trending_db = custom_get_database("trending")
  CSV.write(trending_file, trending_db)

  if isfile("data/packages.csv")
    @assert isfile("data/paths.csv")
    paths_db = CSV.read("data/paths.csv", DataFrame)
    good_paths = collect(zip(paths_db.package, paths_db.path))

    packages_db = _hit_repo_finish(good_paths, general_db)
  else
    good_paths, packages_db = hit_repo_api(general_db, decibans_db)

    paths_db = DataFrame(good_paths)
    rename!(paths_db, Symbol.(["package", "path"]))
    CSV.write("data/paths.csv", DataFrame(paths_db))

    hit_readme_api([good_paths..., searched_paths...])
  end

  CSV.write("data/packages.csv", packages_db)

  println("done.")

end
