module JuliaPackages

  using Pkg
  using Revise
  using ProgressMeter

  using StatsBase
  using DataFrames
  using DataStructures

  using CSV
  using HTTP
  using JSON

  using Gumbo
  using Languages
  using TextAnalysis
  using AbstractTrees
  using Dates

  export general_db, decibans_db, packages_db

  include("scrape_general_packages.jl")
  include("scrape_decibans_packages.jl")

  include("package_paths.jl")
  include("robust_relabel.jl")

  include("combine_datasets.jl")
  include("custom_get_database.jl")

  include("custom_make_url.jl")
  include("custom_text.jl")

  include("hit_repo_api.jl")
  include("hit_readme_api.jl")

  general_db = custom_get_database("general")
  decibans_db = custom_get_database("decibans")

  general_db, decibans_db = combine_datasets(general_db, decibans_db)
  decibans_db = robust_relabel(decibans_db)

  if isfile("../data/packages.csv")
    @assert isfile("../data/paths.csv")
    paths_db = CSV.read("../data/paths.csv")
    good_paths = collect(zip(paths_db.package, paths_db.path))

    packages_db = _hit_repo_finish(good_paths)
  else
    good_paths, packages_db = hit_repo_api(general_db, decibans_db)

    paths_db = DataFrame(good_paths)
    rename!(paths_db, Symbol.(["package", "path"]))
    CSV.write("../data/paths.csv", DataFrame(paths_db))
  end

  CSV.write("../data/packages.csv", packages_db)
  hit_readme_api(good_paths)

end
