function hit_repo_api(general_db, decibans_db)
  cur_paths = package_paths(general_db, decibans_db)

  good_paths = _hit_repo_start(cur_paths)
  packages_db = _hit_repo_finish(good_paths, general_db)

  return good_paths, packages_db
end

function _hit_repo_start(cur_paths)
  good_paths = []

  @showprogress for cur_tuple in cur_paths
    cur_package, cur_path = cur_tuple

    package_file = "../tmp/packages/$(lowercase(cur_package)).json"

    cur_html = nothing
    is_cached = false

    for cur_attempt in 1:3
      check_cache = isfile(package_file) && cur_attempt == 1

      for includes_jl in [true, false]
        cur_headers = ["User-Agent" => "GitHub", "Accept" => "application/vnd.github.html"]

        if check_cache
          modified_since = Dates.unix2datetime( Base.Filesystem.mtime(package_file) )
          modified_since -= Dates.Day(2) + Dates.Hour(12)
          modified_since = Dates.format(modified_since, "e, dd u yyyy HH:MM:SS") * " GMT"

          push!(cur_headers, "If-Modified-Since" => modified_since)
        end

        try
          cur_request = HTTP.get(
            custom_make_url(cur_path, includes_jl), cur_headers,
            userinfo = """$(ENV["CLIENT_ID"])/$(ENV["CLIENT_SECRET"])"""
          )

          cur_html = String(cur_request.body)
          break
        catch cur_error
          isa(cur_error, HTTP.ExceptionRequest.StatusError) || rethrow(cur_error)

          if check_cache && cur_error.status == 304
            is_cached = true

            cur_html = open(package_file) do file ; read(file, String) ; end
            break
          end

          ( cur_error.status == 404 ) || rethrow(cur_error)
        end
      end

      isnothing(cur_html) || break
    end
    isnothing(cur_html) && continue

    if !is_cached
      open(package_file, "w") do io ; write(io, String(cur_html)) ; end
    end

    push!(good_paths, cur_tuple)
  end

  return good_paths
end

function _hit_repo_finish(good_paths, general_db)
  cur_paths = deepcopy(good_paths)

  cur_data_dict = OrderedDict(
    "package" => [],
    "owner" => [],
    "stargazers_count" => [],
    "description" => [],
    "homepage" => [],
    "pushed_at" => [],
    "updated_at" => [],
    "created_at" => [],
    "html_url" => [],
    "registered" => []
  )

  if isfile("../data/searched_paths.csv")
    searched_paths_db = CSV.read("../data/searched_paths.csv")

    searched_paths = collect(
      zip(searched_paths_db.package, searched_paths_db.path)
    )

    standard_packages = map(lowercase, map(first, cur_paths))
    for i in length(searched_paths):-1:1
      ( lowercase(searched_paths[i][1]) in standard_packages ) || continue
      deleteat!(searched_paths, i)
    end
    append!(cur_paths, searched_paths)

    cur_paths = sort(
      cur_paths, by = (cur_path) -> lowercase(first(cur_path))
    )
  end

  skip_keys = ["owner", "package", "registered"]

  for (cur_package, cur_path) in cur_paths
    package_file = "../tmp/packages/$(lowercase(cur_package)).json"

    if !isfile(package_file)
      package_file = "../tmp/searched/$(lowercase(cur_package)).json"
    end

    @assert isfile(package_file)

    push!(cur_data_dict["package"], cur_package)
    push!(cur_data_dict["owner"], split(cur_path, "/")[1])

    push!(cur_data_dict["registered"], cur_package in general_db.package)

    cur_json = JSON.parse(open(f->read(f, String), package_file))

    for (cur_key, cur_value) in cur_data_dict
      ( cur_key in skip_keys ) && continue

      if endswith(cur_key, "_at")
        push!(cur_value, DateTime(chop(cur_json[cur_key])))
      else
        push!(cur_value, cur_json[cur_key])
      end
    end
  end

  packages_db = DataFrame(cur_data_dict)

  rename!(
    packages_db,
    :stargazers_count => :stars,
    :created_at => :created,
    :html_url => :github_url
  )

  packages_db[!, :updated] = maximum.(collect(zip(packages_db.pushed_at, packages_db.updated_at)))

  select!(packages_db, Not(:pushed_at))
  select!(packages_db, Not(:updated_at))

  packages_db.description = replace(packages_db.description, nothing=>missing)
  packages_db.homepage = replace(packages_db.homepage, nothing=>missing)

  packages_db = coalesce.(packages_db, "")

  return packages_db
end
