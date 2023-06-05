-- -- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890
-- hs.hotkey.bind({"cmd"}, "'", function()
--   local alacritty = hs.application.find('alacritty')
--   if alacritty:isFrontmost() then
--     alacritty:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Alacritty.release.app")
--   end
-- end)

hs.hotkey.bind({"cmd"}, ";", function()
    local warp = hs.application.find('warp')
    if warp:isFrontmost() then
      warp:hide()
    else
      hs.application.launchOrFocus("/Applications/Warp.app")
    end
end)
  
-- hs.hotkey.bind({"ctrl"}, " ", function()
--   local alacritty = hs.application.find('alacritty')
--   if not alacritty:isFrontmost() then
--     hs.application.launchOrFocus("/Applications/Alacritty.release.app")
--     hs.eventtap.keyStroke({}, "v", alacritty)
--   else
--     hs.eventtap.keyStroke({"ctrl"}, " ", alacritty)
--   end
--   hs.eventtap.keyStroke({}, "return", alacritty)
-- end)
