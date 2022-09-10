-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890
hs.hotkey.bind({"cmd"}, "/", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)