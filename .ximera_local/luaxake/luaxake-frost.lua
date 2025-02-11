local M = {}
local pl = require "penlight"
local path = require "pl.path"
local html = require "luaxake-transform-html"
local files = require "luaxake-files"
local log = logging.new("frost")

local json = require("dkjson")

--- save Ximera metadata.json file  (with labels/xourses/...)
--- @param xmmetadata table ximera metadata table
--- @return boolean success 
local function save_as_json(xmmetadata)
    local file = io.open("metadata.json", "w")
  
    if file then
        local contents = json.encode(xmmetadata)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
  end
  
  

local function osExecute(cmd, no_warnings)
    log:debug("Exec: "..cmd)
    local fileHandle = assert(io.popen(cmd .. " 2>&1", 'r'))
    local commandOutput = assert(fileHandle:read('*a'))
    local returnCode = fileHandle:close() and 0 or 1
    commandOutput = string.gsub(commandOutput, "\n$", "")
    if returnCode > 0 and not no_warnings then
        log:warningf("Command %s returns %d: %s", cmd, returnCode, commandOutput)
    end
    log:trace("returns "..returnCode..": "..commandOutput..".")
    return returnCode, commandOutput
end

local function get_output_files(file, extension)
    local result = {}
    for fname, entry in pairs(file.output_files_needed or {}) do
        log:tracef("Getting  %-14s entry: %s ", file.extension, entry.absolute_path)

        if entry.extension == extension then --and entry.info.type == targetType then

            if extension == "make4ht.html" then    -- 20250121: does never occur ???
                local file = files.get_fileinfo(entry.relative_dir .."/" .. entry.basenameshort..".html")
                -- require 'pl.pretty'.dump(entry)
                -- require 'pl.pretty'.dump(file)
                table.insert(result, file)
                log:debug(string.format("Hacking  %-14s outputfile: %s ", file.extension, file.absolute_path))
            elseif extension == "draft.html" then
                local file = files.get_fileinfo(entry.relative_dir .. "/" .. entry.basenameshort..".html")
                -- require 'pl.pretty'.dump(entry)
                -- require 'pl.pretty'.dump(file)
                table.insert(result, file)
                log:debug(string.format("Hacking  %-14s outputfile: %s ", file.extension, file.absolute_path))
            else
                table.insert(result, entry)
                log:debug(string.format("Adding   %-14s outputfile: %s ", entry.extension, entry.absolute_path))
            end
        else
            log:tracef("Skipping %-14s outputfile: %s ", entry.extension, entry.absolute_path)
        end
    end
    return result
end

local function get_git_uncommitted_files()
    --  local ret, out = osExecute("git ls-files --modified --other  --exclude-standard")
     local ret, out = osExecute("git status --porcelain")
    if ret > 0 then
        log:warningf("Could not get git info: %s",out)
        out = "GIT ERROR"
    end
    local utils = require "pl.utils"
    return utils.split(out,"\n")
end


--- Frosting: create a 'publications' commit-and-tag
---@param file metadata    -- presumably only root-folder really makes sense for 'frosting'
---@return boolean status
---@return string? msg
local function frost(tex_files, to_be_compiled_files)
    log:debug("frost")

    local uncommitted_files = get_git_uncommitted_files()

    if #uncommitted_files > 0 then
        log:warningf("There are %d uncommitted files; should serve only to localhost", #uncommitted_files)
    end
    
    if #to_be_compiled_files > 0 then
        log:warningf("There are %d file to be compiled; should serve only to localhost", #to_be_compiled_files)
    end

    local needing_publication = {}
    local all_labels = {}
    local tex_xourses = {}
    for i, tex_file in ipairs(tex_files) do
        log:debugf("Getting output for %s (%s)", tex_file.absolute_path, tex_file.relative_path)
        -- add the .tex file itself (might not always be needed/wanted... ? It typically shows all solutions ...)
        needing_publication[#needing_publication + 1] = tex_file.relative_path
        
        -- note: .pdf's are added through ximera-downloads for now ... !

        -- add a .css if present
        local css_file = tex_file.relative_path:gsub(".tex$",".css")
        if path.exists(css_file) then
            log:debugf("Added file-specific css file %s", css_file)
            needing_publication[#needing_publication + 1] = css_file
        end

        -- add the .html
        local html_file 
        if  tex_file.relative_path:match("_pdf.tex") or tex_file.relative_path:match("_beamer.tex")  then 
            log:tracef("No html output for _pdf or _beamer files: skipping %s", tex_file.relative_path)
        else
          if not tex_file.output_files_needed then
                log:debugf("No output_files_needed for %s, and thus no HTML",tex_file.relative_path)
          else
            html_file = tex_file.output_files_needed.html
        
            log:debugf("Processing %s", html_file.relative_path)
            
            needing_publication[#needing_publication + 1] = html_file.relative_path
            
            -- local html_name = html_file.absolute_path
            if not html_file.associated_files then
                log:debugf("Collecting extra fileinfo for  %s", html_file.relative_path)
                local ret, msg =  html.update_html_fileinfo(html_file)     -- get labels etc
                if ret then 
                    log:errorf("FAILED to get associated files etc. for %s", html_file.relative_path)
                    return ret, msg 
                end
            end
            -- now we have added labels, associated_files, title and abstract in html_file

            -- merge all labels in a big table, to be added to metadata.json
            for k,v in pairs(html_file.labels) do 
                if all_labels[k] then
                    log:warningf("Label %s already used in %s; ignoring for %s",k, all_labels[k], html_file.relative_path)
                else
                    all_labels[k] = html_file.relative_path
                    log:tracef("Label %s added for %s",k,html_file.relative_path)
                end
            end

            -- add all associated_files (images!) to needing_publication
            table.move(html_file.associated_files, 1, #(html_file.associated_files), #needing_publication + 1, needing_publication)


            log:debug(string.format("Added %4d files for new total of %4d for %s", #(html_file.associated_files)+2,  #needing_publication, html_file.relative_path))
            -- require 'pl.pretty'.dump(to_be_compiled)

            -- Store xourses, they have to be added explicitly to metadata.json
            if tex_file.tex_documentclass == "xourse" then
                log:info("Adding XOURSE "..tex_file.relative_path.." ("..html_file.title..")")
                tex_xourses[html_file.relative_path:gsub(".html","")] = { title = html_file.title, abstract = html_file.abstract } 
            end
          end
        end
    end

    if path.exists("global.css") then
        log:debugf("Added global.css file")
        needing_publication[#needing_publication + 1] = "global.css"
    end


    -- TODO: check/fix use of 'github'; check use of labels
    local xmmetadata={
        xakeVersion = "2.5",
        labels = all_labels,
        github = {},
        xourses = tex_xourses,
    }

    save_as_json(xmmetadata)
    -- require 'pl.pretty'.dump(tex_xourses)
    needing_publication[#needing_publication + 1] = "metadata.json"

    -- 
    -- START ACTUAL FROSTING (ie, creating a 'publication tag')
    --
    local _, head_oid = osExecute("git rev-parse HEAD")
    if not head_oid then
        log:error("No headid returned by git rev-parse HEAD")
    end

    local publication_branch = "PUB_"..head_oid

    local ret, publication_oid = osExecute("git rev-parse --verify --quiet "..publication_branch)
    if ret > 0 then   -- publication_branch does noy (yet) exist: create it
        osExecute("git branch "..publication_branch)
        publication_oid = head_oid
    end
    log:debug("GOT publication_oid "..(publication_oid or ""))

    if path.exists("ximera-downloads") then
        osExecute("git add -f ximera-downloads")
    else 
        log:debug("No ximera-downloads folder, and thus no PDF files will be made available for download")
    end
    -- require 'pl.pretty'.dump(needing_publication)

    -- 'git add' the files in batches of 10   (risks line-too-long!)
    -- local files_string = table.concat(needing_publication,",")
    -- Execute the git add command

    -- local downloads =  list_files("ximera-downloads")
    -- table.move(downloads, 1, #downloads, #needing_publication + 1, needing_publication)

-- if false then
--     local f = io.open(".xmgitindexfiles", "w")

--     for _, line in ipairs(needing_publication) do
--         log:trace("ADDING "..line)
--         f:write(line .. "\n")
--     end
--     f:close()
--     -- Close the process to flush stdin and complete execution
--     local proc = io.popen("cat .xmgitindexfiles | git update-index --add  --stdin")
--     local output = proc:read("*a")
--     local success, reason, exit_code = proc:close()

--     if not success then
--         log:errorf("git update-index fails with %s (%d)",reason, exit_code)
--     else 
--         log:debugf("Added %d files (%s)", #needing_publication,output)
--     end

-- else    
    for _, line in ipairs(needing_publication) do
        log:trace("ADDING "..line)
        osExecute("git add -f "..line)
    end
-- end


    local _, new_tree = osExecute("git write-tree")
    if not new_tree then
        log:error("No tree returned by git write-tree")
    end
    log:debug("Made new tree ", new_tree)

    -- local tagName = "publications/"..head_oid
    -- result, tag_oid = osExecute("git for-each-ref --sort=-creatordate --count=1 --format '%(refname:strip=2)' refs/tags/publications/*")
    
    local result, most_recent_publication = osExecute("git for-each-ref --sort=-creatordate --count=1 --format '%(tree) %(objectname) %(refname:strip=2)' refs/tags/publications/*")
    
    local tagtree_oid, tag_oid,tagName
    if not most_recent_publication or most_recent_publication == "" then
        log:info("No publication tag found")
    else
        log:debugf("Got publication: %s",most_recent_publication)

        tagtree_oid, tag_oid, tagName = most_recent_publication:match("([^%s]+) ([^%s]+) ([^%s]+)")

        log:infof("Found %s  (tree:%s tag:%s) ", tagName, tagtree_oid, tag_oid)
    end

    if tagtree_oid and tagtree_oid == new_tree then
        log:statusf("Tag "..tagName.." already exists (for %s)",tag_oid)
        return 0, 'Reusing '..tagName
    end
    
    -- Give a dummy account to push/commit if none is available
    ret, output = osExecute("git config  --get user.name  || { echo Setting container-global git user.name;  git config --global user.name  'xmlatex Xake'; }")
    ret, output = osExecute("git config  --get user.email || { echo Setting container-global git user.email; git config --global user.email 'xmlatex@xakecontainer'; }")

    local ret, commit_oid = osExecute("git commit-tree -m "..publication_branch.." -p "..publication_oid.." "..new_tree)
    if ret > 0 then
        return ret, commit_oid   -- this is the errormessage in this case!
    end
    log:debug("GOT commit "..(commit_oid or ""))
    
    if logging.show_level <= logging.levels["trace"] then
        log:tracef("Committed files for %s:", commit_oid)
        osExecute("git ls-tree -r --name-only "..commit_oid)
    end

    local ret, output = osExecute("git reset")

    -- TODO: check this, we might be creating too many commits/.. 
    if false and tagtree_oid then
        log:statusf("Updating tag %s for %s (was %s)", tagName, commit_oid, tag_oid)
        ret, output = osExecute("git update-ref refs/tags/"..tagName.." "..commit_oid)
    else
        --local tagName = "publications/"..os.date("%Y%m%d_%H%M%S")
        tagName = "publications/"..commit_oid
        log:statusf("Creating tag %s for %s", tagName, commit_oid)
        ret, output = osExecute("git tag "..tagName.." "..commit_oid)
        -- if ret > 0 then
        --     log:errorf("Created tag %s for %s: %s", tagName, commit_oid, output)
        -- end
    end

    -- restore ownership of files: committing INSIDE a container creates files owned by root !
    local testfile = ".git"    -- file from which to get the original ownership; 
    local attributes = lfs.attributes(testfile)

    if not attributes then
        log:warningf("Could not determine owner of .git folder....")
    elseif attributes.uid == 0 then
        log:warningf("BIZAR: .git folder owned by root ...? Skipping resetting ownership.")
    else
        local set_uidgid = attributes.uid ..":".. attributes.gid
        log:debugf("Resetting ownership af all files to  uid:gid %s", set_uidgid)
        ret, output = osExecute("chown -R " .. set_uidgid .. " .")
    end

    if ret > 0 then    -- TODO: check/correct usage ret value(s)
        return ret, output
    else
        return 0, "Created "..tagName
    end
end

local function serve(force_serving)

    local result, most_recent_publication = osExecute("git for-each-ref --sort=-creatordate --count=1 --format '%(tree) %(objectname) %(refname:strip=2)' refs/tags/publications/*")

    if not most_recent_publication or most_recent_publication == "" then
        log:warning("No publication tags found. Need 'frost' first?")
        return 1, 'No publications found'
    end

    log:debugf("Got publication: %s",most_recent_publication)
    
    local ret, remote_ximera = osExecute("git remote get-url ximera")
    
    if ret > 0 then
        log:warning("No remote 'ximera' found. Need 'name' first?")
        return 1, "No remote 'ximera' found"
    end
    if remote_ximera:match("localhost") then
        log:infof("Publishing to localhost: %s", remote_ximera)
        force_serving = true
    end

    local tree_oid, tag_oid, tagName = most_recent_publication:match("([^%s]+) ([^%s]+) ([^%s]+)")

    log:debugf("Publishing  %s  (tree:%s tag:%s) ", tagName, tree_oid, tag_oid)
    
    
    local ret, output
    if force_serving then
    
    --  do not warn-on-error
        log:statusf("Forced serving (git push -f ximera "..tagName..")")
        ret, output = osExecute("git push -f ximera "..tagName, true)
    else
        ret, output = osExecute("git push ximera "..tagName, true)
    end
    if ret > 0 then
        log:tracef("Could not push to 'ximera' target: %s",output)
        if true or not force_serving then   -- SKIPPED, see above !
            return ret, output
        else
            log:infof("Retrying push with more power (git push -f ...)")
            ret, output = osExecute("git push -f ximera "..tagName)
            if ret > 0 then
                return ret,output
            end
        end
    end

    
    local ret, output
    if force_serving then
    
    --  do not warn-on-error
        log:status("Forced serving (git push -f ximera "..tag_oid..":refs/heads/master)")
        ret, output = osExecute("git push -f ximera "..tag_oid..":refs/heads/master", true)     -- HACK ???
    else
        ret, output = osExecute("git push ximera "..tag_oid..":refs/heads/master", true)     -- HACK ???
    end

    if ret > 0 then
        log:tracef("Could not push refs to 'ximera' target: %s",output)
        if true or not force_serving then
            return ret,output
        else
            log:infof("Retrying push with more power (git push -f ximera  "..tag_oid..":refs/heads/master)")
            ret, output = osExecute("git push -f ximera "..tag_oid..":refs/heads/master") 
            if ret > 0 then
                return ret,output
            end
        end
    end
    
    log:debugf("Published %s to     %s", tagName, remote_ximera)
    return 0, "Published  " .. tagName .. "to  " .. remote_ximera:gsub(".git","")
end

M.frost      = frost
M.serve      = serve
M.osExecute  = osExecute

return M
