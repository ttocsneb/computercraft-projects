-- PID is setup like the math function:
-- e*p + int(e*i)de + d/de(e*d)
-- where e is the error, and t is time

-- _el and _is are private variables which stand for
-- e last, and i sum respectively
PID = {p=1, i=0, d=0, max_i=50, _el=0, _is=0, _out=0}

-- Create a new PID object
function PID:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Update the PID loop
function PID:update(err, delta)
  local prop = err * self.p
  local deri = ((err - self._el) * self.d) * delta
  self._is = math.max(math.min(self._is + (err * self.i * delta), self.max_i), -self.max_i)

  self._el = err
  self._out = prop + deri + self._is
  return self._out
end

function PID:get()
  return self._out
end

-- reset the variables of the pid loop
function PID:reset()
  self._el = 0
  self._is = 0
end

