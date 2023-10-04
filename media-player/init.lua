local awful       = require("awful")
local beautiful   = require("beautiful")
local helpers     = require("lain.helpers")
local watch = require("awful.widget.watch")
local wibox       = require("wibox")
local gears = require("gears")

function capture(cmd)
   local f = assert(io.popen(cmd, 'r'))
   local s = assert(f:read('*a'))
   f:close()
   return s
end

local status = function() return capture("playerctl status") end
local play_icon = os.getenv('HOME')..'/.config/awesome/media-player/play.svg'
local pause_icon = os.getenv('HOME')..'/.config/awesome/media-player/pause.svg'
local prev_icon = os.getenv('HOME')..'/.config/awesome/media-player/prev.svg'
local next_icon = os.getenv('HOME')..'/.config/awesome/media-player/next.svg'
local art = function() 
  local str= capture("playerctl metadata --format '{{mpris:artUrl}}'") 
  str = string.sub(str,8,-2)
  return str
end

local placement = 'top'
 local function rounded_shape(size)
        return function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, size)
        end
    end

local MediaPlayer = {
   artist="",
   title=""
}

local button_size = 30

local prev_button = wibox.widget{
  id="prev",
  image=prev_icon,
  forced_height=button_size,
  forced_width=button_size,
  widget = wibox.widget.imagebox
}

local space = wibox.widget{
  text="",
  forced_width=button_size*3,
  widget = wibox.widget.textbox
}

prev_button:buttons{
  awful.util.table.join(
    awful.button(
    {}, 1,
    function()
      awful.spawn.easy_async("playerctl previous",function ()	end)
    end
    )
  )
}

local next_button = wibox.widget{
  id="next",
  image=next_icon,
  forced_height=button_size,
  forced_width=button_size,
  widget = wibox.widget.imagebox
}

next_button:buttons{
  awful.util.table.join(
    awful.button(
    {}, 1, 
    function()
      awful.spawn.easy_async("playerctl next",function ()	end) 
    end
    )
  )
}

MediaPlayer.popup_widget = wibox.widget {
  {
    {
    id="art",
   image=art(),
   forced_height=200,
   forced_width=200,
   widget=wibox.widget.imagebox
    },
    {
      prev_button,
      space,
      next_button,
      layout = wibox.layout.align.horizontal
    },
  layout = wibox.layout.align.vertical
  },
   widget = wibox.container.background,
   update_art = function (self,str)
    self:get_children_by_id("art")[1]:set_image(str)
   end,
}

MediaPlayer.popup= awful.popup {
        ontop = true,
        visible = false,
        shape = rounded_shape(4),
        border_width = 1,
        border_color = "#FF00FF",
        widget = MediaPlayer.popup_widget,
        --placement    = awful.placement.top_left(),
        placement    = awful.placement.centered,
}

MediaPlayer.widget = wibox.widget {
   {
      {
         id="icon",
         image=play_icon,
         resize=true,
         widget = wibox.widget.imagebox
      },
      {
         id="artist",
         text = MediaPlayer.artist,
         widget = wibox.widget.textbox
      },
      {
         id="title",
         text = MediaPlayer.title,
         widget = wibox.widget.textbox
      },
      layout = wibox.layout.align.horizontal
   },
   widget = wibox.container.background,
   update_artist = function (self,str)
   self:get_children_by_id("artist")[1]:set_text(str)
   end,
   update_title = function (self,str)
   self:get_children_by_id("title")[1]:set_text(str)
   end,
   update_svg = function (self,str)
    if (str=="Playing") then
      self:get_children_by_id("icon")[1]:set_image(play_icon)
    else
      self:get_children_by_id("icon")[1]:set_image(pause_icon)
    end
   end
}
local update_widget_artist = function(widget, stdout, _, _, _)
MediaPlayer.artist=stdout
widget:update_artist(stdout)
end
local update_widget_title = function(widget, stdout, _, _, _)
  MediaPlayer.title=stdout
widget:update_title(stdout)
end
local update_popup_art = function(widget, stdout, _, _, _)
  widget:update_art(art())
end

watch("playerctl metadata --format '{{artist}}-'", 1, update_widget_artist, MediaPlayer.widget)
watch("playerctl metadata --format '{{title}}'", 1, update_widget_title, MediaPlayer.widget)
watch("playerctl metadata --format '{{mpris:artUrl}}'", 1, update_popup_art, MediaPlayer.popup_widget)
  --local str= capture("playerctl metadata --format '{{mpris:artUrl}}'") 

MediaPlayer.widget:buttons(
  awful.util.table.join(
    awful.button(
    {}, 1, -- button 1: left click  - play/pause
    function()
      awful.spawn.easy_async("playerctl play-pause",function ()	end) --Change icon
      MediaPlayer.widget:update_svg(status())
    end
    ),
    awful.button(
    {}, 3, -- button 3: Rigth click Spawn player
    function()
      MediaPlayer.popup.visible=not MediaPlayer.popup.visible
    end
    )
  )
)

return MediaPlayer

