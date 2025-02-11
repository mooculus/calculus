
kpse.set_program_name "luatex"

local pl = require "penlight"
local path = pl.path

logging = require("luaxake-logging")
local compile = require "luaxake-compile"

GLOB_root_dir = path.abspath(".")

-- Natee just copying this cause it's easier. Should pass needed stuff in through command line args probably
config = {
  ---   will be set infra --- compile_sequence = {"pdf", "draft.html"},
  -- compile_sequence = {"pdf", "make4ht.html", "handout.pdf"},
  -- compile_sequence = {"pdf", "sagetex.sage", "pdf", "html"},
  -- see infra --   default_dependencies = { "xmPreamble.tex" },     -- add here e.g. xmPreamble, ximera.cls, ...
  compilers = {
    pdf = {
      -- this doesn't work well
      -- command = 'pdflatex -interaction=nonstopmode  -file-line-error -shell-escape  "\\PassOptionsToClass{tikzexport}{ximera}\\PassOptionsToClass{xake}{ximera}\\PassOptionsToClass{xake}{xourse}\\nonstopmode\\input{@{filename}}"',
      -- command = 'pdflatex -interaction=nonstopmode  -file-line-error -shell-escape  "\\PassOptionsToClass{xake}{ximera}\\PassOptionsToClass{xake}{xourse}\\input{@{filename}}"',
      command = 'pdflatex -interaction=nonstopmode  -file-line-error -shell-escape  "\\input{@{filename}}"',     -- mmm, this increases the .jax file !!!
      check_log = true,     -- check log
      status = 0,           -- check that the latex command return 0
      infix = "" ,          -- used for .handout, and .make4k4
      extension = "pdf",    -- not used ????
      post_command = 'post_process_pdf',
      download_folder = 'ximera-downloads/with-answers',
    },
    ["handout.pdf"] = {
      command = 'pdflatex -interaction=nonstopmode  -file-line-error -shell-escape  -jobname @{basename}.handout "\\PassOptionsToClass{handout}{ximera}\\PassOptionsToClass{handout}{xourse}\\input{@{filename}}"',
      check_log = true, -- check log
      status = 0, -- check that the latex command return 0
      extension = "handout.pdf",
      infix = "handout" ,
      post_command = 'post_process_pdf',
      download_folder = 'ximera-downloads/handouts',
    },
    -- 20241217: no longet use "html", but eg draft.html (this keeps logfiles etc from being overwritten ...)!
    ["draft.html"] = {
      command = "make4ht -l -c @{configfile} -f html5+dvisvgm_hashes -m draft -j @{basename}.draft -s @{make4ht_extraoptions} @{filename} 'svg,htex4ht,mathjax,-css' '' '' '--interaction=nonstopmode -shell-escape -file-line-error'",
      check_log = true, -- check log
      status = 0, -- check that the latex command return 0
      post_command = 'post_process_html',
      extension = "html",
      infix = "draft" ,
    },    
    -- alternatives, use at your own risk
    ["make4ht.html"] = {
      command = "make4ht -l -c @{configfile} -f html5+dvisvgm_hashes          -j @{basename}.make4ht -s @{make4ht_extraoptions} @{filename} 'svg,htex4ht,mathjax,-css' '' '' '--interaction=nonstopmode -shell-escape -file-line-error'",
      check_log = true, -- check log
      status = 0, -- check that the latex command return 0
      post_command = 'post_process_html',
      extension = "html",
      infix = "make4ht" ,
    },
    -- test: use 'tikz+' option (FAILS for some tikzpictures, eg with shading/patterns)
    ["tikz.html"] = {
      command = "make4ht -l -c @{configfile} -f html5+dvisvgm_hashes -m draft -j @{basename}.draft -s @{make4ht_extraoptions} @{filename} 'svg,htex4ht,mathjax,-css,tikz+' '' '' '--interaction=nonstopmode -shell-escape -file-line-error'",
      check_log = true, -- check log
      status = 0, -- check that the latex command return 0
      post_command = 'post_process_html',
      extension = "html",
      infix = "draft" ,
    },
    ["test.html"] = {
      -- command = "make4ht -f html5+dvisvgm_hashes -c @{configfile} -sm draft @{filename}",
      -- command = "make4ht -c @{configfile} -f html5+dvisvgm_hashes -s @{make4ht_mode} -a debug @{filename} 'svg,htex4ht,mathjax,-css,info,tikz+' '' '' '--interaction=nonstopmode -shell-escape -file-line-error'",
      command = "make4ht -l -c @{configfile} -f html5+dvisvgm_hashes          -j @{basename}.make4ht -s @{make4ht_extraoptions} @{filename} 'svg,htex4ht,mathjax,-css,info,tikz+' '' '' '--interaction=nonstopmode -shell-escape -file-line-error'",
      check_log = true, -- check log
      status = 0, -- check that the latex command return 0
      post_command = 'post_process_html',
      extension = "html",
      infix = "make4ht" ,
    },

    -- sage not tested/implemented !!!!
    ["sagetex.sage"] = {
      command = "sage @{output_file}",
      check_log = true, -- check log
      check_file = true, -- check if the sagetex.sage file exists
      status = 0, -- check that the latex command return 0
      extension = "sage",   -- ?
    },
    -- a dummy test: create .ddd files that contain the date ..
    ddd = {
      command = 'date >@{basename}.ddd',     
      status = 0, -- check that the command returns 0
    },
  },
  -- TeX macro's to use for dependency-checking in .tex files
  input_commands = {
    input=true, 
    include=true, 
    includeonly=true,
    activity=true, 
    practice=true, 
    activitychapter=true, 
    activitysection=true, 
    practicechapter=true, 
    practicesection=true, 
  }, 
  -- extensions to be kept by get_files (and thus for which fileinfo is collected)
  keep_extensions = {
    tex  = true,
    html = true,
    sty  = true,
 },
 -- list of 'infixes' to be cleaned by default
  clean_infixes = {
    "",
    ".make4ht",
    ".draft",
    ".handout",
 },
  -- automatically clean files immediately after each compilation
  -- the commented extensions might cause issues when automatically cleaned, as they may be needed for the next compilation
  clean_extensions = {
    -- "aux",
    "4ct",
    "4tc",
    "oc",
    "md5",
    "dpth",
    "out",
    -- "jax",
    "idv",
    "lg",
    "tmp",
    -- "xref",
    -- "log",
    "auxlock",
    "dvi",
    "scmd",
    "sout",
    "ids",
    "mw",
    "cb",
    "cb2",
  },
  documentclass_lines = 30,
  -- for debugging: dumps the 'fileinfo' of matching files
  -- make4ht_loglevel = "",
  make4ht_extraoptions= "",
  -- number of lines in tex files where we should look for \documentclass
  -- dump_fileinfo = "aFirstXourse.tex",
}

-- Start reading command line arguments for needed data
local file = {}
file.depends_on_files = {} -- Natee we can worry about dependencies later. hassle to pass them in command line rn
file.relative_path = arg[1]:sub(2)
file.absolute_path = arg[2]:sub(2)
file.absolute_dir = arg[3]:sub(2)
file.relative_dir = arg[4]:sub(2)
file.filename = arg[5]:sub(2)

logging.set_outfile(path.abspath("bake-" .. tostring(file.filename) .. ".log")) 
local log = logging.new("bake-" .. tostring(file.filename))

file.basename = arg[6]:sub(2)
file.extension = arg[7]:sub(2)
if arg[8] == ":true" then
  file.exists = true
else
  file.exists = false
end
file.modified = tonumber(arg[9]:sub(2))
if arg[10] == ":true" then
  file.needs_compilation = true
else 
  file.needs_compilation = false
end
file.tex_documentclass = arg[11]:sub(2)

config.compile_sequence = {}
local i = 12
while arg[i] ~= "BREAK" do
  table.insert(config.compile_sequence, arg[i]:sub(2))
  i = i + 1
end

config.output_formats = {}
while arg[i] ~= nil do
  table.insert(config.output_formats, arg[i]:sub(2))
  i = i + 1
end

config.configfile = "ximera.cfg"

-- End reading command line arguments for needed data

-- Start actual baking
log:info("Starting compilation of file: " .. tostring(file.absolute_path))
local start_time =  socket.gettime()
local compile_infos = compile.compile(file, config.compilers, config.compile_sequence,  config.output_formats, config.check)

if config.noclean then
  log:info("Skipping cleaning temp files")
else
  compile.clean(file, config.clean_extensions,config.clean_infixes)
end
local end_time =  socket.gettime()

log:statusf("Finished compiling " .. tostring(file.absolute_path) .. " in %.1f seconds", end_time - start_time)

-- print errors
for _, compile_info in ipairs(compile_infos) do
  log:info("File "..(compile_info.output_file or "UNKNOWN??") .." got status " .. (compile_info.status or 'NIL??') )

  if (compile_info.status or 0) > 0 then 
      for _, err in ipairs(compile_info.errors) do
        log:errorf("[%-10s] %s:%s", compile_info.compiler, compile_info.source_file, err.constructed_errormessage)
      end
  else
    if compile_info.post_processing_error then
        log:errorf("[%-10s] %s: %s", "post_command", compile_info.source_file, compile_info.post_processing_error)
    end
  end 
end

os.exit(0)








