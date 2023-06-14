function categorize_prompt(categories_dict, package_name, package_description, package_readme)
  prompt = """
  I run a website called JuliaPackages.com. For this website we are categorizing the ~10k Julia Packages we know exist.
  From before, we had around 1k labeled. And these gave us the following categories (and sub-categories)
  This dict has categories as the keys and a list of its subcategories as its value

  """

  prompt *= categories_dict

  prompt *= """

  As mentioned our goal is to categorize Julia Packages. 10k of them, one at a time, into these categories (and hopefully/possibly sub-categories)

  Below here will be 3 pieces of information about a package. It's name, its description from Github, and the readme file
  Your goal is to provide a JSON list of guesses on categories and subcategories for the package I give you in this prompt
  (a bunch of you will be doing this process in parallel)

  So In this JSON list, I want each entry/row to have 4 fields/columns
  1) Category Name
  2) Sub-Category Name*
  3) Sureness Score**
  4) Notes***

  // these should be sorted from most sure to least sure
  // file should be N lines where each line is a array with 4 fields as values

  * Some categories do not have sub-categories, or have sub-categories that may not relate to this package. In those rows leave that field as the empty string ""
  (Please do not create new categories and sub-categories though. ONLY use ones from the dictionary above)

  ** The "Sureness Score" here is a rank from 1 to 5 of how sure you are with this category/sub-category labeling.
  (5 is for extreme confidence. 1 is for very low confidence. For weak package guesses, use lower values)

  Feel free to use any information you think you know about the packages subject material from outside sources!

  However try to be specific when labeling. Dont want everything labeled "Numerical Analysis".
  // this is Julia, most developers come from science background. i.e. find which science

  (Also, Please do not output anything except the JSON list! Include extra information/notes in the corresponding "Notes"!!)

  Here is the information for the Package we are categorizing

  Package Name: """

  prompt *= package_name * """

  Package Description:
  """

  if !isnothing(package_description)
    prompt *= "package_description"
  end

  max_readme_length = 7000

  if length(package_readme) > max_readme_length
    prompt *= """


    Package Readme [truncated]:
    """

    did_add = false
    for i in 0:5
      try
        prompt *= package_readme[1:max_readme_length+i]
      catch cur_error
        isa(cur_error, StringIndexError) || rethrow(cur_error)
        continue
      end
      did_add = true
      break
    end
    @assert did_add

    prompt *= """


    // Readme has been truncated

    """
  else
    prompt *= """


    Package Readme:
    """

    prompt *= package_readme
  end

  return prompt
end
