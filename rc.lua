function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
local usr_home= os.getenv( "HOME" ) 
pcall(require, "luarocks.loader")
require('collision')()
local awmodoro = require("awmodoro")
local battery_exists = false

if file_exists('/sys/class/power_supply/BAT0') then
  battery_exists = true
  --local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
end
local github_contributions_widget = require("awesome-wm-widgets.github-contributions-widget.github-contributions-widget")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local ram = require("awesome-wm-widgets.ram-widget.ram-widget")
local volume_widget = require('awesome-wm-widgets.pactl-widget.volume')
local todo_widget = require("awesome-wm-widgets.todo-widget.todo")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")

local lockscreen = require("modules.lockscreen")
lockscreen.init()

if file_exists(usr_home .."/.cache/wal/theme.lua") then 

	beautiful.init(usr_home .."/.cache/wal/theme.lua")
else

	beautiful.init(usr_home .."/.config/awesome/theme.lua")
end

local wibox = require("wibox")
--
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local bling = require("bling")
local app_launcher_config = {
    terminal = "alacritty",                                            -- Set default terminal
    search_commands = false,                                            -- Search by app name AND commandline command
    sort_alphabetically = true,                                        -- Sorts applications alphabetically
    select_before_spawn = false,                                        -- When selecting by mouse, click once to select app, click once more to open the app.
    hide_on_left_clicked_outside = true,                               -- Hide launcher on left click outside the launcher popup
    hide_on_right_clicked_outside = true,                              -- Hide launcher on right click outside the launcher popup
    hide_on_launch = true,                                             -- Hide launcher when spawning application
    try_to_keep_index_after_searching = false,                         -- After a search, reselect the previously selected app
    reset_on_hide = true,                                              -- When you hide the launcher, reset search query
    save_history = true,                                               -- Save search history
    wrap_page_scrolling = true,                                        -- Allow scrolling to wrap back to beginning/end of launcher list
    wrap_app_scrolling = true ,                                        -- Set app scrolling

    type = "dock",
    show_on_focused_screen = true,                                     -- Should app launcher show on currently focused screen
    screen = awful.screen,                                             -- Screen you want the launcher to launch to
    placement = awful.placement.centered,                              -- Where launcher should be placed ("awful.placement.centered").
    shrink_width = false,                                               -- Automatically shrink width of launcher to fit varying numbers of apps in list (works on apps_per_column)
    shrink_height = false,                                              -- Automatically shrink height of launcher to fit varying numbers of apps in list (works on apps_per_row)
    background = beautiful.bg_separator,                                            -- Set bg color
    border_width = 0,                                             -- Set border width of popup
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 50)
    end,                                                               -- Set shape for launcher
    prompt_height = 50,
    prompt_margins = 30,
    prompt_paddings = 1,                                         -- Prompt padding
    prompt_shape = function(cr, width, height)
      gears.shape.rectangle(cr, width, height)
    end                        ,                                       -- Set shape for prompt
    prompt_color = beautiful.bg_separator,                                      -- Prompt background color
    prompt_border_width = 0 ,
    prompt_text_halign = "left"   ,                                  -- Prompt text horizontal alignment
    prompt_text_valign = "center"    ,                                 -- Prompt text vertical alignment
    prompt_icon_text_spacing = 10,                                -- Prompt icon text spacing
    prompt_show_icon = false            ,                               -- Should prompt show icon (?)
    prompt_icon_color = "#000000" ,                                    -- Prompt icon color
    prompt_icon = ""  ,                                               -- Prompt icon
    prompt_icon_markup = string.format(
        "<span size='xx-large'>%s</span>",
        " "
    )                   ,                                              -- Prompt icon markup
    prompt_text = "<b>Search</b>:" ,
    prompt_start_text = "manager"  ,                                   -- Set string for prompt to start with
    prompt_text_color = "#FFFFFF"    ,                                 -- Prompt text color
    prompt_cursor_color = "#000000"  ,                                 -- Prompt cursor color

    apps_per_row = 3                  ,                                -- Set how many apps should appear in each row
    apps_per_column = 1                ,                               -- Set how many apps should appear in each column
    apps_margin = {left = 40, right = 40, bottom = 30} ,-- Margin between apps
    apps_spacing = 10  ,                                          -- Spacing between apps

    expand_apps = true       ,                                         -- Should apps expand to fill width of launcher
    app_width = 700 ,                                        -- Width of each app
    app_height = 30,                                       -- Height of each app
    app_shape = function(cr, width, height)
      gears.shape.rounded_bar(cr, width, height)
    end   ,                                                            -- Shape of each app
    app_normal_color = beautiful.bg_separator,
    app_normal_hover_color = beautiful.fg_normal,
    app_selected_color = beautiful.bg_normal,
    app_selected_hover_color = beautiful.fg_normal,
    app_content_padding = 5,
    app_content_spacing = 5,
    app_show_icon = false                     ,                         -- Should show icon?
    app_show_name = true                ,                              -- Should show app name?
    app_name_generic_name_spacing = 0,                            -- Generic name spacing (If show_generic_name)
    app_name_halign = "center"             ,                           -- App name horizontal alignment
    app_name_normal_color = beautiful.fg_normal,
    app_name_selected_color = beautiful.fg_normal,
    app_show_generic_name = true               ,                       -- Should show generic app name?
}
local app_launcher = bling.widget.app_launcher(app_launcher_config)
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
--Lain
local lain          = require("lain")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--


-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "lvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
local altkey      = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
     awful.layout.suit.tile,
     awful.layout.suit.floating,
     awful.layout.suit.tile.left,
     awful.layout.suit.tile.bottom,
     awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
     awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
     --lain.layout.cascade,
     --lain.layout.cascade.tile,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
local separators = lain.util.separators
local separator = separators.arrow_left
--local new_shape = function(cr, width, height)
--    gears.shape.rounded_rect(cr, width, height, 2)
--end
--wibox.widget {
--    widget = wibox.widget.separator{
--	    shape=new_shape
--    }
--}

-- Create a textclock widget
mytextclock = wibox.widget.textclock('%_H:%M')
local cw = calendar_widget({
    placement = 'top_right',
    start_sunday = true,
    radius = 8,
-- with customized next/previous (see table above)
    previous_month_button = 1,
    next_month_button = 3,
})
mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    --awful.tag({ "(=^ ◡ ^=)", " ૮ – ﻌ–ა ", "   𐐘 ඞ  ", "ଲ(ⓛ ω ⓛ)ଲ", "(´｡• ω •｡`)" }, s, awful.layout.layouts[1])
      awful.tag({ "₍ᐢ.  ̫.ᐢ₎", "૮ – ﻌ–ა", " 𐐘 ඞ  ", "ʕ´•ᴥ•`ʔ", "(`皿´＃)"," ˚ʚ♡ɞ˚ "," ૮꒰ ˶• ༝ •˶꒱ა ♡ ", " ૮₍ ˃ ⤙ ˂ ₎ა", "༺♡༻" }, s, awful.layout.layouts[1])
    -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    s.mywibox = awful.wibar({screen = s,height=21,shape= gears.shape.rounded_rect,position="top",ontop=false })    
local systray=wibox.widget.systray()
systray:set_base_size(20)
  --
    -- Add widgets to the wibox
  if battery_exists then 
  local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
        github_contributions_widget({username = 'senchpimy',days=30,theme='pink',with_border=false}),
		 --wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 5, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(systray,10, 5), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 0, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(volume_widget(), 4, 8), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_normal), 0, 0), beautiful.bg_separator),
		 todo_widget(),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 0, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(
            ram({
                    widget_height=30,
                    widget_width=30,
                }), 4, 8), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_normal), 0, 0), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(mytextclock, 4, 8), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 0, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(
	            batteryarc_widget({
	            show_current_level = true,
	            arc_thickness = 3,
	            size=30,
	            show_notification_mode='on_click'
	        }), 4, 8), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_normal), 4, 0), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(s.mylayoutbox, 10, 8), beautiful.fg_color),
        },
    }
  else 
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
        github_contributions_widget({username = 'senchpimy',days=30,theme='pink',with_border=false}),
		 --wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 5, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(systray,10, 5), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 0, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(volume_widget(), 4, 8), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_normal), 0, 0), beautiful.bg_separator),
		 todo_widget(),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_separator), 0, 0), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(
            ram({
                    widget_height=30,
                    widget_width=30,
                }), 4, 8), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(separator("alpha",beautiful.bg_normal), 0, 0), beautiful.bg_separator),
		 wibox.container.background(wibox.container.margin(mytextclock, 4, 8), beautiful.bg_normal),
		 wibox.container.background(wibox.container.margin(s.mylayoutbox, 10, 8), beautiful.fg_color),
        },
    }
  end
end
)
-- }}}

pomowibox = awful.wibox({ position = "top", screen = 1, height=4})
pomowibox.visible = false
local pomodoro = awmodoro.new({
	minutes 			= 15,
	do_notify 			= true,
	active_bg_color 	= '#313131',
	paused_bg_color 	= '#7746D7',
	fg_color			= {type = "linear", from = {0,0}, to = {pomowibox.width, 0}, stops = {{0, "#AECF96"},{0.5, "#88A175"},{1, "#FF5656"}}},
	width 				= pomowibox.width,
	height 				= pomowibox.height, 

	begin_callback = function()
		pomowibox.visible = true
	end,

	finish_callback = function()
		pomowibox.visible = false
	end})
pomowibox:set_widget(pomodoro)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- Dynamic tagging
    awful.key({ modkey, altkey }, "n", function () lain.util.add_tag() end,
        {description = "add new tag", group = "tag"}),
    awful.key({ modkey, altkey}, "r", function () lain.util.rename_tag() end,
        {description = "rename tag", group = "tag"}),
    awful.key({ modkey, altkey }, "j", function () lain.util.move_tag(-1) end,
        {description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, altkey }, "k", function () lain.util.move_tag(1) end,
        {description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, altkey }, "d", function () lain.util.delete_tag() end,
        {description = "delete tag", group = "tag"}),

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    awful.key({ modkey }, "+", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey   }, "b", function () 
               -- awful.spawn.with_shell( "slock")    
              lock_screen_show()
               end,
              {description = "block screen", group = "client"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey,altkey },            "u",     function () awful.screen.focused().mypromptbox:run() end,
            {description = "run prompt", group = "launcher"}),
    awful.key({ modkey },            "r",     function () 
       app_launcher:toggle()
  end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey, "Control" },            "p",     function () awful.util.spawn('sh /home/plof/.config/rofi/applets/applets/powermenu.sh') end,
              {description = "Power Menu", group = "System Control"}),

    awful.key({ modkey },            "v",     function () awful.util.spawn('sh /home/plof/.config/rofi/applets/applets/volume.sh') end,
              {description = "Volume Menu", group = "System Control"}),

    awful.key({ modkey },            "-",     function () awful.util.spawn('sh /home/plof/.config/rofi/applets/applets/mpd.sh') end,
              {description = "Media PLayer Menu", group = "System Control"}),

awful.key({	modkey			}, "c", function () pomodoro:toggle() end),

awful.key({	modkey, "Shift"	}, "c", function () pomodoro:finish() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

--Power


clientkeys = gears.table.join(

    -- Brightness
    awful.key({ }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end,
              {description = "+10%", group = "System Control"}),
    awful.key({ }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end,
              {description = "-10%", group = "System Control"}),
    -- Non-empty tag browsing
    awful.key({ modkey,"Shift" }, "o", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ modkey,"Shift" }, "p", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  next nonempty", group = "tag"}),
	      --screenshots
    awful.key({ modkey }, "Print", function () awful.util.spawn("scrot 'Screenshot-%Y-%m-%d-%s.jpg' -e 'mv $f "..usr_home.."/Pictures/$f'") end,
        {description = "Scrot", group = "System Control"}),
    awful.key({ modkey, "Shift"   }, "Left",   function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Right",  function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),    
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, 	}, ".", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false}
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--test
beautiful.notification_opacity = '100'
beautiful.notification_icon_size = 80
beautiful.notification_bg = '#ffffff'
beautiful.notification_fg = '#000000'

--awful.spawn.with_shell('wal -R')
awful.spawn.with_shell('flameshot')
awful.spawn.with_shell('mpd')
