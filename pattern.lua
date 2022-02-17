--pattern.lua

local _M = {}

_M.giant = {

  pattern = {
  
  {1,1,1,
   1,2,1,
   1,1,1},
   
  {1,2,1,
   2,3,2,
   1,2,1},
   
  {1,1,1,
   1,2,1,
   1,1,1}
   },
   
   time = 50,
   dropSlot = 5
  }

_M.normal = {
    pattern = {
  
  {1,1,1,
   1,1,1,
   1,1,1},
   
  {1,1,1,
   1,4,1,
   1,1,1},
   
  {1,1,1,
   1,1,1,
   1,1,1}
   },
   
   time = 25,
   dropSlot = 5
  }
  
return _M
