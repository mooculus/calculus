# Luaxake

`luaxake` is a reimplementation in LUA of Ximera's original `xake` program, that was written in GO.
It provides a build tool for Ximera courses (`xake` should make you think of `make`).

It is strongly suggested to always run `luaxake` through the `xmlatex` wrapper script, and thus ONLY INSIDE A PROPERLY BUILD ximeralatex CONTAINER.
Usage of `luaxake` is only tested and supported inside such a container, e.g. in a Codespace or a container started with `xmlatex`. You can run `xmlatex bash` to get a shell inside the container.
`luaxake` should always be started from the root folder of your project. 

The main part of the reimplementation was done by Michal Hoftich (summer 2024), and it was further completed by Wim Obbels (jan 2025).

The `luaxake` program builds and publishes a Ximera project through

- '`bake`: convert to PDF and/or HTML all standalone TeX files in directories given as argument
  - find (interesting....) files, e.g .tex, .pdf, .html...
  - detect dependencies  (mainly relevant in the HTML case to get proper titles/abstracts for xourses out of .html files)
  - (re-)compile (only) if the files themselves or their dependencies have changed
  - only 'standalone' files are compiled, ie files that contain a `\documentclass` command
  - there are adhoc rules for files ending in _pdf.tex and _beamer.tex: 
    - for these files, no .html version is generated
    - for files XXX_pdf.tex files, an XXX_pdf.svg is generated, that can be included semi-automatically in a corresponding XXX.tex file. This has been used for cheatsheets.

- `name`: setup a destination ximera-server. This currently needs a GPG key, and is (still) implemented in `xmlatex`. This could/should change in/with a new ximera server setup....

- `frost`: create a git tag for publishing, containing the necessary output files and setting tome metadata
 in the generated file `metadata.json`

- `serve`: publish the (previously `frosted`) content to a (previously `named`) ximera server

- `clean` : remove non-reused temporary files. This is done by default by `bake`.
- `veryclean` : remove all reused temporary files, and all generated files (.pdf, .html, .aux, ...)

- `ghaction` : adhoc command specifically for Github Actions integrations


Note: there are currently (2025-01) also shorthands 'compile' and 'compilePdf' for respectively only-html and only-pdf generation. 
They are deprecated, but used in some VSCode tasks. Use `bake --compile pdf` or `bake --compile draft.html`.



# Usage:

```
    luaxake [options] command <path/to/directory...>
```


Possible commands are `bake`, `frost`, `serve` and a number of variants/alternatives/extensions.

One or more directories and/or TeX files can be given as argument.


## Options

For a full list of options, see `luaxake -h` or the `luaxake` source code. Main options are

- `-l`,`--loglevel` level  : set level of messages printed to the terminal. Possible
  values: `debug`, `info`, `status`, `warning`, `error`, `fatal`. Default value is `status`,
  which prints warnings, errors and status messages.

- `-s` : silent,  synonym of `-l status`
- `-v` : verbose, synonym of `-l info`
- `-d` : debug,   synonym of `-l debug`
- `-t` : debug,   synonym of `-l trace`

- `-f` : force, rebuild even when a file is considered uptodate, and/or git-push-force to serve 
- `--check` : do not do the actual compilations. (But as of 2025-01, the POST-PROCESSING is done!)
- `--noclean` : by deafult, temporary files that are not needed for subsequent compilations are automatically deleted. This option keeps them available.

- `--compile` target_list: overwrite the compilations to be done. targetlist can be a list of `pdf`, `draft.html`, `handout.pdf`. E.g `--compile pdf,handout.pdf,draft.html` generates three output files.

- `--settings` -- Lua script that can change Luaxake configuration settings.

Extra options for developers or advanced use cases:

- `-c`,`--config` -- name of TeX4ht config file. It can be full path to the
  config file, or just the name. If you pass just the filename, Luaxake will
  search first in the directory with the current TeX file, to support different
  config files for different projects, then in the current working directory,
  project root and local TEXMF tree.

NOTE 2025-01: there is currently some confusion with passing options from `xmlatex` to `lualatex`:
- general rule: options and commands that are not processed by `xmlatex` are passed to `luaxake`
- use the standard linux `--` trick to explicitly pass things to `luaxake`: xmlatex -- -t bake test.tex`
- suggest improvements via Issues/Pull requests.


# Lua settings  (implementation to be documented/improved)

You can set settings using a Lua script with the `-s` option. The script should 
only set the configuration values. For example, to change the command for HTML 
conversion, you can use the following settings file:

```Lua 
compilers.html.command = "make4ht -c @{config_file} @{filename} 'options'"
```

NOTE: this setup might still change, as it should be integrated with the (bash-syntax) config.txt of `xmlatex` !


## Available configuration settings

- `output_formats` -- list of extensions of output formats

```Lua
output_formats = {"html", "pdf", "sagetex.sage"},
```

OBSOLETE: this is calculated by `luaxake` now, based on the `compile_sequence`

NOTE 2025-01: there is currently NO sage support

- `compile_sequence` -- sequence  of compilers to be called on each TeX file (cfr `--compile` option)

```Lua
compile_sequence = {"pdf", "sagetex.sage", "pdf", "html"},
```

- `clean` -- list of extensions to be removed after compilation

```Lua
clean = { "aux", "4ct", "4tc", "oc", "md5", "dpth", "out", "jax", "idv", "lg", "tmp", "xref", "log", "auxlock", "dvi", "scmd", "sout" }
```

## Compilers

- `compilers` -- settings for compiler commands. Each compiler contains table with additional settings.

There are several available compilers, and more can be added in the settings:

- `pdf` -- command used for the PDF generation
- `html` -- (OBSOLETE) command used for the HTML generation
- `draft.html` -- command used for the HTML generation
- `sagetex.sage` -- command used for the `sagetex.sage` generation  (NOT YET IMPLEMENTED)

```Lua
compilers = {
  html = {
    command = "make4ht -f html5+dvisvgm_hashes -c @{config_file} -sm draft @{filename}",
    check_log = true, -- check log
    status = 0 -- check that the latex command return 0
  },
}
```

### Settings available in the `compiler` table:

- `check_log` -- should we check the log file for errors?
- `check_file` -- check if the file exists before compilation. It is used by `sage`, which must be executed only if `filename.sagetex.sage` exists.
- `status` -- expected status code from the command.
- `process_html` -- run HTML post-processing.
- `command` -- template for the command to be executed. `@{variable}` tag will be replaced with the content of variable. 

### Variables available in command templates:

  - `dir` -- relative directory path of the file 
  - `absolute_dir` -- absolute directory path of the file
  - `filename` -- filename of the file
  - `basename` -- filename without extension
  - `extension` -- file extension
  - `relative_path` -- relative path of the file 
  - `absolute_path` -- absolute path of the file
  - `exists` -- boolean, true if file exists
  - `config_file` -- TeX4ht config file
