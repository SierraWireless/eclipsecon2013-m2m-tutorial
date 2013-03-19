-------------------------------------------------------------------------------
-- Copyright (c) 2012, 2013 Sierra Wireless and others.
-- All rights reserved. This program and the accompanying materials
-- are made available under the terms of the Eclipse Public License v1.0
-- which accompanies this distribution, and is available at
-- http://www.eclipse.org/legal/epl-v10.html
--
-- Contributors:
--     Sierra Wireless - initial API and implementation
-------------------------------------------------------------------------------

local sched  = require 'sched'
local modbus = require 'modbus'
local utils  = require 'utils'
local tableutils = require "utils.table"

local MODBUS_PORT = "/dev/ttyACM0"     -- serial port on Raspberry Pi
local MODBUS_CONF = {baudRate = 9600 }

local LOG_NAME = "GREENHOUSE_APP"

local modbus_client =  modbus.new(MODBUS_PORT, MODBUS_CONF)
local modbus_client_pending_init = false

-- ----------------------------------------------------------------------------
-- DATA
-- ----------------------------------------------------------------------------

local modbus_registers =  { luminosity  = 0,
    temperature = 1}

local led_register =  11

local modbus_process = { luminosity  = utils.processLuminosity,
    temperature = utils.processTemperature}

setmetatable(modbus_process,{__index = function (_, _) return utils.identity end})

--- Init Modbus
local function init_modbus()
    if modbus_client_pending_init then return; end
    modbus_client_pending_init = true
    if modbus_client then modbus_client:close(); end
    sched.wait(1)
    modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
    sched.wait(1)
    log(LOG_NAME, "INFO", "Modbus client re-init'ed")
    modbus_client_pending_init = false
end


local function process_modbus ()
    local buffer = modbus_client:readHoldingRegisters(1,0,6)

    if not buffer then
        log(LOG_NAME, "ERROR", "Unable to read modbus")
        init_modbus()
        return end

    local values = { select(2, string.unpack(buffer, 'h6')) }

    for type, address in pairs(modbus_registers) do
        val = modbus_process[type](values[address+1])
        log(LOG_NAME, "INFO", "Read from modbus %s : %s", type, tostring(val))
    end

end

local function main()
    log.setlevel("INFO")
    log(LOG_NAME, "INFO", "Application started")

    if (modbus_client) then
        log(LOG_NAME, "INFO", "Modbus   - OK")
    end

    log(LOG_NAME, "INFO", "Init done")

    sched.wait(2)
    while true do
        process_modbus()
        sched.wait(1)
    end
end

local led_state = 0
local function blink_led()
    sched.wait(2)
    while true do
        modbus_client:writeMultipleRegisters(1,led_register, string.pack('h', led_state))
        led_state = (led_state + 1) % 2
        sched.wait(1)
    end
end

sched.run(main)
sched.run(blink_led)
sched.loop()
