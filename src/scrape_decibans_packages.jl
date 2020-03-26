function scrape_decibans_packages()
  decibans_url = "https://raw.githubusercontent.com/svaksha/Julia.jl/master/db.csv"

  decibans_db = CSV.read(
    HTTP.get(decibans_url).body, header=false
  )

  rename!(decibans_db, Symbol.(split("category sub_category name url description")))

  decibans_db = coalesce.(decibans_db, "")
  decibans_db = strip.(decibans_db)

  decibans_db = decibans_db[endswith.(decibans_db.name, ".jl"), :]
  decibans_db.name .= replace.(decibans_db.name, ".jl" => "")

  decibans_db = decibans_db[occursin.("github.com", lowercase.(decibans_db.url)),:]

  decibans_db = decibans_db[(occursin.("gist", lowercase.(decibans_db.url)) .== 0),:]
  decibans_db = decibans_db[(occursin.("/blob/master/", lowercase.(decibans_db.url)) .== 0),:]

  decibans_db = decibans_db[(occursin.(" ", strip.(decibans_db.url)) .== 0),:]

  for cur_sub_category in unique(decibans_db.sub_category)
      cur_match = match(r"(?<=\[)[^\]]+(?=\]\([^\)]+\))", cur_sub_category)
      isnothing(cur_match) && continue

      decibans_db[decibans_db.sub_category .== cur_sub_category, :sub_category] .= cur_match.match
  end

  split_urls = split.(replace.(decibans_db.url, r".+github.com/" => ""), "/")
  cur_owners = map(first, split_urls)
  cur_packages = map(tmp_part -> tmp_part[2], split_urls)

  cur_packages = replace.(cur_packages, "]" => "")
  cur_packages = replace.(cur_packages, ")" => "")

  insertcols!(decibans_db, 1, :owner => cur_owners)
  insertcols!(decibans_db, 1, :package => cur_packages)

  select!(decibans_db, Not(:url))
  select!(decibans_db, Not(:name))
  select!(decibans_db, Not(:description))

  decibans_db = decibans_db[endswith.(decibans_db.package, ".jl"),:]
  decibans_db.package .= replace.(decibans_db.package, ".jl" => "")

  custom_rename!(decibans_db)

  return decibans_db
end

function custom_rename!(decibans_db)
  category_dict = Dict(
      "DataScience" => "Data Science",
      "DesktopApplications" => "Desktop Applications",
      "Earth-Science" => "Earth Science",
      "FileIO" => "File IO",
      "Programming-Paradigms" => "Programming Paradigms",
      "Space-Science" => "Space Science",
      "Super-Computing" => "Super Computing"
  )

  for (cur_key, cur_value) in category_dict
      decibans_db[decibans_db.category .== cur_key, :category] .= cur_value
  end

  two_word_sub_categories = Dict(
    "NeuralNetworks" => "Neural Networks",
    "DataFormats" => "Data Formats",
    "TabularData" => "Tabular Data",
    "TypeParameters" => "Type Parameters",
    "ImageFormats" => "Image Formats",
    "GraphicalPlotting" => "Graphical Plotting",
    "ComputationalGeometry" => "Computational Geometry",
    "FloatingPoint" => "Floating Point",
    "NumericalAnalysis" => "Numerical Analysis",
    "LinearAlgebra" => "Linear Algebra",
    "MatrixTheory" => "Matrix Theory",
    "SparseMatrices" => "Sparse Matrices",
    "NumericalLinearAlgebra" => "Numerical Linear Algebra",
    "AppliedMath" => "Applied Math",
    "GeneralDifferentialEquations" => "General Differential Equations",
    "GraphTheory" => "Graph Theory",
    "AlgebraicGeometry" => "Algebraic Geometry",
    "AstroLibs" => "Astro Libraries",
    "MathematicalOptimization" => "Mathematical Optimization",
    "MonteCarlo" => "Monte Carlo Methods",
    "RegressionAnalysis" => "Regression Analysis",
    "TimeSeries" => "Time Series",
    "DistributedComputing" => "Distributed Computing",
    "ParallelComputing" => "Parallel Computing",
    "MicrosoftWindows" => "Microsoft Windows",
  )

  caps_sub_categories = Dict(
    "UNITTEST" => "Unit Tests",
    "DISCRETEMATH" => "Discrete Math",
    "OPERATIONSRESEARCH" => "Operations Research",
    "PROBABILISTICPROGRAMMING" => "Probabilistic Programming",
    "MACHINELEARNING" => "Machine Learning",
    "DOCUMENTATIONTOOLS" => "Documentation Tools",
    "AUDIO-VIDEO" => "Audio-Video",
    "BIOINFORMATICS" => "Bioinformatics",
    "GENOMICS" => "Genomics",
    "SOFTWARE" => "Software",
    "MATH" => "Math",
    "GRAPHICS" => "Graphics",
    "INFOGRAPHICS" => "Infographics",
    "CRYPTOGRAPHY" => "Cryptography",
    "ALGEBRA" => "Algebra",
    "WEB" => "Web",
    "STATISTICS" => "Statistics",
    "STOCHASTICS" => "Stochastics",
    "BENCHMARKS" => "Benchmarks",
  )

  sub_category_dict = merge(two_word_sub_categories, caps_sub_categories)

  for (cur_key, cur_value) in sub_category_dict
      decibans_db[decibans_db.sub_category .== cur_key, :sub_category] .= cur_value
  end

  return decibans_db
end
