-- Complete this config file with your configuration
-- values.  This needs to be accurate so it can communicate
-- with your reactor.  If you make changes to your reactor
-- you MUST update this file.

ReactorInformation = {
    -- Reactor Name; you can get this via attaching a modem and network cable to the computer port on the reactor, followed by right clicking the modem to 'connect'
    reactorName = "BigReactors-Reactor_1",

    -- This is the side of the modem on the 'far' end (ie the machine running this code)
    modemPort = "back",

    -- The ID we should use for communicating with the reactor.  If you have alot of networked devices, set this to a unique id
    connectionId = 1,

    -- The interior height of your reactor.  This is needed to complete certian calculations
    -- This is also due to a bug in Extreme Reactors returning fuel rod count vs control rod
    -- count
    interiorHeight = 3,

    -- The target power storage level to9 maintain in decimal (0.1-1.0) is accepted
    targetPowerLevel = .5
}