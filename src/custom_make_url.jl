function custom_make_url(cur_path, includes_jl=true, append_string="")
  if includes_jl
    endswith(cur_path, ".jl") || ( cur_path *= ".jl" )
  else
    cur_path = replace(cur_path, ".jl" => "")
  end

  cur_url = "https://api.github.com/repos/" * cur_path * append_string

  cur_url *= "?" * "client_id=" * ENV["CLIENT_ID"]
  cur_url *= "&" * "client_secret=" * ENV["CLIENT_SECRET"]

  return cur_url
end
