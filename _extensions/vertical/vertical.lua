--[[
     Shortcode handler for defining vertical slide sections in Quarto
     Reveal.js presentations.
     
     Usages
     ------
     ```markdown
     {{< vertical begin >}}
     
     # Vertical slide 1
     
     ---
     
     # Vertical slide 2
     
     {{< vertical end >}}
     ```
     
     Authors
     -------
     - Lucas ROUAUD, MIT 2025-06-03

     Parameters
     ----------
     args : `str`
         The function argument. whether `begin` to start the vertical slides
	 or `end` to end them.
	
     Returns
     -------
     `pandoc.RawBlock` or `pandoc.Null`
         Whether sections tags to inject to the final `.html` or nothing, if
	 wrong parameters provides.
     
     Warns
     -----
     - If wrong parameters given, raise a `warning()`.
--]]
function vertical(args)
  if args[1] == nil then
    error(
      "Vertical shortcode accept an argument. Get none. Use whether `begin` "
      .. "or `end`."
    )

    return pandoc.Null()
  end

  local position = pandoc.utils.stringify(args[1])

  if position == "begin" then
    return pandoc.RawBlock(
      "html",
      "</section>\n<section class='slide level0'>\n<section>"
    )
  end

  if position == "end" then
    return pandoc.RawBlock(
      "html",
      "</section>\n</section>\n<section class='slide level0'>"
    )
  end

  error(
    "Invalid argument to vertical shortcode: `"
    .. position
    .. "`. Use whether `begin` or `end`."
  )

  return pandoc.Null()
end
