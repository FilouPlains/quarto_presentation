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
    local function split(value_list)
        local result = {}
        local SEPARATOR = ","

        for value in string.gmatch(value_list, "([^" .. SEPARATOR .. "]+)") do
            value = (string.gsub(value, "%[", ""))
            value = (string.gsub(value, "%]", ""))
            value = (string.gsub(value, "^%s*(.-)%s*$", "%1"))

            table.insert(result, value)
        end

        return result
    end

    local function test_size(value_list, key, length)
        if #value_list ~= length then
            error("Excepted 2 parameters for `" .. key .. '`. Got "' .. #value_list .. '".')
        end
    end

    local parameter = ""
    local viewer = ""

    for key, value in pairs(kwargs) do
	    print(key, value)
        if key == "transparent" and value then
            viewer = viewer .. "\nviewer.plugin.canvas3d.setProps({transparentBackground: true});"
        elseif not string.find(key, "load") then
            if value ~= "true" and value ~= "false" then
                value = '"' .. value .. '"'
            end

            parameter = parameter .. "\n" .. key .. ": " .. value .. ","
        else
            if key == "loadPdb" then
                viewer = viewer .. '\nviewer.loadPdb("' .. value .. '");'
            elseif key == "loadAlphaFoldDb" then
                viewer = viewer .. '\nviewer.loadAlphaFoldDb("' .. value .. '");'
            elseif key == "loadStructureFromUrl" then
                local value_list = split(value)
                test_size(value_list, key, 2)

                viewer = viewer .. '\nviewer.loadStructureFromUrl("' .. value_list[1] .. '", "' .. value_list[2] .. '");'
            elseif key == "loadVolumeFromUrl" then
                local value_list = split(value)
                test_size(value_list, key, 3)

                viewer = viewer
                    .. '\nviewer.loadVolumeFromUrl({url: "'
                    .. value_list[1]
                    .. '", format: "'
                    .. value_list[2]
                    .. '", isBinary: '
                    .. value_list[3]
                    .. ',}, [{type: "relative", value: 0}]);'
            elseif key == "loadTrajectory" then
                local value_list = split(value)
                test_size(value_list, key, 5)

                viewer = viewer
                    .. '\nviewer.loadTrajectory({model: {kind: "model-url", url: "'
                    .. value_list[1]
                    .. '", format: "'
                    .. value_list[2]
                    .. '",}, coordinates: {kind: "coordinates-url", url: "'
                    .. value_list[3]
                    .. '", format: "'
                    .. value_list[4]
                    .. '", isBinary: '
                    .. value_list[5]
                    .. ",}});"
            end
        end
    end

    quarto.doc.add_html_dependency({
        name = "molstar",
        version = "4.18.0",
        scripts = { "html_dependency/molstar.js" },
        stylesheets = { "html_dependency/molstar.css" },
    })

    if id == nil then
        id = 0
    else
        id = id + 1
    end

    local html_code = string.format(
        [[
<iframe id="iframe-id-%s" class="molstar_app" seamless="" allow="fullscreen" style="width: 100%%; height: 75%%;" srcdoc='
    <html>
        <head>
           <script src="https://molstar.org/viewer/molstar.js"></script>
           <link rel="stylesheet" href="https://molstar.org/viewer/molstar.css" />
	   	   <style>
               div.molstar_app {
                   width: 100%%;
                   height: 800px;
               }

               div.msp-plugin,
               div.msp-plugin div.msp-viewport {
                   background-color: #0000;
               }

               canvas {
                   background: none !important;
               }
	   </style>

        </head>

        <body>
            <div id="app-id-%s" class="molstar_app"></div>

            <script type="text/javascript">
                molstar.Viewer.create("app-id-%s", {%s
                }).then(viewer => {%s
                });


            </script>
        </body>
    </html>
'></iframe>
  ]],
        id,
        id,
        id,
        parameter,
        viewer
    )

    return pandoc.RawBlock("html", html_code)
end
