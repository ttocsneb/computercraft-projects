-- print to console and screen

local _monitor = nil

local function connect(side)
  if periphera.getType(side) == 'monitor' then
    _monitor = peripheral.wrap(side)
  else
    _monitor = peripheral.find(t)
  end
end

-- Call a function to both the monitor and terminal
local function call(method, ...) 
  if _monitor then
    _monitor[method](unpack(arg))
  end
  term[method](unpack(arg))
end

-- Call a color based function to both the monitor and terminal
local function call_color(method, ...)
  if _monitor and _monitor.isColor() then
    _monitor[method](arg)
  end
  if term.isColor() then
    term[method](arg)
  end
end

function write(text)
  call("write", text)
end

-- Blit to the monitor and terminal.  If one is black and white, then the
-- colors will be converted.  Note that if one is black and white, and
-- the other is color, the color screen will still display color, while
-- the black and white will be converted to black and white
function blit(text, text_colors, background_colors)

  -- Convert a color text to black and white text
  local to_black_and_white = function(color)
    new_color = ""
    for c in string.gmatch(color, '.') do
      if string.match("78f", c) then
        new_color = new_color .. '0'
      else
        new_color = new_color .. 'f'
      end
    end
    return new_color
  end
  
  -- If either screen is black and white, convert to black and white
  if (_monitor and not _monitor.isColor()) or not term.isColor() then
    black_color = to_black_and_white(text_colors)
    black_back = to_black_and_white(background_colors)
  end
  
  -- blit to the monitor
  if _monitor then
    if _monitor.isColor() then
      _monitor.blit(text, text_colors, background_colors)
    else
      _monitor.blit(text, black_color, black_back)
    end
  end
  
  -- blit to the terminal
  if term.isColor() then
    term.blit(text, text_colors, background_colors)
  else
    term.blit(text, black_color, black_back)
  end
end

-- show some text with a text color and background color
function show(text, color, back_color)
  local is_colored = function(color)
    return color ~= colors.white and color ~= colors.black
  end
  local colored = (color ~= nil and is_colored(color)) or (back_color ~= nil and is_colored(back_color))
  local color_call = call_color if colored else call
  
  if color then
    color_call("setTextColor", color)
  end
  if back_color then
    color_call("setBackgroundColor", back_color)
  end
  
  call("write", text)
end

function clear()
  call("clear")
end

function clearLine()
  call("clearLine")
end

function getCursorPos()
  return term.getCursorPos()
end

function setCursorPos(x, y)
  call("setCursorPos", x, y)
end

function setCursorBlink(bool)
  call("setCursorBlink", bool)
end

function isColor()
  if _monitor then
    color = _monitor.isColor()
  end
  return color or term.isColor()
end

function getSize()
  if _monitor then
    x, y = _monitor.getSize()
  end
  x2, y2 = term.getSize()
  return math.min(x, x2), math.min(y, y2)
end

function scroll(n)
  call("scroll", n)
end

function setTextColor(color)
  if color == colors.white or color == colors.black then
    call("setTextColor", color)
  else
    call_color("setTextColor", color)
  end
end

function setBackgroundColor(color)
  if color == colors.white or color == colors.black then
    call("setBackgroundColor", color)
  else
    call_color("setBackgroundColor", color)
  end
end

function setTextScale(scale)
  if _monitor then
    _monitor.setTextScale(scale)
  end
end
