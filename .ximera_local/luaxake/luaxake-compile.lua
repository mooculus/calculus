local M = {}
local lfs = require "lfs"
local error_logparser = require("make4ht-errorlogparser")
local pl = require "penlight"
local path = pl.path
local pldir = pl.dir
local plfile = pl.file
local html = require "luaxake-transform-html"
local files = require "luaxake-files"      -- for get_fileinfo
local frost = require "luaxake-frost"      -- for osExecute
local socket = require "socket"

local log = logging.new("compile")


local function parse_log_file(filename)
  -- log:errorf("PARSING %s", filename)
  local f = io.open(filename, "r")
  if not f then 
    log:warningf("Cannot open log file %s; SKIPPING parsing logfile for errors ", filename)
    return nil 
  end
  local content = f:read("*a")
  f:close()
  local result =  error_logparser.parse(content)
  log:tracef("PARSING got %s", result)
  return result
end

--
-- These next functions are/can be called by post_command in config.commands
-- HACK: these currently need to be global; TODO: fix!
-- The functions should return an updated 'cmd' structure, with eg
--  cmd.final_output_file = <the post-processed-output file>
--   cmd.status_post_command = "OK"
function post_process_html(cmd)
  -- simple wrapper to make it work in post_command
  --
  return html.post_process_html(cmd)
end

function post_process_pdf(cmd)
  -- move the pdf to a corresponding folder under root_dir (presumably ximera-downloads, with different path/name!)
  --
  -- use absolute paths when running in chdir-context during compilation ....
  local file = cmd.file
  local src_filename = cmd.output_file
  local absfolder = path.join(GLOB_root_dir, cmd.command_metadata.download_folder, file.relative_dir)
  local relfolder = path.join(               cmd.command_metadata.download_folder, file.relative_dir)
  local abstgt    = path.join(absfolder, file.basename ..".pdf")
  local reltgt    = path.join(relfolder, file.basename ..".pdf")
  -- require 'pl.pretty'.dump(src)
  if not path.exists(src_filename) then
    log:warningf("Output file %s does not exists (for %s)",src_filename, file.relative_path)
  else
    log:infof("Moving %s to %s", src_filename, reltgt)
    pldir.makepath(absfolder)
    plfile.copy(src_filename, abstgt)
  end

  if file.relative_path:match("_pdf.tex$" ) then
    log:infof("Convert _pdf.pdf file to svg for  %s",file.relative_path) 
    -- Mmm, osExecute should better not be in module 'frost'
    frost.osExecute("pdf2svg " .. file.absolute_path:gsub(".tex",".pdf") .. " " .. file.absolute_path:gsub(".tex",".svg"))
  end

  cmd.final_output_file = reltgt
  cmd.status_post_command = "OK"
  return cmd
end

--- run a complete compile-cycle on a given file
--- 
--- SIDE-EFFECT: adds output_files to the file argument !!!
--- 
--- @param file fileinfo file on which the command should be run
--- @param compilers [compiler] list of compilers
--- @param compile_sequence table sequence of keys from the compilers table to be executed
--- @return [compile_info] statuses information from the commands
local function get_commands_to_run(file, compilers, compile_sequence, only_check)
  only_check = only_check or false
  local compile_commands = {}

  -- Collect ALL needed compilations for this file
  -- NOTE: extension is a bad name, it's rather  'compiler'
  for _, extension in ipairs(compile_sequence) do
    log:tracef("Collecting %s compilation of %s (%s)", extension, file.relative_path, file.tex_documentclass)
    local command_metadata = compilers[extension]

    if not command_metadata then
      log:errorf("No compiler defined for %s (%s); SKIPPING",extension,file.relative_path)
      goto uptonextcompilation  -- nice: a goto-statement !!!
    end
    -- This could/should perhaps be handled higher up? Compilation of e.g. preamble.tex does not make sense ...
    if not file.tex_documentclass then
      log:infof("Skipping %s compilation of non-tex-document %s",extension, file.relative_path)
      goto uptonextcompilation 
    end
    if file.tex_documentclass ~= "ximera" and file.tex_documentclass ~= "xourse" and string.match(extension,"html")  then
      log:infof("Compiling a non-ximera %s file %s with 'xhtml' (and thus not ximera.cfg)", file.tex_documentclass,  file.relative_path)
      file.configfile = "xhtml"
    end

    if file.extension ~= "tex" then
      log:errorf("Can't compile non-tex file %s; SKIPPING, SHOULD PROBABLY NOT HAVE HAPPENED",file.relative_path)
      goto uptonextcompilation 
    end


    -- HACK: _pdf.tex and _beamer.tex files should by convention NOT generate HTML (as they typically would contain non-TeX4ht-compatible constructs)
    if extension:match("html$") and ( file.relative_path:match("_pdf.tex$") or file.relative_path:match("_beamer.tex$") ) then
      log:infof("Skipping HTML compilation of pdf-only file %s",file.relative_path) 

      -- create/update a dummy outputfile to mark this file 'uptodate'
      local filename = file.absolute_path:gsub(".tex$",".html")
      local file, err = io.open(filename, "r")
    
      if file then
          -- File exists, update modification time
          file:close()
          lfs.touch(filename)
      else
          -- File doesn't exist, create a new one
          file, err = io.open(filename, "w")
          if file then file:close()
          else         log:infof("Failed to fix dummy htmlfile %s: %s",filename,err)
          end
      end
      goto uptonextcompilation 
    end
  
    -- Construct the expected names of the generated output and logfiles
    local infix = ""    -- used for compilation-variations, eg 'handout' of 'make4ht'/'draft'
    if command_metadata.infix and command_metadata.infix ~= "" then
      infix = command_metadata.infix.."."
    end
    local output_file   = file.absolute_path:gsub("tex$", extension)       -- to be generated by compile
    local log_file      = file.absolute_path:gsub("tex$", infix.."log")    -- hopefully this is where the logs go

    -- sometimes compiler wants to check for the output file (like for sagetex.sage),
    if command_metadata.check_file and not path.exists(output_file) then
      log:debugf("Skipping compilation because of 'check_file', and file %s does not exist",output_file)
      goto uptonextcompilation  -- TODO: CHECK (for sagetex.sage ...)
    end
    
    if output_file.exists and not output_file.needs_compilation then
      log:debugf("Mmm, compiling file %s which was registered as not needing compilation.",output_file)
    end

      -- replace placeholders like @{filename} with the corresponding keys (from the metadata table, or config)
      local command = command_metadata.command
      command = command:gsub("@{(.-)}", file)
      command = command:gsub("@{(.-)}", { output_file = output_file })        -- used for sage ...
      command = command:gsub("@{(.-)}", config)

      log:debug("Adding command " .. command )

      local cmd = { 
          id=extension.."|"..file.relative_path, 
          file=file, 
          extension=extension, 
          command=command, 
          command_metadata=command_metadata, 
          output_file = output_file,
          log_file=log_file, 
          only_check=only_check, 
      }
      table.insert(compile_commands, cmd)

      log:tracef("ADDED %s for %s of %s", cmd.id, cmd.extention, file.relative_path)
      

    ::uptonextcompilation::
  end

  return compile_commands

end


local function do_command_handle(cmd)

  -- log:info("START do_command_handle")

  local file=cmd.file
  local extension=cmd.extension

  log:debugf("Handling return of %s for %s: returns %s (expected %d) after %.3f seconds", cmd.extension, file.relative_path, cmd.status_command or 42, cmd.command_metadata.status or 42, cmd.compilation_time or 42)

      if cmd.command_metadata.check_log then

        log:tracef("Checking logfile %s", cmd.log_file)
        local errors = parse_log_file(cmd.log_file)  -- gets errors the make4ht-way !
        cmd.errors = errors             -- keep them around
        
        -- Show nicely formatted errors 
        local err_context = ""
        local err_line = ""
        for i, err in ipairs(errors or {}) do

          -- Format errormessage a bit, and store it in err.constructed_errormessage
          err_context  = "at "..err.context
          err_line = ""
          if err.line then err_line = "[l." .. err.line .. "]" end
          
          -- remove useless context ...
          if err.context:match('See the LaTeX manual or LaTeX Companion for explanation') 
          or err.context:match('^ <-') then
            err_context = ""
          end
          
          err.constructed_errormessage =  string.format("%s %-30s %s", err_line,  err.error, err_context)

          if i<10 then
            log:errorf("%-20s:%s", cmd.log_file, err.constructed_errormessage)
          elseif i == 10 then
            log:warningf("... skipping further errorlog; %d errors found", #errors)
          end          
        end
      end

    if cmd.status_command ~= cmd.command_metadata.status then
      -- log:errorf("Compilation of %s for %s failed: returns %d (not %d) after %3f seconds", extension, file.relative_path, cmd.status_command, cmd.status_expected, compilation_time)
      log:errorf("Compilation of %s for %s failed: returns %d (not %d)", extension, file.relative_path, cmd.status_command, cmd.command_metadata.status)
      if path.exists(cmd.output_file) then
        -- prevent trailing non-correct files, as they prevent automatic re-compilation !
        log:infof("Moving output of failed compilation to %s", cmd.output_file..".failed")
        pl.file.move(cmd.output_file, cmd.output_file..".failed")
      end
      cmd.status = "COMMAND_FAILED"   -- adhoc errorstatus
      return cmd  
    end

    -- The 'output_file' might need to be post-processed into a 'final_output_file'
    --  ( eg html manipulation, or moving a pdf to a downloads folder)
    -- in case no postprocessing: 
    local final_output_file = cmd.output_file
    if cmd.command_metadata.post_command then
      local post_command = cmd.command_metadata.post_command
      log:debugf("Postprocessing %s: %s",cmd.id, post_command)
      -- call the post_command
      cmd = _G[post_command](cmd)     -- lua way of calling the function whose name is in 'post_command'
      
      -- The post_command might/should have created a new ('final') output file
      final_output_file = cmd.output_file_postprocessed
    end

    if final_output_file then
      log:debugf("Adding outputfile %s for %s ", final_output_file, file.relative_path)
      if not file.output_files_made then file.output_files_made = {} end
      file.output_files_made[final_output_file] = files.get_fileinfo(final_output_file, true)     -- never used?
    end
      
    cmd.status = "OK" 
    -- log:trace("DONE do_command_handle")

    -- -- Update 'needs_compilation' ... (BADBAD: should probably be done in a better way ...)
    -- files.update_output_files(file, output_formats)
    -- log:infof("Updated status of %s:%s uptodate", file.relative_path, file.needs_compilation and ' NOT' or '' )
    
    -- files.dump_fileinfo(file)     -- only for debugging
    
    return cmd
end

--- remove temporary files
---@param basefile fileinfo 
---@param extensions table    list of extensions of files to be removed
---@return  number nfiles     number of files removed
local function clean(basefile, extensions, infixes, only_check)
  only_check = only_check or false
  local nfiles = 0
  local basename = path.splitext(basefile.absolute_path)
  log:tracef("%s the temp files for %s (%s)", (only_check and "Would remove" or "Removing"), basename, basefile.absolute_path)

  for _, infix in ipairs(infixes) do
    for _, ext in ipairs(extensions) do
      local filename = basename .. infix .. "." .. ext
      if path.exists(filename) then
        log:debugf("%s %-14s file %s", (only_check and "Would remove" or "Removing") ,infix.."."..ext, filename)
        if not only_check then os.remove(filename); nfiles = nfiles + 1 end
      -- else
      --   log:tracef("No file %s present", filename)
      end
    end
  end
  return nfiles
end

M.get_commands_to_run = get_commands_to_run
M.do_command_handle   = do_command_handle
M.clean        = clean

return M
