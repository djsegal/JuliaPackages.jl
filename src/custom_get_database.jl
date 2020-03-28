function custom_get_database(cur_name)
  cur_file = "../data/$(cur_name).csv"

  if isfile(cur_file)
    cur_db = coalesce.(
      DataFrame(CSV.read(cur_file)), ""
    )
  else
    cur_db = getfield(JuliaPackages, Symbol("scrape_$(cur_name)_packages"))()
  end

  return cur_file, cur_db
end
