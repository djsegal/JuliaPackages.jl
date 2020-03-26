function robust_relabel(decibans_db)
  count_dict = countmap(decibans_db.category)

  for (cur_key, cur_value) in count_dict
      ( cur_value < 9 ) || continue
      decibans_db = decibans_db[decibans_db.category .!= cur_key,:]
  end

  count_dict = countmap(decibans_db.sub_category)

  for (cur_key, cur_value) in count_dict
      ( cur_value < 9 ) || continue
      decibans_db[decibans_db.sub_category .== cur_key, :sub_category] .= ""
  end

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
