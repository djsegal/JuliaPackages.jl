import Gumbo.text

function custom_text(cur_doc::HTMLDocument)
    string_parts = []
    for elem in PreOrderDFS(cur_doc.root)
        isa(elem, HTMLText) || continue
        push!(string_parts, Gumbo.text(elem))
    end
    return join(string_parts, " ")
end
