function scrape_trending_packages()
  frequency_list = ["daily", "weekly", "monthly"]

  source_dict = Dict(
    "repos" => "/",
    "users" => "/developers/"
  )

  trending_dict = Dict()

  for (cur_source, cur_path) in source_dict
    for cur_freq in frequency_list

      cur_http = HTTP.get("https://github.com/trending$(cur_path)julia?since=$(cur_freq)")
      cur_html = parsehtml(String(cur_http.body))

      cur_items = eachmatch(Selector("a:contains('.jl')"), cur_html.root)

      cur_packages = map(
        cur_item -> replace(strip(cur_item.children[length(cur_item.children)].text), ".jl" => ""),
        cur_items
      )

      trending_dict["$(cur_source)_$(cur_freq)"] = cur_packages
    end
  end

  package_list = sort(collect(Set(Base.Iterators.flatten(values(trending_dict)))))

  database_dict = OrderedDict()

  database_dict["package"] = package_list

  for (cur_key, cur_value) in trending_dict
    work_list = []
    for cur_package in package_list
      push!(work_list, cur_package in cur_value)
    end
    database_dict[cur_key] = work_list
  end

  trending_data = DataFrame(database_dict)

  return trending_data
end
