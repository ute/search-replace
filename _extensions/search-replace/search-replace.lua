
-- filter for abbreviations, also replaces in links
-- not really elegantly programmed, but seems to do its job :-)
--[[
MIT License

Copyright (c) 2023 Ute Hahn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

-- local pout=quarto.log.output
-- local str= pandoc.utils.stringify
-- local ptyp = pandoc.utils.type

local abbreviations = {}
local abbr ={}


-- helper function, for readability
local function append(lst1, lst2)
  for _, v in ipairs(lst2) do
    table.insert(lst1, v)
  end 
  return(lst1)
end  

local function replacevalues(lst1, lst2)
  for i, v in ipairs(lst2) do
    lst1[i]= v
  end 
  return(lst1)
end  


-- function that takes a string and a list of patterns
--- returns: first occurrence of any pattern, or nil
---  start, end, pattern
local findfirst = function(strg, patts)
  if strg == nil or patts == nil then return nil end
  if #strg == 0 or #patts == 0 then return nil end
  local a, b, n = 0, 0, #strg + 1
  local A = n
  local Patt = ""
  for i, patt in pairs(patts) do
     a, b = string.find(strg, patt)
     if a then
       if a < A then
         A = a
         B = b
         Patt = patt
       end   
     end   
  end
  if A < n then return A, B, Patt
    else return nil 
  end    
end


-- Todo-if-bored: rewrite, just replacing from back to front
local  replace_abbr_in_str = function(original)
  local result = pandoc.Inlines("")    
  local istart, iend, patt = findfirst(original, abbr)
  local found = false
  if istart then 
    found = true
    while found do 
      if istart > 1 then -- preserve start
        local startstr = string.sub(original, 1, istart-1)
        table.insert(result,  pandoc.Str(startstr))
      end
      append(result, abbreviations[patt])
      original = string.sub(original, iend+1, #original)
      istart, iend, patt = findfirst(original, abbr)
      found = istart ~= nil
    end
    if #original > 0 then table.insert(result, pandoc.Str(original)) end
    return(result)
  else
    return(pandoc.Inlines(original))
  end     
end   

replace_abbr = {
  Inlines=function(ilist)
    local newtable =  pandoc.Inlines("") 
    local zzz = pandoc.Inlines("") 
    for i, v in ipairs(ilist) do
       if v.t == "Str" then
          zzz = replace_abbr_in_str(v.text)
       elseif v.t == "Link" then
          -- gets already processed as Str :-) v.content = replace_abbr_in_str(pandoc.utils.stringify(v.content))
          v.target = pandoc.utils.stringify(replace_abbr_in_str(pandoc.utils.stringify(v.target)))
          zzz = pandoc.Inlines(v)  
       else  zzz = pandoc.Inlines(v)  
       end
      newtable = append(newtable, zzz)
    end
   return(newtable)
  end
}


return{
{
 Meta = function(m)
  local abbrdefs = m["search-replace"]
  local i = 1
   for k, v in pairs(m) do
     if string.sub(k, 1, 1) == "+" then 
        abbreviations[k] = v
        abbr[i] = k
        i = i+1
      end
   end
  if abbrdefs then 
    for k, v in pairs(abbrdefs) do
         abbreviations[k] = v
         abbr[i] = k
         i = i+1
    end
  end
  return(m)
  end
} , 

{
Callout = function(call)
  if call.title then
    call.title = call.title:walk(replace_abbr)  
  end
  if call.content then
    call.content = call.content:walk(replace_abbr)  
  end
  return(call)
end,

Pandoc = function(doc)
  return(pandoc.Pandoc(doc.blocks:walk(replace_abbr), doc.meta))
end  
}
}


