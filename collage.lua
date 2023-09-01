local collage = require("eyecandy.collage")
local fhelpers = require("eyecandy.helpers")

local imgbox = nil

return {
    show = function()
        if imgbox == nil then
            --local notifpath = os.getenv("HOME").."/Pictures/wallpapers/public-wallpapers/portrait/"
            --local notifpath = os.getenv("HOME")
            local notifpath = "/home/plof/Pictures/"
            local _, imgsources = fhelpers.getImgsFromDir(notifpath)
            imgbox = collage.placeCollageImage(300, 200,
              400, 200, "bottom-right", imgsources, 2, false)
        else
            imgbox.shadow.visible = true
            imgbox.image.visible = true
            imgbox.shadow:get_children_by_id("shadow")[1].visible = true
            imgbox.image:get_children_by_id("img")[1].visible = true
        end
    end,

    hide = function ()
        if imgbox then
            imgbox.image.visible = false
            imgbox.shadow.visible = false
            imgbox.image:get_children_by_id("img")[1].visible = false
            imgbox.shadow:get_children_by_id("shadow")[1].visible = false
        end
    end
}
