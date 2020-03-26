function combine_datasets(general_db, decibans_db)
    for cur_row in eachrow(general_db)
        cur_selector = lowercase.(decibans_db.package) .== lowercase(cur_row.package)

        decibans_db[cur_selector, :package] .= cur_row.package
        decibans_db[cur_selector, :owner] .= cur_row.owner
    end

    insertcols!(decibans_db, 1, :id => 1:nrow(decibans_db))

    lower_packages = lowercase.(decibans_db.package)

    seen_packages = []
    bad_indices = []

    for cur_package in lower_packages
        cur_package in seen_packages && continue
        push!(seen_packages, cur_package)

        sub_packages = decibans_db[lower_packages .== cur_package,:]
        nrow(sub_packages) == 1 && continue

        if length(unique(lowercase.(sub_packages.owner))) > 1
            append!(bad_indices, sub_packages.id)
            continue
        end

        cur_items = Set()
        for cur_row in eachrow(sub_packages)
            cur_tuple = (cur_row.category, cur_row.sub_category)
            if cur_tuple in cur_items
                push!(bad_indices, cur_row.id)
                continue
            end
            push!(cur_items, cur_tuple)
        end
    end

    decibans_db = decibans_db[in.(decibans_db.id,Ref(bad_indices)) .== 0, :]

    select!(decibans_db, Not(:id))

    return (general_db, decibans_db)
end
