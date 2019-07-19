-- reactor display
--Active: yes/no      Power: XMRF
--Control Rod: xx%    Prod: XRF/t
--                    Used: XRF/t
--Core Temp: xC    Frame Temp: xC
--Fuel: xb              waste: xb
--■■■■■■■■■■■■■■■■■■■■■■■ ■■■■■■■

os.loadAPI("monitor")
local width, local height = monitor.getSize()

if height < 6 then
  monitor.write("Warning: Monitor not tall enough for this program")
  sleep(2.5)
end

local function put_left(text, current_text)
  return text .. string.sub(current_text, text.len() + 1)
end

local function put_right(text, current_text)
  return string.sub(current_text, 1, -(text.len() + 1)) .. text
end

local function get_line(c)
  c = c or ' '
  return string.rep(c, width)
end

local function get_notation(level)
  if level == -1 then
    return 'm'
  elseif level == 0 then
    return ''
  elseif level == 1 then
    return 'k'
  elseif level == 2 then
    return 'M'
  end
end

local function get_base(num)
  return math.floor(math.log(math.abs(num)) / math.log(1000))
end

local function round(num, place)
  place = place or 1
  return math.floor(math.exp(10, place) * num + 0.5) / math.exp(10, place)
end

local function notate(number, base)
  if number < 1000 then
    return round(number), get_notation(base)
  elseif number < 1000000 then
    return round(number / 1000, 2), get_notation(base + 1)
  else
    return round(number / 1000000, 2), get_notation(base + 2)
  end
end

local function color_text(text, color)
  string.rep(color, tostring(text).len())
end

function update(reactor, delta_energy)
  local active = reactor.getActive()
  local storage = reactor.getEnergyStored()
  local produce = reactor.getEnergyProducedLastTick()
  local used = produce - delta_energy / 20
  local control_rod = reactor.getControlRodLevel(1)
  local core_temp = reactor.getFuelTemperature()
  local case_temp = reactor.getCasingTemperature()
  local fuel = reactor.getFuelAmount()
  local waste = reactor.getWasteAmount()
  local max_fuel = reactor.getFuelAmountMax()
  
  local line = get_line()
  local color_line = get_line('0')
  
  -- Active
  put_left("Active " .. "yes" if active else "no", line)
  put_left("0000000" .. "555" if active else "11", color_line)
  -- Power
  local num, no = notate(storage)
  put_right("Power " .. num .. no .. "RF", line)
  put_right(color_text(num, '3') .. '0' if no ~= '' else '' .. '00', color_line)

  monitor.setCursorPos(1, 1)
  monitor.blit(line, color_line)
  
  line = get_line()
  color_line = get_line('0')
  -- Control Rod
  put_left("Rod " .. control_rod .. '%', line)
  put_left("0000" .. color_text(control_rod), color_line)
  
  -- Production
  num, no = notate(produce)
  put_right("Prod " .. num .. no .. 'RF/t', line)
  put_right(color_text(num) .. '0' if no ~= '' else '' .. '000', color_line)
  
  monitor.setCursorPos(1, 2)
  monitor.blit(line, color_line)
  
  line = get_line()
  color_line = get_line('0')
  -- Usage
  num, no = notate(used)
  put_right("Use " .. num .. no .. 'RF/t', line)
  put_right(color_text(num) .. '0' if no ~= '' else '' .. '000', color_line)
  
  monitor.setCursorPos(1, 3)
  monitor.blit(line, color_line)
  
  line = get_line()
  color_line = get_line('o')
  -- Core Temp
  num, no = notate(core_temp)
  put_left("Core " .. num .. no .. 'C', line)
  put_left("00000" .. color_text(num), color_line)
  
  -- Case Temp
  num, no = notate(case_temp)
  put_right("Frame " .. num .. no .. 'C', line)
  put_right(color_text(num) .. '0' if no ~= '' or '' .. '0', color_line)
  
  monitor.setCursorPos(1, 4)
  monitor.blit(line, color_line)
  
  line = get_line()
  color_line = get_line('0')
  -- Fuel
  num, no = notate(fuel, -1)
  put_left("Fuel " .. num .. no .. 'B', line)
  put_left("00000" .. color_text(num), color_line)
  
  -- Waste
  num, no = notate(fuel)
  put_right("Waste " .. num .. no .. 'B', line)
  put_right(color_text(num) .. '0' if no ~= '' or '' .. '0', color_line)
  
  monitor.setCursorPos(1, 5)
  monitor.blit(line, color_line)
  
  -- Fuel - Wast bar
  
  line = get_line()
  local back_color_line = get_line('7')
  local color_line = get_line('a')
  
  fuel_width = fuel / max_fuel * width
  waste_width = waste / max_fuel * width
  
  put_left(string.rep('5', fuel_width), back_color_line)
  put_right(string.rep('#', waste_width), line)
  
  monitor.setCursorPos(1, 6)
  monitor.blit(line, color_line, back_color_line)
  
  
end
