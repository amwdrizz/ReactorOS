require "Reactor"

-- This sets up the reactor class and initializes the connection
R = Reactor:New(nil)

-- TODO: Add main loop, logic to balance power requirements to power generation, redstone support for scram, etc.
local previousPowerStoreLevel = 0
R:PowerOn()

while true do
    -- local evt = os.pullEventRaw("terminate")
    -- if(evt == "terminate") then
    --     R:Scram()
    --     return
    -- end
    term:clear()
    local powerStats = R:GetEnergyStats()
    -- powerStats should be a table containing the following values
    -- energyStored, energyCapacity, energyProducedLastTick, energySystem
    
    -- Get current control rod status
    local controlRods = R:GetAllControlRods()

    -- Compare to see if we are gaining or loosing power
    if(powerStats.energyStored > previousPowerStoreLevel) then
        -- Gaining Power, increase rod insertion by 2% on all rods
        for k,v in ipairs(controlRods) do
            print("Updating Rod: " .. k)
            print("Current Insertion %: " .. v.InsertionLevel)
            if(v.InsertionLevel >= 96 and v.InsertionLevel < 100) then
                -- we can only go up by 1
                R:SetControlRod(v.RodId, v.InsertionLevel + 1)
                print("New Insertion %: " .. (v.InsertionLevel + 1))
            elseif (v.InsertionLevel == 100) then
                -- Reactor is offline, no demand on grid
                R:SetControlRod(v.RodId, 100)
            else
                R:SetControlRod(v.RodId, v.InsertionLevel + 2)
                print("New Insertion %: " .. (v.InsertionLevel + 2))
            end
        end
    elseif(powerStats.energyStored < previousPowerStoreLevel) then
        -- Loosing power, reduce control rods to increase supply to meet demand
        for k,v in ipairs(controlRods) do
            print("Updating Rod: " .. v.RodId)
            print("Current Insertion %: " .. v.InsertionLevel)
            if(v.InsertionLevel <= 4 and v.InsertionLevel > 0) then
                -- we are almost fully extracted...  Go by 1%
                R:SetControlRod(v.RodId, v.InsertionLevel - 1)
                print("New Insertion %: " .. (v.InsertionLevel - 1))
            elseif(v.InsertionLevel == 0) then
                R:SetControlRod(v.RodId,0)
            else
                R:SetControlRod(v.RodId, v.InsertionLevel - 2)
                print("New Insertion %: " .. (v.InsertionLevel - 2))
            end
        end
    end
    -- lastly update previousPowerStoreLevel
    previousPowerStoreLevel = powerStats.energyStored
    sleep(1)
end
