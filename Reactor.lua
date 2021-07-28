require "config"
-- Base variables
-- Rod is never referenced global, nor should it ever.  It serves as a template to what it should look like
-- Rod = { rodId = 0, rodName = "", insertionLevel = 0}
Reactor = {
    name = "",
    connection = nil,
    info = ReactorInformation,
    energyCapacity = 0,
    storedEnergy = 0,
    controlRods = {}
}

function Reactor:New(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    self.info = ReactorInformation
    self.name = ReactorInformation.reactorName
    self:Connect()
    return o
end

-- Connects to the reactor, or re-connects if not connected
function Reactor:Connect()
    if(type(self.connection) == "nil") then
        self.connection = peripheral.wrap(self.info.modemPort)
        self.connection.open(self.info.connectionId)
    elseif(not self.connection.isOpen(self.info.connectionId)) then
        self.connection = peripheral.wrap(self.info.modemPort)
        self.connection.open(self.info.connectionId)
    end
    return self.connection
end

-- Halts reactor and shutdown.
-- This inserts all of the rods and powers off the reactor
-- It is possible that attached steam devices could have
-- adverse effects with a scram.  But this is a last ditch
-- effort to regain control of a runaway reaction.
function Reactor:Scram()
    self:SetAllControlRods(100)
    self:Connect().callRemote(self.name, "setActive", false)
end

-- Gets all of the data on the control rods in the system.
-- Note, that the current version returns Control Rod Blocks x Interior Height;
-- A reactor with 5 control rod blocks, with a height of 3 would return 15
-- control rods.
function Reactor:GetAllControlRods()
    -- Just get all of the rod information, it is arranged as an array starting at 0
    local rods = self:Connect().callRemote(self.name, "getControlRodsLevels")
    -- Clear Any Control Rod Data in the table under r
    self.controlRods = {}

    for key,value in ipairs(rods)
    do
        -- Get Control Rod Name, is empty on not set
        local rodName = self:Connect().callRemote(self.name, "getControlRodName", key)
        local rodData = { RodId = key, RodName = rodName, InsertionLevel = value}
        table.insert(self.controlRods, rodData)
    end

    -- Return only the control rod section; this is to ensure we don't mess up
    -- the network connection.  The calling function should ideally overright
    -- Reactor.ControlRods table
    return self.controlRods
end

-- Attempts to power on the reactor.  If it is already running,
-- check if it has been scrammed, and if so; slowly allow power
-- restoration.
function Reactor:PowerOn()
    -- Begin Pre-power on checks
    -- Get current state of reactor
    local isPoweredOn = self:Connect().callRemote(self.name, "getActive")
    if(isPoweredOn == true) then
        -- Are we generating power?
        if(Reactor:GetPowerGeneratedLastTick() ~= 0) then
            -- Power was generated, exit start routine
            return
        end
        -- Check for scram, also this is a sanity check for issues regarding chunk 'dirtiness'
        local cRods = self:GetAllControlRods()
        for k,v in ipairs(cRods)
        do
            if(v == 100) then
                -- Control rod is scrammed, reduce to 90% to allow a slow restart
                self:SetControlRod(k, 90)
            end
        end
        -- Reactor should now be online running at 10% capacity
    else
        -- Reactor is off, perform a cold start to 20% power
        self:SetAllControlRods(80)
        self:Connect().callRemote(self.name, "setActive", true)
    end
end

-- This function is going to need some work.  The idea is that it should
-- insert the control rods to maximum effect, then monitor outputs of
-- power, heat, steam, etc. until the reactor has safely shutdown.
function Reactor:PowerOff()
    self:SetAllControlRods(100) -- Soft turn off the reactor

    while Reactor:GetFuelTemp() > 100 do
        sleep(1)
    end

    -- In Theory this should be already cool since it usually cools at the same rate as the fuel
    while Reactor:GetCasingTemp() > 100 do
        sleep(1)
    end
    self:SetActive(false)  -- Turn the reactor off
end

--#region Reactor Actions

-- Ejects all of the available fuel from the reactor
function Reactor:EjectFuel()
    return self:Connect().callRemote(self.name, "doEjectFuel")
end

-- Ejects all of the available waste from the reactor
function Reactor:EjectWaste()
    return self:Connect().callRemote(self.name, "doEjectWaste")
end
--#endregion

--#region Set Wrapper Calls

-- Sets the given control rod to the given level
function Reactor:SetControlRod(rod, insertionLevel)
    if(type(rod) ~="number" and type(insertionLevel) ~="number") then
        error("Control Rod Number and insertion level need to be given")
        return
    end
    self:Connect().callRemote(self.name, "setControlRodLevel", rod, insertionLevel)
end

-- Sets all of the control rod insertion level
function Reactor:SetAllControlRods(insertionLevel)
    if(type(insertionLevel) ~= "number") then
        error("insertionLevel was not a number")
    end
    if(not(insertionLevel >= 0 and insertionLevel <= 100)) then
        error("insertionLevel not between 0 and 100")
    end
    self:Connect().callRemote(self.name, "setAllControlRodLevels", insertionLevel)
end

-- Powers the reactor on or off
function Reactor:SetActive(poweredOn)
    if(type(poweredOn) ~="boolean" )then
        error("Powered State is to be a bool (true/false) and must be defined")
        return
    end
    return self:Connect().callRemote(self.name, "setActive", poweredOn)
end

--#endregion

--#region Get Wrapper Calls

-- Gets the given control rod level
function Reactor:GetControlRodLevel(rod)
    if(type(rod) ~= "number") then
        error("Rod id not given")
    end
    return self:Connect().callRemote(self.name, "getControlRodLevel", rod)
end

-- Gets the name of the given control rod, not used ATM
function Reactor:GetControlRodName(rod)
    return self:Connect().callRemote(self.name, "getControlRodName", rod)
end

-- Returns the fuel amount left in the reactor
function Reactor:GetFuelAmount()
    return self:Connect().callRemote(self.name, "getFuelAmount")
end

-- Returns the maximum fuel storage of the reactor
function Reactor:GetFuelAmountMax()
    return self:Connect().callRemote(self.name, "getFuelAmountMax")
end

-- Gets the fuel reactivity rate (higher is better)
function Reactor:GetFuelReactivity()
    return self:Connect().callRemote(self.name, "getFuelReactivity")
end

-- Gets the amount of fuel consumed during the last tick
function Reactor:GetFuelConsumedLastTick()
    return self:Connect().callRemote(self.name, "getFuelConsumedLastTick")
end

-- Gets a table of fuel statistics
function Reactor:GetFuelStats()
    return self:Connect().callRemote(self.name, "getFuelStats")
end

-- Gets the total amount of waste fuel in the system
function Reactor:GetWasteAmount()
    return self:Connect().callRemote(self.name, "getWasteAmount")
end

-- The current temperature of the fuel
function Reactor:GetFuelTemp()
    return self:Connect().callRemote(self.name, "getFuelTemperature")
end

-- The reactors casing temperature
function Reactor:GetCasingTemp()
    return self:Connect().callRemote(self.name, "getCasingTemperature")
end

-- Gets the current amount of available coolant in the reactor
function Reactor:GetCoolantAmount()
    return self:Connect().callRemote(self.name, "getCoolantAmount")
end

-- Gets the maximum amount coolant that can be stored in the reactor
function Reactor:GetCoolantAmountMax()
    return self:Connect().callRemote(self.name, "getCoolantAmountMax")
end

-- Gets the type of coolant
function Reactor:GetCoolantType()
    return self:Connect().callRemote(self.name, "getCoolantType")
end

-- Gets coolant statistics
function Reactor:GetCoolantStats()
    return self:Connect().callRemote(self.name, "getCoolantStats")
end

-- Gets the 'Hot' fluid amount, aka steam
function Reactor:GetHotFluidAmount()
    return self:Connect().callRemote(self.name, "getHotFluidAmount")
end

-- Gets the maximum level of steam permitted in the reactor
function Reactor:GetHotFluidAmountMax()
    return self:Connect().callRemote(self.name, "getHotFluidAmountMax")
end

-- Gets the statistics for the 'hot' fluid
function Reactor:GetHotFluidStats()
    return self:Connect().callRemote(self.name, "getHotFluidStats")
end

-- Amount of 'hot' fluid (steam) produced last tick
function Reactor:GetHotFluidProducedLastTick()
    return self:Connect().callRemote(self.name, "getHotFluidProducedLastTick")
end

-- Is the reactor actively cooled or passively? true/false
function Reactor:IsActivelyCooled()
    return self:Connect().callRemote(self.name, "IsActivelyCooled")
end

-- Gets the maximum amount of energy that can be stored in the reactor
function Reactor:GetEnergyCapacity()
    return self:Connect().callRemote(self.name, "getEnergyCapacity")
end

-- Gets the current amount of energy stored in the reactor
function Reactor:GetEnergyStored()
    return self:Connect().callRemote(self.name, "getEnergyStored")
end

-- Gets the current amount of energy stored as a text string (used for displays)
function Reactor:GetEnergyStoredAsText()
    return self:Connect().callRemote(self.name, "getEnergyStoredAsText")
end

-- Gets energy statistics for the reactor
function Reactor:GetEnergyStats()
    return self:Connect().callRemote(self.name, "getEnergyStats")
end

-- Gets the amount of power generated last tick
function Reactor:GetPowerGeneratedLastTick()
    return self:Connect().callRemote(self.name, "getEnergyProducedLastTick")
end
--#endregion


-- Checks to see if we have a valid connection to the reactor
function Reactor:IsOnline()
    if(type(self.connection) == "nil") then
        return false
    elseif(self.connection.isOpen(self.info.connectionId)) then
        return true
    else
        return false
    end
end