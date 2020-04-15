function hit_search_api()

  # hit api

  end_year = year(today())
  beg_year = 2012

  updated_cutoff = end_year - 2

  base_url = "https://api.github.com/search/repositories?"
  base_url *= "per_page=100&sort=updated&order=desc&q=.jl+in:name+language:julia+stars:>4+pushed:>$(updated_cutoff)"
  base_url *= "+created:"

  cur_headers = ["User-Agent" => "GitHub", "Accept" => "application/vnd.github.html"]

  cur_items = []

  @showprogress for cur_year in beg_year:end_year
    cur_url = base_url * string(cur_year)

    for page in 1:10
      cur_request = HTTP.get(
        cur_url * "&page=$(page)", cur_headers,
        userinfo = """$(ENV["CLIENT_ID"])/$(ENV["CLIENT_SECRET"])"""
      )

      request_headers = Dict(cur_request.headers)

      cur_remaining = parse(Int, request_headers["X-Ratelimit-Remaining"])

      if cur_remaining <= 1
        cur_seconds = 1.5 + (
          Dates.unix2datetime(
            parse(Int, Dict(cur_request.headers)["X-Ratelimit-Reset"])
          ) - now(Dates.UTC)
        ) / Millisecond(1000)

        sleep(cur_seconds)
      end

      request_json = JSON.parse(String(cur_request.body))

      @assert request_json["total_count"] <= 1000

      tmp_items = request_json["items"]

      append!(cur_items, tmp_items)

      ( length(cur_items) < 100 ) && break
    end
  end

  # transform json list to nested Dict

  package_dict = SortedDict()
  for cur_item in cur_items
    cur_key = replace(lowercase(cur_item["name"]), ".jl" => "")

    if !( cur_key in keys(package_dict) )
      package_dict[cur_key] = cur_item
      continue
    end

    if cur_item["stargazers_count"] < package_dict[cur_key]["stargazers_count"]
      continue
    end

    package_dict[cur_key] = cur_item
  end

  # build dataframe and save file

  foreach(rm, readdir("../tmp/searched", join=true))

  path_db_packages = []
  path_db_paths = []

  for (cur_key, cur_value) in package_dict
    push!(path_db_packages, replace(cur_value["name"], ".jl" => ""))
    push!(path_db_paths, lowercase(cur_value["full_name"]))

    package_file = "../tmp/searched/$(cur_key).json"
    open(package_file, "w") do io ; write(io, json(cur_value)) ; end
  end

  searched_paths_db = DataFrame(package=path_db_packages, path=path_db_paths)

  CSV.write("../data/searched_paths.csv", searched_paths_db)

  searched_paths = collect(
    zip(path_db_packages, path_db_paths)
  )

  return searched_paths
end
