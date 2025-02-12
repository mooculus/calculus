local M = {}
local pl = require "penlight"
local graph = require "luaxake-graph"
local log = logging.new("files")
local lfs = require "lfs"

local path = pl.path
local abspath = pl.path.abspath
local tablex = pl.tablex

GLOB_files = {}     -- global variable with all fileinfo collected with get_files  (caching...)



--- find TeX4ht config file 
--- @param filename string name of the config file
--- @param directories [string]
--- @return string path of the config file
local function find_config(filename, directories)
  -- the situation with the TeX4ht config file is a bit complicated
  -- it can be placed in the current directory, in the document root directory, 
  -- or in the kpse path. if it cannot be found in any of these places, 
  -- we will set it to config.config_file (presumably ximera.cfg)
  -- in any case, we must provide a full path to the config file, because it will 
  -- be used in different directories. 
  for _, dir in ipairs(directories) do
    local lpath = dir .. "/" .. filename
    if pl.path.exists(lpath) then
      log:trace("find_config found "..filename.. " in ".. lpath.."( from "..table.concat(directories,', ')..")")
      return lpath
    end
  end
  -- if we cannot find the config file in any directory, try to find it using kpse
  local lpath = kpse.find_file(filename, "texmfscripts")
  if lpath then
    log:trace("find_config found "..filename.. " in ".. lpath.."( from kpse texmfscripts)")
    return lpath 
  end
  -- lastly, test if it is a full path to the file
  if pl.path.exists(filename) then 
    log:trace("find_config found "..filename.. " ( as this file happens to exist)")
    return filename
  end
  -- xhtml is default TeX4th config file, use it if we cannot find a user config file
  -- return "xhtml"
  return config.config_file
end


--- get absolute and relative file path, as well as other file metadata
--- @param input_path string filename
--- @return fileinfo
local function dump_fileinfo(fileinfo)

  local filename = fileinfo.relative_path
  if logging.show_level <= logging.levels["debug"] and config.dump_fileinfo and filename:match(config.dump_fileinfo) then
    log:debugf("Dumping updated fileinfo for %s:", filename)
    pl.pretty.dump(fileinfo)
  end
end


--- get absolute and relative file path, as well as other file metadata
--- @param input_path string filename
--- @return fileinfo
local function get_fileinfo(input_path, use_no_cache)

  -- caching
  if not use_no_cache and GLOB_files[input_path] then
    log:tracef("Getting cached fileinfo for %s", input_path)
    return GLOB_files[input_path]
  end
  
  log:tracef("Getting fileinfo for %s (from folder %s)", input_path, lfs.currentdir())

  -- if root_folder and string.match(input_path, "^"..root_folder) then
  --   input_path = input_path:gsub("^"..root_folder, "")
  -- end

  local relative_path = path.normpath(input_path)     -- resolve potential ../ parts

  --- @class fileinfo
  --- @field relative_path  string        relative path of the file (to the root_folder)
  --- @field absolute_path  string        absolute path of the file
  --- @field absolute_dir   string        absolute directory path of the file
  --- @field filename       string        filename of the file
  --- @field basename       string        filename without extension
  --- @field extension      string        file extension
  --- @field exists         boolean       true if file exists
  --- @field modified       number        last modification time 
  --- @field needs_compilation boolean 
  --- @field depends_on_files  fileinfo[]    list of files the file depends on
  --- @field output_files      fileinfo[]
  --- @field config_file?   string        TeX4ht config file
  --- @field root_folder?   string        root folder
  --- @
  local fileinfo = {}
  
  fileinfo.relative_path = relative_path
  fileinfo.absolute_path = abspath(relative_path)
  -- fileinfo.absolute_dir  = abspath(dir)
  
  fileinfo.exists        = path.exists(relative_path)
  fileinfo.modified      = path.getmtime(relative_path)
  fileinfo.needs_compilation = false
  -- fileinfo.config_file   = config.config_file     -- always the same, unless overwritten somewhere ?

  fileinfo.relative_dir,  fileinfo.filename      = path.splitpath(relative_path)
  fileinfo.absolute_dir,  _                      = path.splitpath(fileinfo.absolute_path)
  fileinfo.basename,      fileinfo.extension     = fileinfo.filename:match("(.*)%.([^%.]+)$")
  fileinfo.basenameshort, fileinfo.extensionlong = fileinfo.filename:match("([^%.]*)%.(.+)$")


  -- fileinfo.depends_on_files  = {}
  -- fileinfo.output_files      = {}

  GLOB_files[fileinfo.relative_path] = fileinfo
  
  -- dump_fileinfo(fileinfo)   -- for debugging

  return fileinfo
end


--- get fileinfo for all files in a directory and it's subdirectories
--- @param dir string path to the directory
--- @param files? table retrieved files
--- @return fileinfo[]
local function get_files(dir)
  --dir = dir:gsub("/$", "")     -- remove potential trailing '/'
  dir = dir:gsub("^.//*", "")    -- remove potential leading './'     -- it confuses skipping hidden .xxx files/folders
  dir = path.normpath(dir)
  local all_filenames = {}

  if path.isfile(dir)  then
    all_filenames = { dir }
    log:tracef("get_files: considering %s", dir)
  elseif path.isdir(dir) then
    all_filenames = pl.dir.getallfiles(dir)
    log:tracef("get_files: considering %d files (for %s)", #all_filenames, dir)
  else
    all_filenames = { }
    log:errorf("get_files %s: no such file or directory", dir)
    return {}
  end


  local files = {}

  for _, filename in ipairs(all_filenames) do
    -- ext = path.extension(filename)

    -- local basename = filename:match(".*/(.*)$") or filename  -- Extract filename from path
    if filename:match("/%.") then  -- ignore every file/folder starting with a . (ie, containing xxx/.yyy )
      -- log:tracef("get_files skips %s", filename)
      goto next_file
    end

    ext = filename:match("%.([^%.]+)$")

    -- log:tracef("get_files adding %s (%s)", filename, ext)
    if config.keep_extensions[ext] then
      log:tracef("get_files adding %s", filename)

      finfo = get_fileinfo(filename)
      files[finfo.relative_path] = finfo
    end

    ::next_file::
  end

  return files

end


function filter_tex_files(tbl)
  local result = {}
  for _, entry in pairs(tbl) do
      if entry.extension == "tex" then
          table.insert(result, entry)
      end
  end
  return result
end

--- Detect if the output file needs recompilation
---@param tex fileinfo metadata of the main TeX file to be compiled
---@param outfile fileinfo metadata of the output file
---@return boolean
local function needs_compiling(tex, outfile)
  -- if the output file doesn't exist, it needs recompilation
  log:tracef("Does %s need compilation? %s",outfile.relative_path, outfile.exists and "It exists." or "It doesn't exist.")
  if not outfile.exists then return true end
  -- test if the output file is older if the main file or any dependency
  local status = tex.modified > outfile.modified
  if status then 
    log:debugf("TeX file %s has changed since compilation of %s",tex.relative_path, outfile.relative_path)
  end

  if not tex.depends_on_files  then
    log:warningf("File %s does not depend on any files ...?")
  else
  for filename, subfile in pairs(tex.depends_on_files or {}) do
    log:tracef("Check modified of subfile %s", subfile.relative_path)
    if not subfile.modified then
        log:warningf("No modified info for dependency %s of %s",filename,tex.relative_path)
        -- pl.pretty.dump(subfile)
    elseif subfile.modified > outfile.modified then
      log:tracef("Dependent file %s has changed since compilation of %s", subfile.relative_path,  outfile.relative_path)
      status = status or subfile.modified > outfile.modified
    end
  end
  end
  log:tracef("%s %s", outfile.relative_path, status and "needs compilation" or "does not need compilation")
  return status
end


--- update the list of files included in the given TeX file
--- @param fileinfo fileinfo TeX file metadata
--- @return 
local function update_depends_on_files(fileinfo)
  local filename    = fileinfo.absolute_path
  local relfilename = fileinfo.relative_path     -- for logging ...
  local current_dir = fileinfo.absolute_dir

  if fileinfo.depends_on_files and tablex.size(fileinfo.depends_on_files) > 0 then
    -- TODO: check this? Is it safe to skip? Should the duplicate work not be detected earlier?
    log:debugf("Mmm, %s already has %d dependent files! Skip potential duplicate work...?", relfilename, tablex.size(fileinfo.depends_on_files))
    return
  end

  fileinfo.depends_on_files = {}    -- update has ran, no files found (yet)
  
  local f, msg = io.open(filename, "r")
  if not f then
    log:errorf("Could not open file %s: %s",filename, msg)
    return
  end

    local content = f:read("*a")
    f:close()
    -- 
    -- Warning: this matching of commands is definitely not completely correct !!!
    --
    -- remove all comments   (otherwise also commented commands would be processed!)
    -- content = content:gsub("([^\\])%%.-\n", "%1\n")
    content = content:gsub("%%[^\n]*", "")
    -- remove all optional arguments (they break the matching infra!)
    content = content:gsub("%[[^%]]*%]", "")    
    -- remove verbatim environments
    content = content:gsub("\\begin{verbatim}.-\\end{verbatim}", "")  

    fileinfo.tex_documentclass = false    -- default, might be overwritten infra
    -- loop over all LaTeX commands with arguments
    -- for command, argument, argument2 in content:gmatch("\\(%w+)%s*{([^%}]+)}({[^%}]+})?") do
    -- for command, argument, argument2 in content:gmatch([[\\(%a+){([^}]+)}({([^}]+)})?]]) do
    for command, argument in content:gmatch("\\(%w+)%s*{([^%}]+)}[^{]") do

      -- log:tracef("MATCHED  command=%s and argument=%s", command, argument)
      -- add dependency if the current command is \input like
      --- local metadata = nil    -- should be fileinfo ...
      local included_file = nil
      local wanted_extension = nil
      if not fileinfo.tex_documentclass and command == "documentclass" then
        -- only process the first documentclass found (poor-mans prevention against later \documentclass in \verb or so ... !)
        log:debugf("%-40s has documentclass %s", relfilename, argument)
        fileinfo.tex_documentclass = argument
      elseif not fileinfo.has_title and (command == "title" or command == "xmtitle") then 
        -- only process the first title/xmtitle found (poor-mans prevention against later \documentclass in \verb or so ... !)
        log:debugf("%-40s has title %s", relfilename, argument)
        fileinfo.has_title = true
      elseif command == "dependsonpdf" then
        -- hack to include PDF (or SVG) eg of cheatsheets (that can/should not converted to HTML): a (dummy) \dependsonpdf{xxx} can explicitely mark the dependency of aaa.tex on aaa_pdf.tex)
        included_file = fileinfo.relative_path:gsub(".tex","_pdf.tex")
        log:debugf("%-40s explicitely dependsonpdf (%s, but use semi-hardcoded %s)", relfilename, argument, included_file)
        wanted_extension = "pdf"
      elseif fileinfo.tex_documentclass and config.input_commands[command] then   -- only process inputs AFTER the documentclass (and thus not INSIDE preambles etc) !!!
        -- log:tracef("Consider %s{%s}", command, argument)
        included_file = path.normpath(current_dir.."/"..argument)     -- make absolute dir, and remove potential ../ constructs
        if string.match(included_file,"[#\\]") then
          log:debugf("SKIPPING included file %s", included_file)  
          included_file=nil
        else
        wanted_extension = "html"    -- because the html will/might be read to get 
        if not path.isfile(included_file) then
          if not path.isfile(included_file..".tex") then
            if not path.isfile(included_file..".sty") then
              log:warningf("%-40s includes %s, but this file nor variants with .sty or .tex seem to exits", relfilename, included_file)
            else
              included_file = included_file..".sty"
            end
          else
            included_file = included_file..".tex"
          end
        end
        log:tracef("%-40s considering included file %s (from %s)", relfilename, path.relpath(included_file, GLOB_root_dir), included_file)
        included_file = path.relpath(included_file, GLOB_root_dir)      -- make relative path 
      end
      -- else
        -- log:tracef("Skipping command %s (arg=%s)", command, argument)   -- would log all commands in the .tex file .... !!!
      end
      

      if included_file then

          local included_fileinfo = get_fileinfo(included_file)

          log:debugf("%-40s depends on %s", relfilename, included_file)
          fileinfo.depends_on_files[included_file] = included_fileinfo


          -- log:tracef("Getting tex_file_with_status for included file %s", included_file)
          update_status_tex_file(included_fileinfo, {wanted_extension}, {wanted_extension} )
          for fname, finfo in pairs(included_fileinfo.depends_on_files) do
            if finfo.exists then
              log:debugf("%-40s indirectly depends on %s", relfilename, finfo.relative_path)
              fileinfo.depends_on_files[finfo.relative_path] = finfo
            else
              log:warningf("%-40s indirectly depends on non-existing file %s (%s); NOT ADDED TO DEPENDENT FILES", relfilename, finfo.relative_path, finfo.absolute_path)
            end  
  
          end
      end  -- included_file
    end  -- next command ...
    
    
    -- TERRIBLE HACK, now just for \execrciseCollection which has TWO arguments...
    for command, argument, argument2 in content:gmatch("\\(%w+)%s*{([^%}]+)}{([^%}]+)}") do

      -- log:tracef("MATCHED  command=%s and argument=%s and argument2=%s.", command, argument, argument2)
      -- add dependency if the current command is \input like
      --- local metadata = nil    -- should be fileinfo ...
      local included_file = nil
      local wanted_extension = nil
      if fileinfo.tex_documentclass and config.input2_commands[command] then   -- only process inputs AFTER the documentclass (and thus not INSIDE preambles etc) !!!
        -- log:tracef("Consider %s{%s}", command, argument)
        included_file = path.normpath(current_dir.."/"..argument..argument2)     -- make absolute dir, and remove potential ../ constructs
        if string.match(included_file,"[#\\]") then
          log:debugf("SKIPPING included file %s", included_file)  
          included_file=nil
        else
        wanted_extension = "html"    -- because the html will/might be read to get 
        if not path.isfile(included_file) then
          if not path.isfile(included_file..".tex") then
            if not path.isfile(included_file..".sty") then
              log:warningf("%-40s includes %s, but this file nor variants with .sty or .tex seem to exits", relfilename, included_file)
            else
              included_file = included_file..".sty"
            end
          else
            included_file = included_file..".tex"
          end
        end
        log:tracef("%-40s considering included file %s (from %s)", relfilename, path.relpath(included_file, GLOB_root_dir), included_file)
        included_file = path.relpath(included_file, GLOB_root_dir)      -- make relative path 
      end
      -- else
        -- log:tracef("Skipping command %s (arg=%s)", command, argument)   -- would log all commands in the .tex file .... !!!
      end
      

      if included_file then

          local included_fileinfo = get_fileinfo(included_file)

          log:debugf("%-40s depends on %s", relfilename, included_file)
          fileinfo.depends_on_files[included_file] = included_fileinfo


          -- log:tracef("Getting tex_file_with_status for included file %s", included_file)
          update_status_tex_file(included_fileinfo, {wanted_extension}, {wanted_extension} )
          for fname, finfo in pairs(included_fileinfo.depends_on_files) do
            if finfo.exists then
              log:debugf("%-40s indirectly depends on %s", relfilename, finfo.relative_path)
              fileinfo.depends_on_files[finfo.relative_path] = finfo
            else
              log:warningf("%-40s indirectly depends on non-existing file %s (%s); NOT ADDED TO DEPENDENT FILES", relfilename, finfo.relative_path, finfo.absolute_path)
            end  
  
          end
      end  -- included_file
    end  -- next command ...



    -- for ximera ducuments, add potential 'default dependensies', ie xmPreamble.tex, ximera.cfg, ...
    --    ( only xmPreamble.tex implemented and tested ...!)
    -- done here at the end, because tex_documentclass needs to be availbale ...
    if fileinfo.tex_documentclass == "ximera" or fileinfo.tex_documentclass == "xourse" then
      for _, dep in ipairs(config.default_dependencies or {}) do
        local dep_fileinfo = get_fileinfo(dep)
        dep_fileinfo.tex_documentclass = false      -- HACK: prevent compilation later
        if filename ~= dep_fileinfo.absolute_path then
          log:tracef("%-40s Adding default dependency %s",filename, dep)
          fileinfo.depends_on_files[dep] = dep_fileinfo
        else
          log:tracef("%-40s Skipping circular default dependency %s",relfilename, dep)
        end
      end
    end
  
    
  local deps = tablex.keys(fileinfo.depends_on_files)
  table.sort(deps)

  -- HINT: pipe output/logfile to "grep dependenc" to get all relevant info ...!
  if #deps == 0 then
    log:debugf("%-40s has no dependencies"    , relfilename)
  elseif #deps == 1 then
    log:debugf("%-40s has %2d dependency %s"  , relfilename, #deps, deps[1])
  elseif #deps < 10 then
    log:debugf("%-40s has %2d dependencies %s", relfilename, #deps, table.concat(deps,', '))
  else 
    log:debugf("%-40s has %3d dependencies, namely \ndependency %s", relfilename, #deps, table.concat(deps,",\ndependency "))
  end
end


--- sets metadata.output_files and metadata.needs_compilation (for given extensions as html, pdf, ..)
--- @param metadata metadata metadata of the TeX file
--- @param extensions table list of extensions
local function update_output_files(metadata, extensions)
  metadata.output_files_needed = {}
  local needs_compilation = false
  for _, extension in ipairs(extensions) do
    local out_file = get_fileinfo(metadata.relative_path:gsub("tex$", extension), true)   -- do not use cached info
    -- detect if the HTML file needs recompilation
    local status = needs_compiling(metadata, out_file)

    -- for some extensions (like sagetex.sage), we need to check if the output file exists 
    -- and stop the compilation if it doesn't
    -- TODO: check sagetex.sage stuff; 
    -- -- local compiler = compilers[extension] or {}
    -- -- if compiler.check_file and not path.exists(out_file.absolute_path) then
    if extension == "sagetex.sage" and not path.exists(out_file.absolute_path) then
      log:debug("Ignored output file doesn't exist: " .. out_file.absolute_path)
      status = false
    end
    
    out_file.needs_compilation = status
    out_file.extension         = extension
    
    needs_compilation = needs_compilation or status
    
    log:debugf("Marked output %-12s %-18s for %s",extension,  status and 'NEEDS_COMPILATIONS' or 'NO_COMPILATION', out_file.relative_path)
    
    -- output_files[#output_files+1] = out_file
    metadata.output_files_needed[extension]  = out_file
  end
  metadata.needs_compilation = needs_compilation

  log:infof( "Marked source %-12s %-18s for %s", metadata.extension, needs_compilation and 'NEEDS_COMPILATIONS' or 'NO_COMPILATION', metadata.relative_path)

  if metadata.tex_documentclass == "ximera" or metadata.tex_documentclass == "xourse"
  then
    metadata.config_file = config.config_file
  end

  -- removed finding config-file

end

--- create sorted table of files that needs to be compiled 
--- @param tex_files metadata[] list of TeX files metadata
--- @return metadata[] to_be_compiled list of files in order to be compiled
local function sort_dependencies(tex_files)
  -- create a dependency graph for files that needs compilation 
  -- the files that include other courses needs to be compiled after changed courses 
  -- at least that is what the original Xake command did. I am not sure if it is really necessary.
  log:tracef("Sorting dependencies")

  local Graph = graph:new()
  local used = {}
  local to_be_compiled = {}
  -- first add all used files
  for _, metadata in ipairs(tex_files) do
    log:tracef("Consider %s", metadata.relative_path)

    if metadata.needs_compilation then
      Graph:add_edge("root", metadata.relative_path)
      used[metadata.relative_path] = metadata
    end
  end
  
  -- now add edges to included files which needs to be recompiled
  for _, metadata in pairs(used or {}) do
    local current_name = metadata.relative_path
    log:tracef("Get used = %s (%s)",current_name, tablex.keys(metadata.depends_on_files))
    for filename, child in pairs(metadata.depends_on_files or {}) do
    -- for _, child in ipairs(metadata.dependecies or {}) do
      local name = child.relative_path
      log:tracef("Get child = %s",name)
      -- add edge only to files added in the first run, because only these needs compilation
      if used[name] then
        log:tracef("Added edge %s  - %s", current_name, name)
        Graph:add_edge(current_name, name)
      end
    end
  end
  log:tracef("Topographic sort")

  -- topographic sort of the graph to get dependency sequence
  local sorted, msg = Graph:sort()

  if not sorted then
    log:errorf("Could not sort dependency Graph: %s", msg)
    log:errorf("RETURNING UNSORTED LIST")
    return tex_files
  end
  
  -- we need to save files in the reversed order, because these needs to be compiled first
  -- and delete the dummy 'root' entry

  if not sorted[1] == "root" then
    log:errorf("The first entry of the sorted dependency list is NOT the dummy 'root' entry, but %s. BADBAD, this should not have happened...")
  else
    table.remove(sorted,1) -- remove the dummy entry
  end
  for i = #sorted, 1, -1 do
      local name = sorted[i]
      log:tracef("Adding file to be compiled %2d: %-30s (%s)",i ,name, used[name].relative_path)
      to_be_compiled[#to_be_compiled+1] = used[name]
  end
  return to_be_compiled
end


--- update the fileinfo ('metadata') of a tex-file, in particular the depends_on_files and output_files, for a given (set of) output_format(s)
--- @param metadata fileinfo  fileinfo of TeX-file to be updated, 
function update_status_tex_file(metadata, output_formats, compilers)
    log:tracef("update_status_tex_file %s (for output_formats=%s and compilers=%s)", metadata.relative_path, table.concat(output_formats,', '), table.concat(compilers,', '))

    local relfilename = metadata.relative_path

    if metadata.status_updated  then
      log:tracef("%-40s has already an updated status: SKIPPING" , relfilename)
      return
    end 

    update_depends_on_files(metadata)
    if not metadata.tex_documentclass then
        log:tracef("%-40s has no documentclass; skipping output", metadata.relative_path)
    
    else
        -- check for the need compilation
      update_output_files(metadata, output_formats)
      -- 20250109: SKIPPED finding config_file; now set above in update_output_files
    end

    metadata.status_updated = true   -- prevent reprocessing (e.g. for preambles ...)
    
  dump_fileinfo(metadata)     -- only for debugging
end

--- find TeX files that needs to be compiled in the directory tree
--- @param dir string root directory where we should find TeX files
--- @return metadata[] tex_files list of all these TeX files AND THE FILES THEY MIGHT DEPEND ON (potentially in OTHER directories)
function get_tex_files_with_status(dir, output_formats, compilers)
  log:debugf("Getting tex files in %s (for output_formats=%s and compilers=%s)", dir, table.concat(output_formats,', '), table.concat(compilers,', '))
  local files = get_files(dir, {})
  local tex_files = filter_tex_files(files)
  
  local tex_fileinfos = {}
  -- now check which output files needs a compilation
  log:tracef("Start getting status of %d tex files",  #tex_files)
  for _, metadata in ipairs(tex_files) do
    tex_fileinfos[metadata.relative_path] = metadata
    log:tracef("Adding main file to tex_fileinfo:  %s", metadata.relative_path)
    update_status_tex_file(metadata, output_formats, compilers)    -- collect depends_on_files ...
    for fname, finfo in pairs(metadata.depends_on_files) do
      log:tracef("Adding dependend file to tex_fileinfo:  %s", fname)
      tex_fileinfos[fname] = finfo
    end
    
  end

  return tex_fileinfos
end

M.get_tex_files_with_status = get_tex_files_with_status
M.update_output_files =  update_output_files
M.sort_dependencies = sort_dependencies
M.get_fileinfo  = get_fileinfo
M.dump_fileinfo = dump_fileinfo


return M
