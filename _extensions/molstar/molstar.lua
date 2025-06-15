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


function molstar(args, kwargs)
  local function get(value, default)
    return (#value > 0) and value or default
  end

  quarto.doc.add_html_dependency({
    name = "molstar",
    version = "4.18.0",
    scripts = {"html_dependency/molstar.js"},
    stylesheets = {"html_dependency/molstar.css"}
  })

  if id == nil then
    id = 0
  else
    id = id + 1
  end

  local html_code = string.format([[
    <div id="app-id-%s" class="molstar_app"></div>

    <script type="text/javascript">
        molstar.Viewer.create("app-id-%s", {
            emdbProvider: '%s',
            pdbProvider: '%s',
            layoutIsExpanded: %s,
            layoutShowControls: %s,
            layoutShowLeftPanel: %s,
            layoutShowLog: %s,
            layoutShowRemoteState: %s,
            layoutShowSequence: %s,
            viewportShowAnimation: %s,
            viewportShowControls: %s,
            viewportShowExpand: %s,
            viewportShowSelectionMode: %s,
            viewportShowSettings: %s,
        }).then((viewer) => {
            viewer.loadSnapshotFromUrl((url = "structure.molx"), "molx");
        });
    </script>
  ]],
    id,
    id,
    get(kwargs["emdbProvider"], "rcsb"),
    get(kwargs["pdbProvider"], "rcsb"),
    get(kwargs["layoutIsExpanded"], "true"),
    get(kwargs["layoutShowControls"], "true"),
    get(kwargs["layoutShowLeftPanel"], "true"),
    get(kwargs["layoutShowLog"], "true"),
    get(kwargs["layoutShowRemoteState"], "true"),
    get(kwargs["layoutShowSequence"], "true"),
    get(kwargs["viewportShowAnimation"], "true"),
    get(kwargs["viewportShowControls"], "true"),
    get(kwargs["viewportShowExpand"], "true"),
    get(kwargs["viewportShowSelectionMode"], "true"),
    get(kwargs["viewportShowSettings"], "true")
  )

  return pandoc.RawBlock("html", html_code)
end
