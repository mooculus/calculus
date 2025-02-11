local Graph = { nodes = {} }

function Graph:new()
  setmetatable(Graph, self)
  self.__index = self
  return self
end

--- initialize graph node
---@param a string
---@return table
function Graph:add_node(a)
  local node = self.nodes[a] or { edges = {}, edges_from = {}}
  self.nodes[a] = node
  return node
end

--- add edge between nodes
---@param a string parent node
---@param b string child node
---@param value? any 
function Graph:add_edge(a,b, value)
  -- get the parent edge
  local parent = self:add_node(a)
  -- initialize also the second node
  local child = self:add_node(b)
  -- we can either add a value, or just simply use true
  value = value or true
  parent.edges[b] = value
  child.edges_from[a] = value
end

--- get node
---@param a string node name
---@return table node
function Graph:get_node(a)
  return self.nodes[a]
end

--- count number of items in a hash table
---@param tbl table hash table to be counted
---@return number count
local function count_table(tbl)
  local count = 0
  for _, _ in pairs(tbl) do count = count + 1 end
  return count
end

--- count number of edges pointing to the given node
---@param a string node
---@return number count of edges
function Graph:count_incoming_edges(a)
  return count_table(self.nodes[a].edges_from)
end



function Graph:sort()
  -- based on Kahn's algorithm
  local L = {}
  local S = {}
  local all_edges = {}
  -- prepare table with all edges that points to the given node
  for name, node in pairs(self.nodes) do
    local t = {}
    for edge, _ in pairs(node.edges_from) do t[edge] = true end
    all_edges[name] = t
  end
  -- get list of nodes with no incoming edges
  for name, _ in pairs(self.nodes) do
    if self:count_incoming_edges(name) == 0 then S[#S+1] = name end
  end
  while #S > 0 do
    -- remove first entry from the list of nodes with no incoming edges
    local n = table.remove(S, 1)
    L[#L+1] = n
    local node = self:get_node(n)
    -- find all nodes that are children of n
    for m, _ in pairs(node.edges) do
      -- get edges that point to m
      local edges = all_edges[m]
      if edges[n] then
        -- remove edge from n to m
        edges[n] = nil
        -- if there are no other edges, we need to process this node in the next run of this loop
        if count_table(edges) == 0 then
          S[#S+1] = m
        end
      end
    end
  end
  -- test if we removed all edges
  local count = 0
  for _, tbl in pairs(all_edges) do
    count = count + count_table(tbl)
  end
  if count > 0 then
    return nil, "Graph has "..count.." cycles"
  end
  return L
end

---------------------
-- Example of use: --
-- ------------------
-- local graph = Graph:new()
-- 
-- 
-- graph:add_edge("a", "b")
-- graph:add_edge("a", "c")
-- graph:add_edge("b", "d")
-- graph:add_edge("c", "d")
-- graph:add_edge("d", "e")
-- graph:add_edge("b", "e")
-- 
-- for _, name in ipairs(graph:sort()) do
--   print(name)
-- end
--

return Graph




