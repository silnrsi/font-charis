function Link(el)
  --el.target = string.gsub(el.target, "(.+)", "../../pdf/%0")
  el.target = string.gsub(el.target, "(.+)", "")
  el.target = string.gsub(el.target, "%.md", ".pdf")
  el.target = string.gsub(el.target, "%.rawmd", ".md")
  return el
end

function Image(el)
  el.src = string.gsub(el.src, "(.+)", "../../%0")
  return el
end

function CodeBlock(el)
  el.text = string.gsub(el.text, "(.+)", "    %0")
  return el
end
