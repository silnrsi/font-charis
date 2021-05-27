function Link(el)
  el.target = string.gsub(el.target, "(.+)", "../../pdf/%0")
  el.target = string.gsub(el.target, "%.md", ".pdf")
  return el
end

function Image(el)
  el.src = string.gsub(el.src, "(.+)", "../../%0")
  return el
end
