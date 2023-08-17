local gfs = require("gears.filesystem")

local lock_screen = {}

local config_dir = gfs.get_configuration_dir()
package.cpath = package.cpath .. ";" .. config_dir .. "modules/lockscreen/lib/?.so;"

lock_screen.init = function(screen_locked)
	local pam = require("liblua_pam")
	lock_screen.authenticate = function(password)
		--return pam.auth_current_user(password)
		if pam.auth_current_user(password) then
      screen_locked.value = false
      return true
    else
      return false
    end
	end
	require("modules.lockscreen.lockscreen")
end

return lock_screen
