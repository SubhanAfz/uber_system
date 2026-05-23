local basalt = require("basalt")

local function readFile(path)
    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()
    return content
end

local monitor = peripheral.find("monitor")
local main
local width
local height

if monitor then
    main = basalt.createFrame():setTerm(monitor)
    width, height = monitor.getSize()
else
    main = basalt.getMainFrame()
    width, height = term.getSize()
end

local coordsScreen = main:addFrame()
coordsScreen:setPosition(1, 1)
coordsScreen:setSize(width, height)

local tripScreen = main:addFrame()
tripScreen:setPosition(1, 1)
tripScreen:setSize(width, height)

local function showCoords()
    tripScreen:setVisible(false)
    coordsScreen:setVisible(true)
end

local function submitCoords()
    local x = tonumber(coordsScreen:getChild("coordsRoot/coordsForm/xField/xInput"):getText()) or 0
    local y = tonumber(coordsScreen:getChild("coordsRoot/coordsForm/yField/yInput"):getText()) or 0
    local z = tonumber(coordsScreen:getChild("coordsRoot/coordsForm/zField/zInput"):getText()) or 0
    local distance = math.floor(math.sqrt(x * x + y * y + z * z))
    local arrivalLabel = tripScreen:getChild("tripRoot/arrivalLabel")

    arrivalLabel:setText(string.format("at (%d, %d, %d) - %d Away", x, y, z, distance))

    coordsScreen:setVisible(false)
    tripScreen:setVisible(true)
end

coordsScreen:loadXML(readFile("coords.xml"), {
    submitCoords = submitCoords,
})

tripScreen:loadXML(readFile("trip.xml"), {
    showCoords = showCoords,
})

tripScreen:setVisible(false)

basalt.run()
