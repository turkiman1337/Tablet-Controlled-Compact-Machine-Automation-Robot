--magic.lua--

-- Requires --
local robot = require("robot")
local component = require("component")
local computer = component.computer
local sides = require("sides")
local look_vars = false
local pattern = require("pattern")
local inv = component.inventory_controller
local modem = component.modem

local myrobot = {}



-- You can change this --
local layout = {}

local dropSlot = 1                  -- the slot where the drop item is
local dropCount = 1                 -- how many items should be dropped

local waitTime = 7.5                -- time between creations
local beeps = true                  -- turn off the beeps

local nrItems = 5                         -- number of items in the interface

-- Do not change after this --
dimensions = #layout

local function randomBeep()
    if beeps then
        computer.beep(math.random(400, 2000))
    end
end

local function walk(steps)
    if steps > 0 then
        for _ = 1, steps do
            robot.forward()
        end
    elseif steps < 0 then
        for _ = steps, -1 do
            robot.back()
        end
    end
end

local function getItemCounts()
	local itemCounts = {}
	for q = 1, nrItems do itemCounts[q] = 0 end
	for z = 1, dimensions do
		for i = 1, #layout[z] do 
	local nr = layout[z][i]
	if nr ~= 0 then
	itemCounts[nr] = itemCounts[nr] + 1
		end
	end
end

itemCounts[dropSlot] = itemCounts[dropSlot] + dropCount

return itemCounts
end 



local function placeDown(slot)
    if slot == 0 then
        return true
    end
    robot.select(slot)
    return robot.placeDown()
end

local function buildOneLayer(layer, layerNr)
    for i = 1, #layer do
        if layerNr == 1 and i == math.ceil(#layer/2) then
            robot.select(inventorySize)
            robot.suckDown()
            randomBeep()
        end
        if not placeDown(layer[i]) then
            robot.select(layer[i]+nrItems)
            robot.transferTo(layer[i])
            placeDown(layer[i])
        end
        robot.forward()
        if i % dimensions == 0 and i ~= dimensions^2 then
            if i % (dimensions*2) == 0 then
                robot.turnLeft()
            else
                robot.turnRight()
            end
            robot.forward()
            if i % (dimensions*2) == 0 then
                robot.turnLeft()
            else
                robot.turnRight()
            end
            robot.forward()
        end
    end
    randomBeep()
end

local function buildLayers()
    for i = 1, dimensions do
        robot.turnAround()
        robot.up()
        robot.forward()
        buildOneLayer(layout[i], i)
    end
    randomBeep()
end

local function getItems()
    local stackSize = 64
        robot.turnRight()
        robot.forward()
        robot.turnLeft()
    for i = 1, nrItems do
        robot.select(i)
        randomBeep()
        inv.suckFromSlot(sides.front,i+9, itemCounts[i])
        if itemCounts[i] > stackSize then
            robot.select(nrItems+i)
            inv.suckFromSlot(sides.front,nrItems+i+9, itemCounts[i]-stackSize)
        end
    end
end

function loadGiant()
  layout = pattern.giant.pattern
  waitTime = pattern.giant.time
  dropSlot = pattern.giant.dropSlot
  end

function loadNormal()
  layout = pattern.normal.pattern
  waitTime = pattern.normal.time
  dropSlot = pattern.normal.dropSlot
  end
  
function configurate(patternName)
  if patternName == "giant" then
    loadGiant()
    end
  if patternName == "normal" then
    loadNormal()
    end
  end

function main()
    randomBeep()
  dimensions = #layout
  inventorySize = robot.inventorySize()
  itemCounts = getItemCounts()
        -- get the items
        robot.back()
        modem.broadcast(69, "Get Items")
        getItems()
        -- go to start position
        robot.turnRight()
        walk(dimensions)
        robot.turnLeft()
        -- build
        modem.broadcast(69, "Building")
        buildLayers()
        -- go to item throw position
        robot.turnRight()
        walk(2)
        while not robot.detectDown() do robot.down() end
        robot.turnRight()
        robot.forward()
        robot.turnRight()
        robot.select(dropSlot)
        randomBeep()
        robot.drop(dropCount)
        -- go back to station
        robot.turnLeft()
        while not robot.detect() do robot.forward() end
        -- deposit items
        robot.select(inventorySize)
        robot.dropUp()
        randomBeep()
        modem.broadcast(69, "Waiting")
    os.sleep(waitTime)
        modem.broadcast(69, "Ready")
end

function printLayout()
    table1 = layout[1]
    print(table1[1]..","..table1[2]..","..table1[3])
    print(table1[4]..","..table1[5]..","..table1[6])
    print(table1[7]..","..table1[8]..","..table1[9])
    
    print(" ")
    
    table2 = layout[2]
    print(table2[1]..","..table2[2]..","..table2[3])
    print(table2[4]..","..table2[5]..","..table2[6])
    print(table2[7]..","..table2[8]..","..table2[9])
    
    print(" ")
    
    table3 = layout[3]
    print(table3[1]..","..table3[2]..","..table3[3])
    print(table3[4]..","..table3[5]..","..table3[6])
    print(table3[7]..","..table3[8]..","..table3[9])
    
end

function myrobot.activate(a)
  configurate(a)
  print(waitTime.. " waitTime")
  print(dropSlot.. " dropSlot")
  printLayout()
  main()
end

return myrobot
