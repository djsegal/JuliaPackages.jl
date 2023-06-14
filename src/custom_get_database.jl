function custom_get_database(cur_name)
  cur_file = "data/$(cur_name).csv"

  if isfile(cur_file)
    work_db = coalesce.(
      CSV.read(cur_file, DataFrame), ""
    )

    if cur_name == "general"
      cur_db = deepcopy(work_db)

      select!(cur_db, Not(:shallow_depending))
      select!(cur_db, Not(:deep_depending))

      cur_db[!, :shallow_depending] = _custom_database_column_clean(work_db.shallow_depending)
      cur_db[!, :deep_depending] = _custom_database_column_clean(work_db.deep_depending)

      select!(cur_db, Not(:shallow_dependents))
      select!(cur_db, Not(:deep_dependents))

      cur_db[!, :shallow_dependents] = _custom_database_column_clean(work_db.shallow_dependents)
      cur_db[!, :deep_dependents] = _custom_database_column_clean(work_db.deep_dependents)
    else
      cur_db = work_db
    end
  else
    cur_db = getfield(JuliaPackages, Symbol("scrape_$(cur_name)_packages"))()
  end

  return cur_file, cur_db
end

function _custom_database_column_clean(cur_field)
  return map(
    cur_list -> cur_list == [""] ? [] : cur_list,
    map(
      cur_list -> replace.(cur_list, "'" => ""),
      (
        split.(map(
          cur_match -> ( isnothing(cur_match) ? "" : cur_match.match ),
          match.(r"(?<=\[).+(?=\])", cur_field)
        ), r"\s*\,\s*")
      )
    )
  )
end
