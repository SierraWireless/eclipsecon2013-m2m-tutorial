-------------------------------------------------------------------------------
-- Copyright (c) 2012, 2013 Sierra Wireless and others.
-- All rights reserved. This program and the accompanying materials
-- are made available under the terms of the Eclipse Public License v1.0
-- which accompanies this distribution, and is available at
-- http://www.eclipse.org/legal/epl-v10.html
--
-- Contributors:
--     Gaétan Morice, Sierra Wireless - initial API and implementation
-------------------------------------------------------------------------------
--
-- @module utils
-- 
local M = {}

function M.processTemperature(value)
	-- 10 mV == 1ºC
	local vsensor = value * 5.0 / 1024
	return vsensor * 100.0
end

function M.processLuminosity(value)
	local vsensor = value * 0.0048828125
	return 500 / ( 10 * ( (5.0 - vsensor) / vsensor ) )
end

return M
