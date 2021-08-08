require "Reactor"

-- This sets up the reactor class and initializes the connection
R = Reactor:New(nil)
R:PowerOn()

-- local monitor = peripheral.find("monitor")
-- monitor.clear()
-- monitor.setTextScale(.5)
-- monitor.setCursorPos(1,1)
-- monitor.write("ReactorOS v1.1")
-- monitor.setCursorPos(1,2)
-- monitor.write("Created by AMWDrizz")
-- monitor.setCursorPos(1,4)
-- monitor.write("Reactor Status: ")
-- monitor.setTextColor(8192)
-- monitor.write("Online")
-- monitor.setTextColor(1)
-- monitor.setCursorPos(1,5)

while true do
    term:clear()
    local powerStats = R:GetEnergyStats()
    -- powerStats should be a table containing the following values
    -- energyStored, energyCapacity, energyProducedLastTick, energySystem
    
    local maxStorage = powerStats.energyCapacity * .65
    local minStorage = powerStats.energyCapacity * .35
    -- monitor.setCursorPos(1,5)
    -- monitor.clearLine()
    -- monitor.write("Min Storage Level: " .. minStorage)
    -- monitor.setCursorPos(1,6)
    -- monitor.clearLine()
    -- monitor.write("Max Storage Level: " .. maxStorage)

    print("Min Storage Level: " .. minStorage)
    print("Max Storage Level: " .. maxStorage)

    print("Current Energy Stored: " .. powerStats.energyStored)
    if(powerStats.energyStored > maxStorage) then
        R:SetAllControlRods(100)
        -- monitor.setCursorPos(16,4)
        -- monitor.setTextColor(16)
        -- monitor.write("Standby Mode")
        -- monitor.setTextColor(1)
    elseif (powerStats.energyStored < minStorage) then
        R:SetAllControlRods(0)
        -- monitor.setCursorPos(16,4)
        -- monitor.setTextColor(8192)
        -- monitor.write("Generating  ")
        -- monitor.setTextColor(1)
    end
    sleep(5)
end