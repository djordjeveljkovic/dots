-- ~/.config/swayimg/init.lua

-- ============================================================
-- Viewer: Vim-style navigation
-- ============================================================

-- h = pan left
swayimg.viewer.on_key("h", function()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x + 50, pos.y)
end)

-- l = pan right
swayimg.viewer.on_key("l", function()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x - 50, pos.y)
end)

-- k = pan up
swayimg.viewer.on_key("k", function()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x, pos.y + 50)
end)

-- j = pan down
swayimg.viewer.on_key("j", function()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x, pos.y - 50)
end)


-- ============================================================
-- Rotation
-- ============================================================

-- r = rotate clockwise 90°
swayimg.viewer.on_key("r", function()
  swayimg.viewer.rotate(90)
end)

-- R = rotate counter-clockwise 90°
swayimg.viewer.on_key("Shift+r", function()
  swayimg.viewer.rotate(270)
end)


-- ============================================================
-- Gallery: Vim-style navigation
-- ============================================================

swayimg.gallery.on_key("h", function()
  swayimg.gallery.select("left")
end)

swayimg.gallery.on_key("j", function()
  swayimg.gallery.select("down")
end)

swayimg.gallery.on_key("k", function()
  swayimg.gallery.select("up")
end)

swayimg.gallery.on_key("l", function()
  swayimg.gallery.select("right")
end)

-- q = quit
swayimg.viewer.on_key("q", function()
  swayimg.exit()
end)

swayimg.gallery.on_key("q", function()
  swayimg.exit()
end)


-- 0 = reset zoom and position
swayimg.viewer.on_key("0", function()
  swayimg.viewer.reset()
end)


-- n / p = next / previous image
swayimg.viewer.on_key("n", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("p", function()
  swayimg.viewer.open("prev")
end)

-- Shift+j = next image
swayimg.viewer.on_key("Shift+j", function()
  swayimg.viewer.open("next")
end)

-- Shift+k = previous image
swayimg.viewer.on_key("Shift+k", function()
  swayimg.viewer.open("prev")
end)
