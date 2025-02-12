local M = {}
local lfs = require "lfs"
local error_logparser = require("make4ht-errorlogparser")
local pl = require "penlight"
local path = pl.path
local pldir = pl.dir
local plfile = pl.file

local tablex = require("pl.tablex")

local html = require "luaxake-transform-html"
local files = require "luaxake-files"      -- for get_fileinfo
local frost = require "luaxake-frost"      -- for osExecute
local socket = require "socket"
local ffi = require "ffi"

local log = logging.new("bake")


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


-- POSIX system calls we need for non-blocking popen
-- Note this makes us POSIX dependent, but we could add Windows system calls to support Windows if we ever needed
ffi.cdef([[
  void* popen(const char* cmd, const char* mode);
  int pclose(void* stream);
  int fileno(void* stream);
  int fcntl(int fd, int cmd, int arg);
  int *__errno_location ();
  ssize_t read(int fd, void* buf, size_t count);
]])
  
-- I think these are technically system dependent
local F_SETFL = 4
local O_NONBLOCK = 2048
local EAGAIN = 11

function do_command_start(cmd)
  
  local file=cmd.file
  local command=cmd.command
  local folder=file.absolute_dir
  
  log:tracef("Starting process in %s with command %s " , folder, command)

  local process = {}
  process.cmd = cmd
  process.file_name = file.absolute_path

  process.start_time =socket.gettime()

  if cmd.only_check then
    log:info("Running in check-modus: SKIPPING " .. command )
    command = "echo SKIPPED " .. command
  end 

  log:statusf("Command %3d started for %s", cmd.job_nr, cmd.id )


  -- Start process with "command"
  process.handle = ffi.C.popen("cd "..folder.."; ".. command, "r")
  if process.handle == nil then
    log:warningf("ffi.popen returns %s", popen)

    local err_code = _errno[0]
    return tonumber(err_code), "Error trying to popen command: " .. tostring(command) .. "Error code: " .. tostring(err_code)
  end

  -- Get file descriptor of pipe
  process.fd = ffi.C.fileno(process.handle)
  log:tracef("ffi.fileno returns %s", process.fd)
  
  if process.fd == -1 then
    local err_code = _errno[0]
    local err_msg = "Failed to get file descriptor for command: " .. tostring(command) .. ". Error code: " .. tostring(err_code)

    local status_code = ffi.C.plcose(process.handle)

    if status_code -1 then
      err_code = _errno[0]
      err_msg = err_msg .. ". Failed to pclose process. Error code: " .. tostring(err_code)
    end

    return tonumber(err_code), err_msg
  end

   -- Set non-blocking mode for pipe
  local status_code = ffi.C.fcntl(process.fd, F_SETFL, O_NONBLOCK)
  if status_code ~= 0 then
    err_code = _errno(0)
    log:info("failed fcntl. status_code: " .. tostring(status_code) .. ". error: " .. tostring(_errno[0]))
    return tonumber(err_code), "Failed to set non-blocking reads for pipe to command: " .. tostring(command) .. ". Error code: " .. tostring(err_code)
  end

  return 0, process
end



function bake(to_be_compiled, n_jobs)
  local commands_to_run = {}
  local commands_that_ran = {}


  log:tracef("Collecting all needed compile commands for %s to be compiled files", #to_be_compiled)
  for i, file in ipairs(to_be_compiled) do
    
    local extra_run_commands = get_commands_to_run(file,  config.compilers, config.compile_sequence, config.check)
    tablex.insertvalues(commands_to_run, extra_run_commands)

    log:infof("Added %d compile commands for file %3d/%d: %s", #extra_run_commands, i, #to_be_compiled, file.relative_path)
  end

  local job_total = #commands_to_run
  log:statusf("There are %d commands to run for %d files", job_total, #to_be_compiled)
    

  local _errno = ffi.C.__errno_location() -- Get pointer to errno location
  local buffer_size = 2025
  local read_buffer = ffi.new("char[?]", buffer_size)

  local current_processes = {}
  local current_workers = 1
  local job_nr = 1

  local total_start_time =  socket.gettime()

  log:tracef("Starting up to %d processes", n_jobs)
  while current_workers <= n_jobs do
      -- Take first command (and remove it from the list of commands_to_run)
      local cmd = table.remove(commands_to_run,1)
      
      if not cmd then
        log:tracef("No more commands to compile, not all %d processes were needed", n_jobs)
        break
      end
      
      -- Give this command a 'job_nr' for logging/follow-up
      cmd.job_nr = job_nr
      job_nr = job_nr + 1
      
      log:debugf("Starting process %d for command %s", current_workers, cmd.command)
      local ret, process = do_command_start(cmd)

      if ret > 0 then
        return ret,process
      else 
        log:tracef("Added process %d to current_processes",current_workers)
        table.insert(current_processes, process)
        current_workers = current_workers + 1
      end
  end
  -- (at most) n_jobs processes have been started; now start collecting results, and restart processes as long as needed

  log:tracef("Starting main processing loop (for %d processes)", #current_processes)
  while #current_processes > 0 do
    local j = 1
    while  j <= #current_processes do
        local process = current_processes[j]
        log:tracef("Checking process %d of %s (fd=%d)", j , #current_processes, process.fd)
        
        -- log:tracef("Read up to 2024 bytes from fd %d",process.fd)
        local bytes_read = ffi.C.read(process.fd, read_buffer, 2024) -- Read 2024 bytes at a time (We currently don't do anything with what we read)
        -- log:tracef("ffi.read returns %s (%s)", bytes_read, read_buffer)

        if (bytes_read == -1) and (_errno[0] ~= EAGAIN) then -- There was some unexpected error
          log:errorf("Reading 2024 bytes from fd %d returns %s",process.fd, _errno[0])
          -- TODO: We might be able to handle some of these errors instead of just failing
          return tonumber(_errno[0]), "Failed to read pipe for compilation process for file: " .. tostring(process.file_name) .. ". Error code: " .. tostring(_errno[0])

        elseif bytes_read == -1 then
          j = j+1     -- TODO: check ...!
        elseif bytes_read > 0 then
          local read_string = string.sub(string.gsub(ffi.string(read_buffer),"[\r\n]",""), 1, math.min(bytes_read,30)+1)
          log:tracef("Read from fd %d returns %s: %s...",process.fd, bytes_read, read_string)
          j = j+1
        else  --  bytes_read == 0 then -- End of file
          log:tracef("Zero bytes read from fd %d",process.fd)

          local ret_code = ffi.C.pclose(process.handle)


          if ret_code == -1 then -- TODO: Do we have to do anything more in this case?
            log:error("Failed to get return code for compilation process for file: " .. tostring(process.file_name))
          elseif ret_code == 0 then
            log:tracef("Got returncode %s for file %s", ret_code, process.file_name)
          else
            log:warningf("Got returncode %s for file %s", ret_code, process.file_name)
            -- ret_code = ret_code / 256 -- Discard last 8 bits
          end
          
          process.cmd.status_command = ret_code

          -- TODO: add error handling based off of this return code
          log:trace("Return code for compilation process for file: " .. tostring(process.file_name) .. " is ret_code: " .. tostring(ret_code))

          local compilation_time = socket.gettime() - process.start_time

          process.cmd.compilation_time = compilation_time


          local cmd = do_command_handle(process.cmd)

          log:statusf("Command %3d/%d returns %s (process %d, %.1f seconds) for %s of %s", process.cmd.job_nr, job_total, process.cmd.status, j, process.cmd.compilation_time, process.cmd.extension, process.cmd.file.relative_path)
    
          table.insert(commands_that_ran, cmd)
          
          -- Now start the next command_to_run 
          local next_cmd
          if cmd.status_post_command == "RETRY_COMPILATION" then
            next_cmd = cmd -- RETRY !!
            next_cmd.this_is_a_retry = true
            job_nr = job_nr - 1     -- otherwise you get job 25/13 ... !
            log:infof("Restarting %s (as command %d)", next_cmd.id, job_nr)
          else
            -- Start the next compile, if there are any left
            log:tracef("Selecting next command to run")
            next_cmd = table.remove(commands_to_run,1)

            -- -- TODO : check if dependencies are successfully compiled 
            -- -- (unless you don't want to ...)
            -- if not config.nodependencies then
            --   for fname, ffile in pairs(next_cmd.file.depends_on_files) do
            --     if ffile.needs_compilation then
            --       log:errorf("SKIPPING %s: dependent file %s not (yet) compiled.", next_cmd.file.relative_path, fname)
            --       goto uptonextcompilation 
            --     end
            --   end
            -- end
          end

          if next_cmd then
            log:debugf("Starting worker %d for %s", j, next_cmd.command)

            next_cmd.job_nr = job_nr
            job_nr = job_nr + 1
            local ret, process = do_command_start(next_cmd)
            
            if ret > 0 then
              log:errorf("Problem starting current_processes %d for %s: %s", j, next_cmd.id, process)
              return ret,process
            else 
              log:debugf("Updating current_processes %d for %s", j, next_cmd.id)
              current_processes[j] = process
            end
      
            
            j = j+1
          else
            log:debugf("No more work, removing worker %d", j)
            table.remove(current_processes, j)   --  THIS SHIFTS THE REMAINING ELEMENTS, so no increase of j !!!                
          end
        end 
    end
    local sleep_time = 0.25
    log:tracef("sleep %f", sleep_time)
    socket.sleep(sleep_time)
  end


    -- if config.noclean then
    --   log:debugf("Skipping cleaning temp files")
    -- else
    --   compile.clean(file, config.clean_extensions,config.clean_infixes)
    -- end
  local total_end_time =  socket.gettime()

  log:statusf("Finished compiling %d files in %.1f seconds", #to_be_compiled, total_end_time - total_start_time)


  -- collect and print all errors 
  local failed_commands = {}
  for _, cmd in ipairs(commands_that_ran) do 
      log:trace("File "..(cmd.output_file or "UNKNOWN??") .." got status " .. (cmd.status or 'NIL??') )
      
      if cmd.status ~= "OK"  then 
        failed_commands[cmd.id] = #(cmd.errors)
        log:debugf("Found %d errors: %s", #(cmd.errors), cmd.errors)

          for _, err in ipairs(cmd.errors or {}) do
            -- log:errorf("[%10s] %s:%s %s [%s]", compile_info.compiler, compile_info.source_file, err.line, err.context,err.error)
            log:errorf("[%-10s] %s:%s", cmd.extension, cmd.file.relative_path, err.constructed_errormessage)

          end
        if cmd.post_processing_error then
            log:errorf("[%-10s] %s: %s", "post_command", cmd.file.relative_path, cmd.post_processing_error)
            local _, n_errors = cmd.post_processing_error:gsub("\n", "")   -- HACK: number of lines equals number of errors ...
            failed_commands[cmd.id] = ( failed_commands[cmd.id] or 0 ) + n_errors + 1
        end
      end 
  end
  --
  -- all compilations done; process/summarize errors
  --
  if tablex.size(failed_commands) == 0 then
    -- log:statusf("Baked %d files, no errors found", #to_be_compiled)
    return 0,  string.format("Baked %d files, no errors found", #to_be_compiled)
  else
    log:warningf("Baked %d files, but %d compilation%s failed", #to_be_compiled, tablex.size(failed_commands), tablex.size(failed_commands) == 1 and "" or "s")

    for filename, errs in pairs(failed_commands) do
          log:debugf("Found %2d errors in %s", errs, filename)
    end
    -- log:statusf("Baking resulted in %d errors", tablex.size(failed_files) )
    return 1, string.format("Baking resulted in %d errors", tablex.size(failed_commands) )
  end
end

M.get_commands_to_run = get_commands_to_run
M.do_command_handle   = do_command_handle
M.bake         = bake
M.clean        = clean

return M
