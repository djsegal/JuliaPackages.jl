function scrape_general_packages()
  isdir("../tmp/General") || run(
    `git clone "https://github.com/JuliaRegistries/General" ../tmp/General`
  )

  cur_packages = []
  cur_owners = []
  cur_shallow = []

  gitlab_packages = []

  for cur_char in 'A':'Z'
    for cur_package in readdir("../tmp/General/$(cur_char)")
      startswith(cur_package, ".") && continue

      package_dict = Pkg.TOML.parsefile(
        "../tmp/General/$(cur_char)/$(cur_package)/Package.toml"
      )

      package_name = package_dict["name"]
      package_url = package_dict["repo"]

      if occursin("gitlab.com", package_url)
        push!(gitlab_packages, package_name)
        continue
      else
        @assert occursin("github.com", package_url)
      end

      @assert endswith(package_url, ".git")
      package_url = replace(package_url, ".git" => "")

      cur_owner, cur_package = split(
        replace(package_url, ".jl" => ""), "/"
      )[end-1:end]

      if package_name == "StatPlots"
        cur_package = "StatPlots"
      else
        @assert lowercase(package_name) == lowercase(cur_package)
      end

      push!(cur_packages, package_name)
      push!(cur_owners, cur_owner)

      if !isfile("../tmp/General/$(cur_char)/$(cur_package)/Deps.toml")
        push!(cur_shallow, Set())
        continue
      end

      deps_dict = Pkg.TOML.parsefile(
        "../tmp/General/$(cur_char)/$(cur_package)/Deps.toml"
      )

      push!(
        cur_shallow, Set(Base.Iterators.flatten(map(keys,values(deps_dict))))
      )
    end
  end

  cur_request = JSON.parse(
    String(HTTP.get("https://api.github.com/repos/JuliaLang/julia/contents/stdlib").body)
  )

  other_list = [
    gitlab_packages...,
    "Pkg",
    "Statistics"
  ]

  for cur_item in cur_request
    (cur_item["type"] == "dir") || continue
    push!(other_list, cur_item["name"])
  end

  for cur_set in cur_shallow
    for cur_value in other_list
      ( cur_value in cur_set ) || continue
      delete!(cur_set, cur_value)
    end
  end

  cur_dict = OrderedDict(zip(cur_packages, cur_shallow))

  while true
    has_added = false

    for (cur_key, cur_values) in cur_dict
      cur_set = [cur_values...]

      for cur_value in cur_values
          @assert cur_value in keys(cur_dict)
          append!(cur_set, cur_dict[cur_value])
      end

      cur_set = Set(cur_set)
      (cur_set == cur_values) && continue

      cur_dict[cur_key] = cur_set
      has_added = true
    end

    has_added || break
  end

  cur_deep = collect(map(
    cur_tuple -> Set(setdiff(cur_tuple...)),
    zip(values(cur_dict), cur_shallow)
  ))

  for (cur_package, cur_set) in zip(cur_packages, cur_deep)
    ( cur_package in cur_set ) || continue
    delete!(cur_set, cur_package)
  end

  cur_shallow = map(cur_entry -> keys(cur_entry.dict), cur_shallow)
  cur_deep = map(cur_entry -> keys(cur_entry.dict), cur_deep)

  general_db = DataFrame(
    package=cur_packages, owner=cur_owners,
    shallow=cur_shallow, deep=cur_deep
  )

  return general_db
end
