function categorize_packages()
    @assert isdir("data/readme_html")
    @assert isfile("data/paths.csv")

    isdir("data/package_categories") || mkdir("data/package_categories")

    decibans_file, decibans_db = custom_get_database("decibans")
    general_file, general_db = custom_get_database("general")

    general_db, decibans_db = combine_datasets(general_db, decibans_db)

    categories_dict = _categorize_packages_dict(decibans_db)

    paths_db = CSV.read("data/paths.csv", DataFrame)
    good_paths = collect(zip(paths_db.package, paths_db.path))

    searched_paths = []

    # searched_paths_db = CSV.read("data/searched_paths.csv", DataFrame)
    # searched_paths = collect(zip(searched_paths_db.package, searched_paths_db.path))

    cur_paths = [good_paths..., searched_paths...]

    text_list = []

    package_count = 0

    @showprogress for cur_tuple in cur_paths
        cur_package, cur_path = cur_tuple
        cur_package in decibans_db.package && continue

        package_file = "tmp/packages/$(lowercase(cur_package)).json"
        if !isfile(package_file) ; continue ; end

        cur_html_2 = open(package_file) do file ; read(file, String) ; end
        github_json = JSON.parse(cur_html_2)

        if github_json["stargazers_count"] < 20 ; continue ; end
        package_count += 1

        output_file = "data/package_categories/$(lowercase(cur_package)).txt"
        if isfile(output_file) ; continue ; end

        package_file = "data/readme_html/$(lowercase(cur_package)).txt"
        cur_html_1 = open(package_file) do file ; read(file, String) ; end

        all_good = true
        category_output = nothing

        for cur_attempt in 1:10
            sleep(3)

            cur_prompt = categorize_prompt(
                categories_dict, cur_package, github_json["description"],
                replace(custom_text(parsehtml(cur_html_1)), r"\s+" => " ")
            )

            cur_request = nothing

            try
                cur_request = create_chat(
                    ENV["OPENAI_API_KEY"], "gpt-3.5-turbo",
                    [Dict("role" => "user", "content"=> cur_prompt)]
                )
            catch cur_error
                error_message = JSON.parse(
                    String(cur_error.response.body)
                )["error"]["message"]

                println([error_message, 222, cur_prompt])
                if contains(error_message, "Please reduce the length of the messages.")
                    rethrow(cur_error)
                end

                println(cur_error)
                continue
            end

            @assert !isnothing(cur_request)

            tmp_output = string(
                cur_request.response[:choices][begin][:message][:content]
            )

            tmp_output = replace(
                string(tmp_output), r"\][\s\n]*\,[\s\n]*\]" => "]]"
            )

            try
                tmp_output = JSON.parse(tmp_output)
            catch cur_error
                println([444,tmp_output,cur_error])
                continue
            end

            all_good = true
            for cur_row in tmp_output
                @assert length(cur_row) == 4
                if cur_row[4] != "" ; continue ; end
                all_good = false
            end

            if all_good
                category_output = tmp_output
                break
            end
        end

        @assert all_good
        open(output_file, "w") do io
            write(io, JSON.json(category_output))
        end
    end

    println(package_count)
end

function _categorize_packages_dict(decibans_db)
    cat_dict = Dict()
    for cur_category in sort(unique(decibans_db.category))
        sub_categories = sort(unique(decibans_db[decibans_db.category .== cur_category,"sub_category"]))
        cat_dict[cur_category] = filter(!isempty,sub_categories)
    end

    category_json = "{\n"
    for (cur_index, (cur_key, cur_values)) in enumerate(cat_dict)
        category_json *= "  '" * cur_key * "': ['" * join(cur_values, "', '") * "']"
        if cur_index == length(cat_dict) ; continue ; end
        category_json *= ",\n"
    end
    category_json *= "\n}"

    return category_json
end

# packages_db
# categorize_prompt
