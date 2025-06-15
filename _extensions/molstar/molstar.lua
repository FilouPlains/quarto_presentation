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
function molstar(args)
  if args[1] == nil then
    error(
      "Vertical shortcode accept an argument. Get none. Use whether `begin` "
      .. "or `end`."
    )

    return pandoc.Null()
  end

  if _G.id == nil then
    _G.id = 0
  else
    _G.id = _G.id + 1
  end

  print(_G.id)

  html_code = [[
    <div id="app-id" class="molstar_app"></div>

    <script type="text/javascript">
        let result = molstar.Viewer.create("app-id", {
            emdbProvider: "rcsb",
            layoutIsExpanded: true,
            layoutShowControls: false,
            layoutShowLeftPanel: false,
            layoutShowLog: false,
            layoutShowRemoteState: false,
            layoutShowSequence: false,
            pdbProvider: "rcsb",
            viewportShowAnimation: false,
            viewportShowControls: false,
            viewportShowExpand: false,
            viewportShowSelectionMode: false,
            viewportShowSettings: false,
        }).then((viewer) => {
            viewer.loadSnapshotFromUrl((url = "structure.molx"), "molx");
        });
    </script>
  ]]

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
