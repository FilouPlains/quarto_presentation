--[[
    Generates an embeddable Mol* molecular viewer iframe with configurable
    loading options, passed as shortcode arguments from Quarto.

    This function processes parameters for Mol* Viewer initialization,
    including support for multiple data sources such as `PDB`, `AlphaFold`,
    and custom URLs. It handles raw JS injection and HTML composition
    for Quarto Reveal.js or HTML documents.

    Usages
    ------
    ```markdown
    {{< molstar
        loadPdb="7SGL"
        loadAlphaFoldDb="Q8W3K0"
        loadStructureFromUrl="[
          https://raw.githubusercontent.com/jmbuhr/quarto-molstar/refs/heads/main/www/example.xyz,
          xyz
        ]"
        loadVolumeFromUrl="[
          https://raw.githubusercontent.com/jmbuhr/quarto-molstar/refs/heads/main/www/density.cube,
          cube,
          false
        ]"
        viewportShowAnimation="false"
        emdbProvider="rcsb"
        transparent="true"
     >}}
    ```

    Authors
    -------
    Lucas ROUAUD, MIT 2025-06-24

    Parameters
    ----------
    args : `table`
        Currently unused placeholder, included for Quarto shortcode compatibility.

    kwargs : `table`
        A key-value table of string arguments for configuring the Mol* viewer.
        These can be rendering settings (e.g., `transparent`) or data loading
        operations (`loadPdb`, `loadStructureFromUrl`, etc.).

        Supported keys include:
        - `transparent`: `true` or `false` – sets a transparent background.
        - `loadPdb`: `str` – loads a PDB entry.
        - `loadAlphaFoldDb`: `str` – loads an AlphaFold entry.
        - `loadStructureFromUrl`: `str` – CSV of `[url, format]`.
        - `loadVolumeFromUrl`: `str` – CSV of `[url, format, isBinary]`.
        - `loadTrajectory`: `str` – CSV of `[modelUrl, modelFormat, coordUrl, coordFormat, isBinary]`.
	- Any parameters support by molstar, like `viewportShowAnimation="false"`.

    Returns
    -------
    `pandoc.RawBlock`
        The iframe code block containing the configured Mol* Viewer HTML
        and embedded JavaScript, ready to be rendered in the final output.

    Warns
    -----
    - Raises an `error()` if one of the loader keys has incorrect number
      of parameters (e.g., missing `format` or `isBinary` for `loadTrajectory`).
--]]
function molstar(args, kwargs)
    --[[
        Splits a comma-separated string into a cleaned Lua table of values.

        This function removes leading/trailing whitespace and optional square
        brackets (`[` and `]`) from each element. It is used to parse argument
        values passed as CSV strings for Mol* data loading operations.

        Authors
        -------
        Lucas ROUAUD, MIT 2025-06-24

        Parameters
        ----------
        value_list : `str`
            A string which is a comma-separated list, like `"[url,format]"`.

        Returns
        -------
        `table`
            A list of individual cleaned strings with no brackets and trimmed whitespace.

        Examples
        --------
        ```lua
        split("[pdb, cif]") --> { "pdb", "cif" }
        ```
    --]]
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

    --[[
        Checks that a parsed list contains the expected number of elements.

        If the provided `value_list` does not match the expected `length`,
        an error is raised indicating the mismatch. This helps validate
        loader arguments like `loadStructureFromUrl`, `loadTrajectory`, etc.

        Authors
        -------
        - Lucas ROUAUD, MIT 2025-06-24

        Parameters
        ----------
        value_list : `table`
            A list of parsed values to be validated.

        key : `str`
            The name of the key being validated, used in the error message.

        length : `int`
            The expected number of elements in `value_list`.

        Raises
        ------
        `error`
            If `#value_list` does not match `length`, an error is thrown
            with a descriptive message.

        Examples
        --------
        ```lua
        test_size({"a", "b"}, "loadStructureFromUrl", 2) --> passes
        test_size({"a"}, "loadStructureFromUrl", 2)      --> error
        ```
    --]]
    local function test_size(value_list, key, length)
        if #value_list ~= length then
            error("Excepted 2 parameters for `" .. key .. '`. Got "' .. #value_list .. '".')
        end
    end

    local parameter = ""
    local viewer = ""
    local width = "100%"
    local height = "100%"

    for key, value in pairs(kwargs) do
        if key == "transparent" and value then
            viewer = viewer .. "\nviewer.plugin.canvas3d.setProps({transparentBackground: true});"
        elseif key == "width" then
            width = value
        elseif key == "height" then
            height = value
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
<iframe id="iframe-id-%s" class="molstar_app" seamless="" allow="fullscreen" style="width: %s; height: %s;" srcdoc='
    <html>
        <head>
           <script src="https://molstar.org/viewer/molstar.js"></script>
           <link rel="stylesheet" href="https://molstar.org/viewer/molstar.css" />
	   	   <style>
               body, div.molstar_app {
                   width: 100%%;
                   height: 100%%;
		   margin: 0;
		   padding: 0;
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
        width,
	height,
        id,
        id,
        parameter,
        viewer
    )

    return pandoc.RawBlock("html", html_code)
end
