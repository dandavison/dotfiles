-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890
hs.hotkey.bind({"cmd"}, "/", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

hs.hotkey.bind({"ctrl"}, "v", function()
  local alacritty = hs.application.find('alacritty')
  if not alacritty:isFrontmost() then
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
  -- Send key stroke 'v' followed by Enter to current application
  hs.eventtap.keyStroke({}, "v", alacritty)
  hs.eventtap.keyStroke({}, "return", alacritty)
end)
