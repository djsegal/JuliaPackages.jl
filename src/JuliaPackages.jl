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
  using Cascadia
  using AbstractTrees

  using Dates
  using Languages
  using TextAnalysis

  using MLJ
  using XGBoost
  using MultivariateStats
  using Glob

  using InlineStrings
  using VersionParsing
  using RegistryTools: Compress

  using OpenAI

  export general_db, decibans_db
  export packages_db, trending_db

  include("scrape_general_packages.jl")
  include("scrape_decibans_packages.jl")
  include("scrape_trending_packages.jl")

  include("init.jl")

  include("package_paths.jl")
  include("combine_datasets.jl")

  include("custom_text.jl")
  include("custom_make_url.jl")
  include("custom_get_database.jl")

  include("hit_repo_api.jl")
  include("hit_readme_api.jl")
  include("hit_search_api.jl")

end
