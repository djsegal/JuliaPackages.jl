function hit_repo_api(general_db, decibans_db)
  cur_paths = package_paths(general_db, decibans_db)

  good_paths = _hit_repo_start(cur_paths)
  packages_db = _hit_repo_finish(good_paths)

  return good_paths, packages_db
end

function _hit_repo_start(cur_paths)
  good_paths = []

  cur_headers = ["User-Agent" => "GitHub", "Accept" => "application/vnd.github.html"]

  @showprogress for cur_tuple in cur_paths
    cur_package, cur_path = cur_tuple

    package_file = "../tmp/packages/$(lowercase(cur_package)).json"

    if isfile(package_file)
      push!(good_paths, cur_tuple)
      continue
    end

    cur_request = nothing
    for cur_attempt in 1:3
      for includes_jl in [true, false]
        try
          cur_request = HTTP.get(
            custom_make_url(cur_path, includes_jl), cur_headers,
            userinfo = """$(ENV["CLIENT_ID"])/$(ENV["CLIENT_SECRET"])"""
          )

          break
        catch cur_error
          isa(cur_error, HTTP.ExceptionRequest.StatusError) || rethrow(cur_error)
          ( cur_error.status == 404 ) || rethrow(cur_error)
        end
      end

      isnothing(cur_request) || break
    end
    isnothing(cur_request) && continue

    cur_html = String(cur_request.body)
    open(package_file, "w") do io ; write(io, String(cur_html)) ; end

    push!(good_paths, cur_tuple)
  end

  return good_paths
end

function _hit_repo_finish(cur_paths)
  cur_data_dict = OrderedDict(
    "package" => [],
    "stargazers_count" => [],
    "description" => [],
    "homepage" => [],
    "pushed_at" => [],
    "updated_at" => [],
    "created_at" => []
  )

  for (cur_package, cur_path) in cur_paths
    package_file = "../tmp/packages/$(lowercase(cur_package)).json"
    @assert isfile(package_file)

    push!(cur_data_dict["package"], cur_package)

    cur_json = JSON.parse(open(f->read(f, String), package_file))

    for (cur_key, cur_value) in cur_data_dict
      ( cur_key == "package" ) && continue
      if endswith(cur_key, "_at")
        push!(cur_value, DateTime(chop(cur_json[cur_key])))
      else
        push!(cur_value, cur_json[cur_key])
      end
    end
  end

  packages_db = DataFrame(cur_data_dict)

  rename!(packages_db, :stargazers_count => :stars, :created_at => :created)

  packages_db[!, :updated] = maximum.(collect(zip(packages_db.pushed_at, packages_db.updated_at)))

  select!(packages_db, Not(:pushed_at))
  select!(packages_db, Not(:updated_at))

  packages_db.description = replace(packages_db.description, nothing=>missing)
  packages_db.homepage = replace(packages_db.homepage, nothing=>missing)

  packages_db = coalesce.(packages_db, "")

  return packages_db
end
