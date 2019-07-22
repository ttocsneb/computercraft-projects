-- Reactor Program
-- Config

target_battery = 5000000  -- Target battery usage

reactor_side = nil  -- The name/side of the reactor, if nil, it will try to 
--find it automanually
monitor_side = nil  -- The name/side fo the monitor, not necessary for operation

update_time = 0.2   -- The time in seconds between each update (smaller number
--is more accurate, but uses more processes)
display_update_time = 1

-- Advanced Config

-- Power PID controller constants
pkp = 1  -- Controls the main portion of the error
pki = 0  -- Helps control constant errors
pkd = 0  -- Helps control spikes in errors
power_target = 100

-- Battery PID controller
bkp = 1
bki = 0
bkd = 0

-- End Config

local display_on_loop = math.ceil(display_update_time / update_time)


os.loadAPI("reactor/pid")
os.loadAPI("reactor/monitor")

-- Setup monitor
monitor.connect(monitor_side)
monitor.clear()
monitor.setCursorPos(1, 1)

if monitor.connected() then
  monitor.write("Monitor Connected")
else
  monitor.write("No Monitor Found")
end

sleep(2)

os.loadAPI("reactor/display")

-- Setup reactor
local function connect(side)
  side = side or ''
  if peripheral.isPresent(side) and peripheral.getType(side) == 'BigReactors-Reactor' then
    return peripheral.wrap(side)
  else
    return peripheral.find('BigReactors-Reactor')
  end
end
local reactor = connect(reactor_side)
if reactor == nil then
  monitor.write("Unable to locate reactor!")
  return
end

-- Setup PID Objects
local power_pid = pid.PID:new({p=pkp, i=pki, d=pkd, max_i=100})
local batt_pid = pid.PID:new({p=bkp, i=bki, d=bkd, max_i=100})

local last_energy = reactor.getEnergyStored()
local loop_num = display_on_loop
while true do
  loop_num = loop_num + 1

  local energy = reactor.getEnergyStored()
  
  batt_pid:update((target_battery - energy) / 1000000, update_time)
  power_pid:update(100 - batt_pid:get(), update_time)

  local rod_perc = math.max(math.min(math.floor(50.5 + power_pid:get()), 100), 0)
  reactor.setAllControlRodLevels(100 + rod_perc)

  if loop_num >= display_on_loop then
    local delta_energy = (energy - last_energy) / update_time
    display.update(reactor, delta_energy)
    loop_num = 0
  end
  last_energy = energy
  sleep(update_time)
end