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

  for sub_category in unique(decibans_db.sub_category)
    sub_category == "" && continue

    count_dict = countmap(decibans_db[decibans_db.sub_category .== sub_category, :category])
    length(count_dict) == 1 && continue

    used_category = collect(keys(count_dict))[
      findmax(collect(values(count_dict)) .* map(cur_key -> length(decibans_db[decibans_db.category .== cur_key, :category]), collect(keys(count_dict))))[2]
    ]

    decibans_db[decibans_db.sub_category .== sub_category, :category] .= used_category
  end

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
    "2DVectorGraphics" => "2D Vector Graphics",
    "AlgebraicGeometry" => "Algebraic Geometry",
    "AppliedMath" => "Applied Math",
    "AquaticEcology" => "Aquatic Ecology",
    "AssociationRule" => "Association Rule",
    "AstroLibs" => "Astro Libraries",
    "AstronomicalImaging" => "Astronomical Imaging",
    "AutomaticProgramming" => "Automatic Programming",
    "BinaryIO" => "Binary IO",
    "BiomedicalResearch" => "Biomedical Research",
    "BlackBoxTesting" => "Black Box Testing",
    "BooleanAlgebra" => "Boolean Algebra",
    "CloudComputing" => "Cloud Computing",
    "ClusterComputing" => "Cluster Computing",
    "CodeAnalyzer" => "Code Analyzer",
    "CollaborativeFiltering" => "Collaborative Filtering",
    "ColloidalChemistry" => "Colloidal Chemistry",
    "ComplexSystems" => "Complex Systems",
    "CompositeDataTypes" => "Composite Data Types",
    "ComputationalChemistry" => "Computational Chemistry",
    "ComputationalGeometry" => "Computational Geometry",
    "ComputerArithmetic" => "Computer Arithmetic",
    "ControlFlow" => "Control Flow",
    "DataFormats" => "Data Formats",
    "DataScience" => "Data Science",
    "Debian-Ubuntu" => "Debian-Ubuntu",
    "DimensionReduction" => "Dimension Reduction",
    "DistributedComputing" => "Distributed Computing",
    "DocumentGenerator" => "Document Generator",
    "DocumentProcessors" => "Document Processors",
    "EmbeddedSystems" => "Embedded Systems",
    "Executables" => "Executables",
    "Fedora-RHEL" => "Fedora-RHEL",
    "FileCompression" => "File Compression",
    "FiniteAutomata" => "Finite Automata",
    "FloatingPoint" => "Floating Point",
    "FluidDynamics" => "Fluid Dynamics",
    "FunctionalProgramming" => "Functional Programming",
    "GeneralDifferentialEquations" => "General Differential Equations",
    "GeneralIO" => "General IO",
    "GeneticProgramming" => "Genetic Programming",
    "GeometricProgramming" => "Geometric Programming",
    "GrammaticalEvolution" => "Grammatical Evolution",
    "GraphicalPlotting" => "Graphical Plotting",
    "GraphicDesign" => "Graphic Design",
    "GraphTheory" => "Graph Theory",
    "GridComputing" => "Grid Computing",
    "ImageFormats" => "Image Formats",
    "In-MemoryStorage" => "In-Memory Storage",
    "IntegralEquation" => "Integral Equation",
    "JobScheduler" => "Job Scheduler",
    "LaserPhysics" => "Laser Physics",
    "LinearAlgebra" => "Linear Algebra",
    "MaterialScience" => "Material Science",
    "MathematicalAnalysis" => "Mathematical Analysis",
    "MathematicalOptimization" => "Mathematical Optimization",
    "MatrixTheory" => "Matrix Theory",
    "MicrosoftWindows" => "Microsoft Windows",
    "MolecularBiology" => "Molecular Biology",
    "MolecularModelling" => "Molecular Modelling",
    "MonteCarlo" => "Monte Carlo Methods",
    "MultinomialLogisticRegression" => "Multinomial Logistic Regression",
    "NationalInstruments" => "National Instruments",
    "NeuralNetworks" => "Neural Networks",
    "Non-GraphicalPlotting" => "Non-Graphical Plotting",
    "NumericalAnalysis" => "Numerical Analysis",
    "NumericalLinearAlgebra" => "Numerical Linear Algebra",
    "ParallelComputing" => "Parallel Computing",
    "PatternMatching" => "Pattern Matching",
    "ProgramAnalysis" => "Program Analysis",
    "QuantumChemistry" => "Quantum Chemistry",
    "QuantumMechanics" => "Quantum Mechanics",
    "ReactiveProgramming" => "Reactive Programming",
    "RegressionAnalysis" => "Regression Analysis",
    "SavingJuliaObjects" => "Saving Julia Objects",
    "SchedulingAlgorithm" => "Scheduling Algorithm",
    "SetTheory" => "Set Theory",
    "SIMDComputing" => "SIMD Computing",
    "Single-CellSequencing" => "Single-Cell Sequencing",
    "Software" => "Software",
    "SolidGeometry" => "Solid Geometry",
    "SolidStateChemistry" => "Solid State Chemistry",
    "Sorting" => "Sorting",
    "SparseMatrices" => "Sparse Matrices",
    "SpecialFunctions" => "Special Functions",
    "StatisticalMechanics" => "Statistical Mechanics",
    "StatisticalTests" => "Statistical Tests",
    "StyleGuidelines" => "Style Guidelines",
    "SymbolicComputation" => "Symbolic Computation",
    "TabularData" => "Tabular Data",
    "TimeSeries" => "Time Series",
    "TouchScreen" => "Touch Screen",
    "TurnaroundTime" => "Turnaround Time",
    "TypeParameters" => "Type Parameters",
    "VirtualInstrumentSoftwareArchitecture" => "",
    "WorkerProcesses" => "Worker Processes"
  )

  case_sub_categories = Dict(
    "AERONAUTICS" => "Aeronautics",
    "ALGEBRA" => "Algebra",
    "ALGORITHMS" => "Algorithms",
    "AUDIO-VIDEO" => "Audio-Video",
    "BENCHMARKS" => "Benchmarks",
    "BIOINFORMATICS" => "Bioinformatics",
    "BIOMEDICINE" => "Biomedicine",
    "BIOSTATISTICS" => "Biostatistics",
    "BOTS" => "Bots",
    "BUILDAUTOMATION" => "Build Automation",
    "CARTOGRAPHY" => "Cartography",
    "CLIMATOLOGY" => "Climatology",
    "COMPILERS" => "Compilers",
    "COMPUTERPERFORMANCE" => "Computer Performance",
    "CONCURRENCY" => "Concurrency",
    "CONTINUOUSINTEGRATION" => "Continuous Integration",
    "COOKBOOKS" => "Cookbooks",
    "CRYPTOGRAPHY" => "Cryptography",
    "DEBUGGER" => "Debugger",
    "DISCRETEMATH" => "Discrete Math",
    "DOCUMENTATIONTOOLS" => "Documentation Tools",
    "ECOLOGY" => "Ecology",
    "ENGINES" => "Engines",
    "FRAMEWORKS" => "Frameworks",
    "GENOMICS" => "Genomics",
    "GEOSTATISTICS" => "Geostatistics",
    "GRAPHICS" => "Graphics",
    "graphics" => "Graphics",
    "INFOGRAPHICS" => "Infographics",
    "JULIADEVELOPMENT" => "Julia Development",
    "JUPYTERNOTEBOOKS" => "Jupyter Notebooks",
    "LOGGING" => "Logging",
    "MACHINELEARNING" => "Machine Learning",
    "MATH" => "Math",
    "MATLAB" => "Matlab",
    "METEOROLOGY" => "Meteorology",
    "MIOCROSCOPY" => "Miocroscopy",
    "MULTIVARIATESTATISTICS" => "Multivariate Statistics",
    "NETWORKING" => "Networking",
    "NEUROSCIENCE" => "Neuroscience",
    "OPERATIONSRESEARCH" => "Operations Research",
    "PHARMACOLOGY" => "Pharmacology",
    "PROBABILISTICPROGRAMMING" => "Probabilistic Programming",
    "PUZZLES" => "Puzzles",
    "REDUCE" => "Reduce",
    "REINFORCEMENTLEARNING" => "Reinforcement Learning",
    "RESOURCES" => "Resources",
    "SECURITY" => "Security",
    "SLIDES" => "Slides",
    "SOFTWARE" => "Software",
    "SPACE" => "Space",
    "SPEECHRECOGNITION" => "Speech Recognition",
    "STATICANALYSIS" => "Static Analysis",
    "STATISTICS" => "Statistics",
    "STOCHASTICS" => "Stochastics",
    "SUPERVISEDLEARNING" => "Supervised Learning",
    "TUTORIALS-WORKSHOPS" => "Tutorials and Workshops",
    "UNITTEST" => "Unit Tests",
    "UNSUPERVISEDLEARNING" => "Unsupervised Learning",
    "UTILS" => "Utils",
    "WEB" => "Web"
  )

  sub_category_dict = merge(two_word_sub_categories, case_sub_categories)

  for (cur_key, cur_value) in sub_category_dict
      decibans_db[decibans_db.sub_category .== cur_key, :sub_category] .= cur_value
  end

  return decibans_db
end
