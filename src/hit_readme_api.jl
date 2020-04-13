function hit_readme_api(cur_paths)
  _hit_readme_api_start(cur_paths)
  _hit_readme_api_finish(cur_paths)

  return cur_paths
end

function _hit_readme_api_start(cur_paths)
  @showprogress for cur_tuple in cur_paths
    cur_package, cur_path = cur_tuple

    package_file = "../data/readme_html/$(lowercase(cur_package)).txt"

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
            custom_make_url(cur_path, includes_jl, "/readme"), cur_headers,
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

    if isnothing(cur_html)
      open(package_file, "w") do io ; write(io, "") ; end
      continue
    end

    if !is_cached
      open(package_file, "w") do io ; write(io, String(cur_html)) ; end
    end
  end
end

function _hit_readme_api_finish(cur_paths)
  @showprogress for cur_tuple in cur_paths
    cur_package, cur_path = cur_tuple

    package_file = "../data/readme_html/$(lowercase(cur_package)).txt"
    cur_html = open(package_file) do file ; read(file, String) ; end

    cur_text = custom_text(parsehtml(cur_html))
    cur_text = replace(cur_text, r"\s+" => " ")

    stop_words = stopwords(Languages.English())

    clean_text = strip(lowercase(cur_text))
    clean_text = replace(clean_text, r"[^a-zA-Z\s]" => " ")
    clean_text = replace(clean_text, r"\s+" => " ")

    split_text = split(clean_text)

    split_text = filter((cur_word) -> length(cur_word) >= 3, split_text)
    split_text = filter((cur_word) -> !(cur_word in stop_words), split_text)

    search_text = join(
      unique(split_text), " "
    )

    nlp_text = join(
      map(cur_word -> stem(Stemmer("english"), cur_word), split_text), " "
    )

    open("../data/readme_search/$(lowercase(cur_package)).txt", "w") do io ; write(io, search_text) ; end
    open("../data/readme_nlp/$(lowercase(cur_package)).txt", "w") do io ; write(io, nlp_text) ; end
  end
end
