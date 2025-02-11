-- post-process HTML files created by TeX4ht to a form suitable for Ximera
local M = {}
local log = logging.new("html")
local domobject = require "luaxml-domobject"
local pl = require "penlight"
local path = require "pl.path"

local url = require("socket.url")
-- local url = require "lualibs-url"

function getRelativePath(base, targ)
  -- Normalize paths by ensuring both are absolute
  local function normalize(path)
      -- Remove trailing slashes for consistency
      return path:gsub("/$", ""):gsub("\\$", "")
  end

  base = normalize(base)
  targ = normalize(targ)

  -- Split paths into components
  local baseParts = {}
  local targParts = {}

  for part in base:gmatch("[^/\\]+") do
      table.insert(baseParts, part)
  end

  for part in targ:gmatch("[^/\\]+") do
      table.insert(targParts, part)
  end

  -- Find the common prefix
  local i = 1
  while i <= #baseParts and i <= #targParts and baseParts[i] == targParts[i] do
      i = i + 1
  end

  -- Calculate the number of steps to go up from base
  local upSteps = #baseParts - i + 1
  local relativeParts = {}

  -- Add `..` for each step up
  for _ = 1, upSteps do
      table.insert(relativeParts, "..")
  end

  -- Add the remaining parts of the target path
  for j = i, #targParts do
      table.insert(relativeParts, targParts[j])
  end

  -- Join the relative parts into a path
  return table.concat(relativeParts, "/")
end


local html_cache = {}

--- load DOM from a HTML file
---@param filename string
---@return DOM_Object|nil dom
---@return string? error_message
local function load_html(filename)
  -- cache DOM objects
  if false and html_cache[filename] then    -- does not work with RECOMPILE ...
    log:trace("returning cached dom ")
    -- require 'pl.pretty'.dump(domobject.html_parse(content))
    return html_cache[filename]
  else
    log:debug("Loading and parsing html for "..filename)
    local f = io.open(filename, "r")
    if not f then return nil, "Cannot open HTML file: " .. (filename or "") end
    -- log:debug("Opened html for "..filename)
    local content = f:read("*a")
    f:close()
    -- log:debug("Dumping html for "..filename..": "..content)
    html_cache[filename] = domobject.html_parse(content)
    log:trace("returning non-cached dom ")
    return domobject.html_parse(content)
  end
end

--- detect if the HTML file is xourse
---@param dom DOM_Object
---@return boolean
local function is_xourse(dom, filename)
  local metas = dom:query_selector("meta[name='description']")
  if #metas == 0 then
    log:debug("No meta[description] tags in " .. filename .. " (and thus not a xourse)")
  end
  for _, meta in ipairs(metas) do
    if meta:get_attribute("content") == "xourse" then
      log:debug("File "..filename.." is a xourse")
      return true
    else
      log:debug("File "..filename.." has not-a-xourse description tag  "..(meta.get_attribute("content") or ""))
    end
  end
  -- log:debug("File "..filename.." is not a xourse ")
  return false
end

local function is_element_empty(element)
  -- detect if element is empty or contains only blank spaces
  local children = element:get_children()
  if #children > 1 then return false 
  elseif #children == 1 then
    if children[1]:is_text() then
      if children[1]._text:match("^%s*$") then
        return true
      end
      return false
    end
    return false
  end
  return true
  
end

--- Remove empty paragraphs
---@param dom DOM_Object
local function remove_empty_paragraphs(dom)
  for _, par in ipairs(dom:query_selector("p")) do
    if is_element_empty(par) then
      log:trace("Removing empty par")
      par:remove_node()
    end
  end
end

local function read_title_and_abstract(activity_dom)
  local title, abstract
  local title_el = activity_dom:query_selector("title")[1]
  if title_el then title = title_el:get_text() end
  log:trace("Read title ", title)
  local abstract_el = activity_dom:query_selector("div.abstract")[1]
  if abstract_el then
    abstract = abstract_el:get_text()
    -- log:trace("Read abstract ", abstract)
  end
  return title, abstract
end

local function get_labels(activity_dom)
  local labels = {}

  if not activity_dom then
    log:warning("Passed nil to get_labels...? No labels returned.")
    return {}
  end
  for i, anchor in ipairs(activity_dom:query_selector("a.ximera-label")) do
    -- require 'pl.pretty'.dump(anchor)
    local label = anchor:get_attribute("id")
    labels[label] = (labels[label] or 0) + 1
    log:tracef("Found label %s", label )
    if labels[label] > 1 then
      log:warning("Duplicate label ",label)
    end 
  end
  return labels
end

--- Transform Xourse files
---@param dom DOM_Object
---@param file fileinfo
---@return DOM_Object
local function transform_xourse(dom, file)
  for _, activity in ipairs(dom:query_selector("a.activity")) do
    local href = activity:get_attribute("href")
    log:trace("Updating srv/title/abstract for activity", href)
    if not href then
      log:warningf("Bizar, an activity without href in %s? Nothing to process...", file.relative_path)
      goto next_activity
    end
        -- some activity links don't have links to HTML files
        -- remove the optional '.tex'
    local newhref = href
    if path.extension(href) == ".tex" then newhref, _ = path.splitext(href) end
    -- add .html if no extension (anymore)
    if path.extension(newhref) == "" then newhref = newhref .. ".html" end
    
    local relhref = file.relative_dir.."/"..newhref
    relhref = relhref:gsub("^/","")   -- remove leading /
   if relhref:gsub(".html$","") ~= href then 
      -- The  .html extension breaks the previous/next buttons in ximeraServer 
      log:debug("Resetting href to "..relhref:gsub(".html$","") .. "( from "..href..")") 
      activity:set_attribute("href",relhref:gsub(".html$",""))
    end
    
    -- the absolute path to .html of the linked activity
    local abshtmlpath = path.join(file.absolute_dir,  newhref)
    local relhtmlpath = path.join(file.relative_dir,  newhref)
    local title, abstract

    if not path.exists(abshtmlpath) then 
      log:errorf("File %s: html file for activity %s does not (yet?) exist; SKIPPING add/update title and abstract", file.relative_path, abshtmlpath)
      goto next_activity
    end
  
    -- add the title and abstract of the activity to the xourse file ...
    -- TODO: these could already be in the fileinfo of abshtmlpath, which would prevent reading/parsing the .html here (again...)
    
    -- add titles and abstracts from linked activity HTML
    local html_fileinfo = GLOB_files[relhtmlpath]
    if false and html_fileinfo then   -- TODO : DOES NOT WORK (file not (yet?) there
      log:debug("Found cached fileinfo for "..abshtmlpath)
      title    = html_fileinfo.title
      abstract = html_fileinfo.abstract
  
    else
      log:debugf("File %s: no fileinfo yet for activity %-30s; Getting it now.",  file.relative_path, relhtmlpath)

      local activity_dom, msg = load_html(abshtmlpath)
      if not activity_dom then
        log:error(msg)
        goto next_activity
      end
      title, abstract = read_title_and_abstract(activity_dom)
    end


    if title and title ~= "" then
      local h2 = activity:create_element("h2")
      local h2_text = h2:create_text_node(title )
      log:trace("Adding title for "..href..": "..title) 
      h2:add_child_node(h2_text)
      activity:add_child_node(h2,1)
    else 
      log:debug("No title found for "..href)
    end
    -- the problem with abstract is that Ximera redefines \maketitle in TeX4ht to produce nothing, 
    -- abstract in Ximera is part of \maketitle, so abstracts are missing in the generated HTML
    if abstract then
      --require 'pl.pretty'.dump(abstract)
      local h3 = activity:create_element("h3")
      local h3_text = h3:create_text_node(abstract)
      log:trace("Adding abstract (h3) for "..href..": "..abstract:gsub("\n","")) 
      h3:add_child_node(h3_text)
      activity:add_child_node(h3,1)
    end
    ::next_activity::
  end

  return dom
end

--- return sha256 digest of a file
---@param filename string
---@return string|nil hash
---@return unknown? error
local function hash_file(filename)
  -- Xake used sha1, but we don't have it in Texlua. On the other hand, sha256 is built-in
  local f = io.open(filename, "r")
  if not f then return nil, "Cannot open TeX dependency for hashing: " .. (filename or "") end
  local content = f:read("*a")
  f:close()
  -- the digest return binary code, we need to convert it to hexa code
  local bincode = sha2.digest256(content)
  local hexs = {}
  for char in bincode:gmatch(".") do
    hexs[#hexs+1] = string.format("%X", string.byte(char))
  end
  return table.concat(hexs)
end



--- Add fileinfo with TeX file dependencies to the HTML DOM
---@param dom DOM_Object
---@param file fileinfo
---@return DOM_Object
local function add_dependencies(dom, file)
  -- we will add also TeX file of the current HTML file
  local t = {file}
  -- copy dependencies, as we have an extra entry of the current file
  for _, x in ipairs(file.dependecies) do t[#t+1] = x end
  local head = dom:query_selector("head")[1]
  if not head then log:error("Cannot find head element " .. file.absolute_path:gsub("tex$", "html")) end
  for _, dependency in ipairs(file.dependecies) do
    log:debug("dependency", dependency.relative_path, dependency.filename, dependency.basename)
    local hash, msg = hash_file(dependency.absolute_path)
    if not hash then
      log:warning(msg)
    else
      local content = hash .. " " .. dependency.filename
      local meta = head:create_element("meta", {name = "dependency", content = content})
      local newline = head:create_text_node("\n")
      head:add_child_node(meta)
      head:add_child_node(newline)
    end

  end
  return dom
end



--- get file extension 
--- @param relative_path string file path
--- @return string extension
local function get_extension(relative_path)
  return relative_path:match("%.([^%.]+)$")
end



--- Get all files 'associated' with a given file (i.e. images)
---@param dom DOM_Object
---@param file fileinfo
---@return ret , table
local function get_associated_files(dom, file)
  log:tracef("get_associated_files for %s", file.filename)
  -- pl.pretty.dump(file)

  if not dom then
    log:tracef("Passed nil to get_associated_files for %s...? No files returned.", file.filename or "<NO__FILE>")
    return 1, "Passed nil to get_associated_files for " ..  file.filename or "<NO__FILE>"
  end

  local ass_files = {}
  local ass_errors = {}
  local isXimeraFile = dom:query_selector("meta[name='ximera']")[1]
  if not isXimeraFile then 
      log:warning(file.filename.." is not a ximera file (no meta[name='ximera' tag])")
  end

  -- Add images 
  for _, img_el in ipairs(dom:query_selector("img") ) do
    local src = img_el:get_attribute("src")
    -- log:tracef("Found img %s in %s (%s)", src, file.relative_dir, file.relative_path )
    -- src = (file.relative_dir or ".").."/"..src
    src = path.join(file.relative_dir, src)
    log:debugf("Found img %s in %s", src, file.absolute_path )

    if not path.exists(path.join(GLOB_root_dir, src)) then    -- BADBAD: this might got processed after chdir in compile ....!
      log:errorf("Image file %s does not exist (%s)", src, path.join(GLOB_root_dir, src))
      ass_errors[#ass_errors+1] = src .. " does not exist"
      goto next_image

    end
    if path.getsize(path.join(GLOB_root_dir, src)) == 0 then
      log:errorf("Image file %s has size zero", path.join(GLOB_root_dir, src))
      ass_errors[#ass_errors+1] = src .. " has size zero"
      goto next_image
    end
    
    ass_files[#ass_files+1] = src
    
    -- local u = url.parse(src)
    -- if false and get_extension(u.path) == "svg"
    -- then
    --   local png  = u.path:gsub(".svg$", ".png")
    --   log:debug("also adding  "..png)
    --   ass_files[#ass_files+1] = png
    -- end
  
    ::next_image::
  end

  if #ass_errors >  0 then
    log:warningf("Got %d errors for associateds file (images) of %s", #ass_errors, file.relative_path)
    table.insert(ass_errors,1,"")    -- HACK to get also the first error on a newline ...
    return 1, "Error(s):".. table.concat(ass_errors, "\n ERROR  ->")
  else 
    log:debugf("Got %d associated files (images) for %s", #ass_files, file.relative_path)
    return nil, ass_files
  end
end



--- Update 'fileinfo' of html file 
---@param fileinfo fileinfo
---@param dom? DOM_Object
---@return ret, msg
local function update_html_fileinfo(fileinfo, dom)
  log:tracef("update_html_fileinfo for %s", fileinfo.filename)

  local html_file = fileinfo.relative_path

  local msg

  -- if dom not passed, get it ...
  if not dom then
    dom, msg = load_html(fileinfo.absolute_path)
    if not dom then 
        log:tracef("No dom for %s (%s). SKIPPING", html_file, msg)
        return 1, "No dom loaded for " ..  html_file .. ": " .. msg 
    end
  end

-- collect info  (for frosting...)
  fileinfo.labels = get_labels(dom)
  
  -- check if e.g. images can be found...
  local ret, associated_files = get_associated_files(dom, fileinfo)
  
  if ret then
    log:tracef("ERROR: Could not get associated files (images) for %s: %s", html_file, associated_files )
    return ret, associated_files
  end
  
  fileinfo.associated_files = associated_files

  local title, abstract = read_title_and_abstract(dom)
  fileinfo.title = title or ""
  fileinfo.abstract = abstract or ""

  return nil,"OK"
end

--- Save DOM to file
---@param dom DOM_Object
---@param filename string
--- returns nil on success, errormessage on failure
local function save_html(dom, filename)
  local f, err = io.open(filename, "w")
  if not f then
    return "Cannot save updated HTML to " .. (filename or "" .. ": ".. err) 
  end
  f:write(dom:serialize())
  f:close()
  return nil
end


--- Post-process HTML files
---@param cmd command
---@return string? name of post_processed file (could be same name/file is src, or not...)
---@return string? msg  (if error: name in nil)
-- local function post_process_html(src, file, cmd_meta)
local function post_process_html(cmd)
  local file = cmd.file
  local src= cmd.output_file
  local extension = cmd.command_metadata.extension

  log:tracef("post_process_html %s (%s)",src, file.relative_path)
      
  local dom, msg = load_html(src)
  if not dom then 
    cmd.status_post_command = "NO_HTML_DOM_FOUND"
    cmd.error = msg
    return cmd
  end
  

  local ret, msg =  update_html_fileinfo(file, dom)     -- not really 'post-processing', but implicit checking-of-generated-images
  -- BADBAD: inconsistent error-conventions .... !
  if ret then 
    cmd.status_post_command = ret
    cmd.error = msg
    return cmd
  end

  if file.has_title and ( not file.title or file.title == "" ) then
    if not cmd.this_is_a_retry then
      log:warningf("No title found in %s; recompiling once more might solve this ...", file.relative_path)
      cmd.status_post_command = "RETRY_COMPILATION"
    else 
      log:warningf("No title found in %s; recompiling did not work to solve this ...", file.relative_path)
      cmd.status_post_command = "NO_TITLE_FOUND"
      cmd.error = msg
    end
    return cmd
  end

  remove_empty_paragraphs(dom)
  --add_dependencies(dom, file)    -- IS THIS NEEDED???

  log:debug("Remove blanks in '\\begin {' if present")
  for _, mjax in ipairs(dom:query_selector(".mathjax-inline, .mathjax-block")) do
    local mtext = mjax:get_text()
    mtext = mtext:gsub("\\begin%s*{", "\\begin{")
    mtext = mtext:gsub("\\end%s*{", "\\end{")
    if mtext ~= mjax:get_text() then
      log:tracef("Set mtext to %30.30s.", mtext:gsub("[\n \t]+"," "))
      mjax.textContent = mtext
    end
  end

  log:trace("Process .xmjax file if present")
  local jax_file = src:gsub(".html$", ".xmjax")
  if not path.exists(jax_file) then
    log:warning("Strange: no JAX file with extra LaTeX commands for MathJAX")
    jax_file = nil
  end

  if jax_file then

    local preambles = dom:query_selector("div.preamble")
      
    if #preambles == 0 then
      -- Should not happen ...
      log:error("No div.preamble in html : please add one") 
    end

    local preamble = preambles[1]
    local scrpt = preamble:create_element("script")
    scrpt:set_attribute("type", "math/tex")
    
    
    local f = io.open(jax_file, "r")
    local cmds = f:read("*a")
    f:close()

    -- Function to keep only lines starting with \new
    local function filter_newcommands(text)
      local result = {}
      for line in text:gmatch("[^\r\n]+") do
        if line:match("^\\newcommand {") or line:match("^\\DeclareMathOperator") or line:match("^\\newenvironment") then
            table.insert(result, line)
        end
      end
      return table.concat(result, "\n")
    end

    local filtered_cmds = cmds
    filtered_cmds= filtered_cmds:gsub("[^\n]*[:*@].-\n", "")      -- remove all 'exotic' characters; _ must be kept...
    filtered_cmds= filtered_cmds:gsub("[^\n]\\_.-\n", "")          -- remove \_  (Mathax error)
    filtered_cmds= filtered_cmds:gsub("[^\n]\\TU.-\n", "")          -- remove \_  (Mathax error)
    filtered_cmds= filter_newcommands(filtered_cmds)               -- only keep newcommands and declaremathoperator
    filtered_cmds= filtered_cmds:gsub("##(%d)", "#%1")             -- replace ##1 with #1
    
    local _, n_cmds = cmds:gsub("\n","")
    local _, n_filtered_cmds = filtered_cmds:gsub("\n","")

    log:debugf("Adding %d newcommands (from %s,  %d filtered)",n_filtered_cmds, jax_file,   n_cmds - n_filtered_cmds)

    local scrpt_text = scrpt:create_text_node(filtered_cmds)
    scrpt:add_child_node(scrpt_text)
    preamble:add_child_node(scrpt)

  end

  
  if is_xourse(dom, src) then   -- not needed anymore, was already determened from .tex source ???
  -- if file.tex_documentclass == "xourse" then
    transform_xourse(dom, file)    

    
    log:debug("Checking if a 'part' is present") 
    local part = dom:query_selector(".card.part")

    if #part == 0 then
      log:info("No parts found, adding one, as this is needed in (some versions of) the ximeraServer") 

      local body = dom:query_selector("body")[1]
      local first_activity = dom:query_selector(".card.activity")[1]
      if first_activity then
        log:debug("Adding default card of type 'part' (HACK: needed by current preview server)") 
        local h1 = body:create_element("h1")
        local h1_text = h1:create_text_node("Main Part")
        h1:add_child_node(h1_text)
        h1:set_attribute("class", "card part")
        body:add_child_node(h1,6)    -- the 3 is a guess  
      else
        log:warning("BIZAR: No 'activity' card found to add a dummy 'part' to ??? ") 
      end
    end
  --<h1 class='card part' id='part1'>The First Topic of This Course</h1>
  end

  -- save with absolute path to be independent of chdir's in compilation-step ...
  local abstgt = path.join(file.absolute_dir, file.basename ..".".. extension)
  local reltgt = path.join(file.relative_dir, file.basename ..".".. extension)

  log:infof("Adapted html being saved as %s (%s)", reltgt, abstgt)
  
  local msg = save_html(dom, abstgt)
  if err then  
    cmd.status_post_command = "NO_COULD_NOT_SAVE"
    cmd.error = msg
    return cmd
  end   -- return failure

  cmd.output_file_final = reltgt
  cmd.status_post_command = "OK"
  return cmd    -- return success: relative path of post_processed file
end

M.post_process_html = post_process_html
M.update_html_fileinfo = update_html_fileinfo

return M
