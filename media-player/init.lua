local awful       = require("awful")
local beautiful   = require("beautiful")
local helpers     = require("lain.helpers")
local watch = require("awful.widget.watch")
local wibox       = require("wibox")

function capture(cmd)
   local f = assert(io.popen(cmd, 'r'))
   local s = assert(f:read('*a'))
   f:close()
   return s
end

local art = function() return capture("playerctl metadata --format '{{mpris:artUrl}}'") end
local status = function() return capture("playerctl status") end
local play_icon = os.getenv('HOME')..'/.config/awesome/media-player/play.svg'
local pause_icon = os.getenv('HOME')..'/.config/awesome/media-player/pause.svg'

local MediaPlayerArt=wibox.widget{
   image = "",
   resize = true,
   widget = wibox.widget.imagebox,
}

local MediaPlayer = {
   artist="",
   title=""
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
widget:update_artist(stdout)
end
local update_widget_title = function(widget, stdout, _, _, _)
widget:update_title(stdout)
end

watch("playerctl metadata --format '{{artist}}-'", 1, update_widget_artist, MediaPlayer.widget)
watch("playerctl metadata --format '{{title}}'", 1, update_widget_title, MediaPlayer.widget)

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
    end
    )
  )
)

return MediaPlayer

