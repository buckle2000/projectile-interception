vec = require("vector")
class = require("class")

--- Calculate launch angle of interception object
-- @param T target position (vector)
-- @param Vt target velocity (vector)
-- @param L launch position (vector)
-- @param Vl launch speed (scalar)
-- @return angle of launch
-- @return time to interception (`nan` means never)
function intercept_angle(T, Vt, L, Vl)
	local ds = L - T  -- delta position
	local phi = ds:angleTo()
	local theta = phi + math.asin(( Vt.x*ds.y - Vt.y*ds.x ) / Vl / ds:len())
	local time = ds:len() / (Vt - vec.polar(Vl, theta)):len()
	return theta, time
	-- return phi
end

obj = class()

function obj:init(px, py, vx, vy)
	self.pos = vec(px, py)
	self.v = vec(vx, vy)
end

function obj:update(dt, acc)
	if acc then
		self.v = self.v + acc * dt
	end
	self.pos = self.pos + self.v * dt
end

function obj:draw()
	local x, y = self.pos:unpack()
	love.graphics.circle('line', x, y, 5)
end

function reset()
	paused = false
	o1 = obj(0,100,50,-50)  -- target
	pool = {}  -- object pool
	g = vec(0, 40)  -- gravity
end

reset()

function love.update(dt)
	if not paused then
		if love.mouse.isDown(1) then
			local speed = math.random(250, 450)
			-- local speed = 500
			local x, y = love.mouse.getPosition()
			local o2 = obj(x, y)
			local cos0, time = intercept_angle(o1.pos, o1.v, o2.pos, speed)
			-- if can reach
			if time == time then
				o2.v.x = math.cos(cos0) * -speed
				o2.v.y = math.sin(cos0) * -speed
				table.insert(pool, o2)
			end
		end
		o1:update(dt, g)
		for _,o in ipairs(pool) do  
			o:update(dt, g)
		end
	end
end

function love.draw()
	for _,o in ipairs(pool) do  
		o:draw()
	end
	love.graphics.setColor({255,255,0})
	o1:draw()
	love.graphics.setColor({255,255,255})
	love.graphics.print("R - reset\nP - pause")
end

function love.keypressed(key)
	if key == 'r' then
		reset()
	elseif key == 'p' then
		paused = not paused
	end
end
