--magic.lua--

-- Requires --
local robot = require("robot")
local component = require("component")
local computer = component.computer
local sides = require("sides")
local look_vars = false
local pattern = require("pattern")

local myrobot = {}

fucntion myrobot.setconfig(a)

-- You can change this --
local layout = {}

local dropSlot = 1                  -- the slot where the drop item is
local dropCount = 1                 -- how many items should be dropped

local waitTime = 7.5                -- time between creations
local beeps = true                  -- turn off the beeps

-- Do not change after this --

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



local function getNrItems()
    local itemCounts = {}
    for z = 1, dimensions do
        for i = 1, #layout[z] do
            local itemNr = layout[z][i]
            if itemNr ~= 0 then
                local ic = itemCounts[itemNr]
                if ic ~= nil then
                    itemCounts[itemNr] = ic+1
                else
                    itemCounts[itemNr] = 1
                end
            end
        end
    end
    local ic = itemCounts[dropSlot]
    if ic ~= nil then
        itemCounts[dropSlot] = ic+dropCount
    else
        itemCounts[dropSlot] = dropCount
    end
    return #itemCounts, itemCounts
end

local nrItems, itemCounts = getNrItems()

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
    for i = 1, nrItems do
        robot.turnRight()
        robot.forward()
        robot.turnLeft()
        robot.select(i)
        randomBeep()
        robot.suck(itemCounts[i])
        if itemCounts[i] > stackSize then
            robot.select(nrItems+i)
            robot.suck(itemCounts[i]-stackSize)
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
  if patternName = "giant" then
    loadGiant()
    end
  if patternName = "normal" then
    loadNormal()
    end
  end

function main(a)
    randomBeep()
configurate(a)
  dimensions = #layout
  inventorySize = robot.inventorySize()

        -- get the items
        robot.back()
        getItems()
        -- go to start position
        robot.turnRight()
        walk(dimensions+1-nrItems)
        robot.turnLeft()
        -- build
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
    os.sleep(waitTime)
end

function myrobot.activate(a)
  main()
end

return myrobot
