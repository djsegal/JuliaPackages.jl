function scrape_general_packages()
  isdir("tmp/General") || run(
    `git clone "https://github.com/JuliaRegistries/General" tmp/General`
  )

  run(`git -C tmp/General pull`)
  run(`git -C tmp/General fetch --all`)
  run(`git -C tmp/General reset origin --hard`)

  cur_packages = []
  cur_owners = []
  cur_shallow_depending = []

  gitlab_packages = []
  independent_packages = []
  other_domain_packages = []

  rename_dict = Dict()

  for cur_char in 'A':'Z'
    for cur_package in readdir("tmp/General/$(cur_char)")
      startswith(cur_package, ".") && continue

      package_dict = Pkg.TOML.parsefile(
        "tmp/General/$(cur_char)/$(cur_package)/Package.toml"
      )

      package_name = package_dict["name"]
      package_url = package_dict["repo"]

      if occursin("gitlab.com", package_url)
        push!(gitlab_packages, package_name)
        continue
      elseif !occursin("github.com", package_url)
        push!(other_domain_packages, package_name)
        continue
      end

      @assert endswith(package_url, ".git")
      package_url = replace(package_url, ".git" => "")

      cur_owner, cur_package = split(
        replace(package_url, ".jl" => ""), "/"
      )[end-1:end]

      if lowercase(package_name) != lowercase(cur_package)
        println(["renamed", package_name, cur_package])
        rename_dict[package_name] = cur_package
        package_name = cur_package
      end

      if package_name in cur_packages
        continue
      end

      push!(cur_packages, package_name)
      push!(cur_owners, cur_owner)

      deps_file = "tmp/General/$(cur_char)/$(cur_package)/Deps.toml"
      if !isfile(deps_file)
        push!(cur_shallow_depending, Set())
        continue
      end

      deps_dict = Compress.load(deps_file)
      if isempty(deps_dict)
        push!(cur_shallow_depending, Set())
        continue
      end

      versions_file = "tmp/General/$(cur_char)/$(cur_package)/Versions.toml"
      @assert isfile(versions_file)

      versions_toml = Pkg.TOML.parsefile(versions_file)
      package_version = maximum(vparse.(keys(versions_toml)))

      if !haskey(deps_dict, package_version)
        push!(independent_packages, package_name)
        push!(cur_shallow_depending, Set())

        continue
      end

      package_dependencies = Set(keys(deps_dict[package_version]))
      push!(cur_shallow_depending, package_dependencies)
    end
  end

  @show independent_packages
  @show gitlab_packages
  @show other_domain_packages

  cur_request = JSON.parse(
    String(HTTP.get("https://api.github.com/repos/JuliaLang/julia/contents/stdlib").body)
  )

  other_list = [
    gitlab_packages...,
    other_domain_packages...,
    "Pkg",
    "Statistics"
  ]

  for cur_item in cur_request
    (cur_item["type"] == "dir") || continue
    push!(other_list, cur_item["name"])
  end

  for cur_set in cur_shallow_depending
    for cur_value in other_list
      ( cur_value in cur_set ) || continue
      delete!(cur_set, cur_value)
    end
  end

  for (cur_index, cur_set) in enumerate(cur_shallow_depending)
    new_values = []
    for cur_value in cur_set
      if cur_value in keys(rename_dict)
        cur_value = rename_dict[cur_value]
      end
      push!(new_values, cur_value)
    end
    cur_shallow_depending[cur_index] = Set(new_values)
  end

  cur_dict = OrderedDict(zip(cur_packages, cur_shallow_depending))

  bad_package_names = []

  while true
    has_added = false

    for (cur_key, cur_values) in cur_dict
      cur_set = [cur_values...]

      for cur_value in cur_values
        if cur_value in keys(cur_dict)
          append!(cur_set, cur_dict[cur_value])
        else
          if !(cur_value in bad_package_names)
            push!(bad_package_names, cur_value)
            println("Invalid package name: " * cur_value)
          end
        end
      end

      cur_set = Set(cur_set)
      (cur_set == cur_values) && continue

      cur_dict[cur_key] = cur_set
      has_added = true
    end

    has_added || break
  end

  cur_deep_depending = collect(map(
    cur_tuple -> Set(setdiff(cur_tuple...)),
    zip(values(cur_dict), cur_shallow_depending)
  ))

  for (cur_package, cur_set) in zip(cur_packages, cur_deep_depending)
    ( cur_package in cur_set ) || continue
    delete!(cur_set, cur_package)
  end

  cur_shallow_depending = map(_custom_sort_keys, cur_shallow_depending)
  cur_deep_depending = map(_custom_sort_keys, cur_deep_depending)

  cur_shallow_dependents = [ Set() for _ in 1:length(cur_packages) ]
  cur_deep_dependents = [ Set() for _ in 1:length(cur_packages) ]

  dependents_list = [
    (cur_shallow_depending, cur_shallow_dependents),
    (cur_deep_depending, cur_deep_dependents)
  ]

  for (cur_depending_list, cur_dependents_list) in dependents_list
    for (cur_package, cur_depending) in zip(cur_packages, cur_depending_list)
      for cur_depender in cur_depending
        if cur_depender in bad_package_names
          continue
        end

        cur_indices = findall(tmp_package -> tmp_package == cur_depender, cur_packages)
        @assert length(cur_indices) == 1
        cur_index = cur_indices[1]

        push!(cur_dependents_list[cur_index], cur_package)
      end
    end
  end

  for cur_index in 1:length(cur_packages)
    this_length_1 = length(cur_shallow_dependents[cur_index])
    this_length_2 = length(cur_deep_dependents[cur_index])

    that_length = length(unique([
          cur_shallow_dependents[cur_index]...,
          cur_deep_dependents[cur_index]...
    ]))

    @assert this_length_1 + this_length_2 == that_length
  end

  cur_shallow_dependents = map(_custom_sort_keys, cur_shallow_dependents)
  cur_deep_dependents = map(_custom_sort_keys, cur_deep_dependents)

  general_db = DataFrame(
    package=cur_packages, owner=cur_owners,
    shallow_depending=cur_shallow_depending, deep_depending=cur_deep_depending,
    shallow_dependents=cur_shallow_dependents, deep_dependents=cur_deep_dependents
  )

  return general_db
end

_custom_sort_keys(cur_entry) = sort(collect(keys(cur_entry.dict)))
