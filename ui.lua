Element = {}

function Element:new(x, y, tex, w, h)
	local fields = {x=x,y=y,w=w or (tex ~= nil and tex:getWidth() or nil),h=h or tex ~= nil and tex:getHeight() or nil,tex=tex,children={},inside=false,enabled=true}
	self.__index = self
	return setmetatable(fields, self)
end

function Element:update(dt)
	if not self.enabled then return end
	local mx,my = love.mouse.getPosition()
	if  mx < self.x + self.w and mx > self.x and my < self.y + self.h and my > self.y then
		if not self.inside then
			self:enter()
			self.inside = true
		end
	else
		if self.inside then
			self.inside = false
			self:exit()
		end
	end
end

function Element:draw()
	--print(self.enabled)
	if not self.enabled then return end
	if self.tex then
		love.graphics.draw(self.tex,self.x,self.y)
	end
end

function Element:enter()
	--print("enter")
end

function Element:exit()
	--print("exit")
end

function Element:clicked(x,y,b)
	if x > self.x and x < self.x+self.w and y > self.y and y < self.y+self.h then
		return true
	end
	return false
end

function Element:unclicked(x,y,b)
	if x > self.x and x < self.x+self.w and y > self.y and y < self.y+self.h then
		return true
	end
	return false
end

function Element:key(k)

end

function Element:enable()
	self.enabled = true
	for i=1,#self.children do
		self.children[i]:enable()
	end
end

function Element:disable()
	self.enabled = false
	for i=1,#self.children do
		self.children[i]:disable()
	end
end

Button = Element:new()

function Button:new(x, y, tex, callback)
	local fields = Element.new(self, x,y,tex)
	fields.callback=callback
	self.__index = self
	return setmetatable(fields, self)
end

function Button:clicked(x,y,b) --b = mouse button
	if Element.clicked(self,x,y,b) then
		self.callback(b,self)
		return true
	end
	return false
end

function Button:draw()
	if self.inside then
		love.graphics.setColor(0.5, 0.5, 0.5)
	else
		love.graphics.setColor(0.7, 0.7, 0.7)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	love.graphics.setColor(1,1,1)
	Element.draw(self)
end

Slider = Element:new()

function Slider:new(label, x, y, min, max, step, default, w, h)
	local fields = Element.new(self, x, y, nil, w or 128, h or 32)
	fields.min = min
	fields.max = max
	fields.step = step
	fields.value = default and (default-min)/(max-min) or 0
	fields.text = label
	return fields
end

function Slider:update(dt)
	if love.mouse.isDown(1) then
		local mx,my = love.mouse.getPosition()
		if Element.clicked(self, mx, my, 1) then
			self.value = (mx - self.x)/self.w
		end
	end
	Element.update(self, dt)
end

function Slider:clicked(x, y, b)
	if Element.clicked(self, x, y, b) then
		if b == 2 then
			self.value = 0
		end
	end
end

function Slider:draw()
	if self.inside then
		love.graphics.setColor(0.3,0.3,0.3)
	else
		love.graphics.setColor(0.2,0.2,0.2)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	love.graphics.setColor(0.5,0.5,0.5)
	love.graphics.rectangle("fill", self.x, self.y, (self:get()-self.min)/(self.max-self.min)*self.w, self.h)
	love.graphics.setColor(1,1,1)
	love.graphics.print({{1,1,1}, self.text.." ("..self:get()..")"}, fontsmall, self.x+4, self.y+4)
end

function Slider:get()
	local value = self.value*(self.max-self.min)+self.min
	return self.step and math.floor(value/self.step + 0.5)*self.step or value
end

function Slider:set(value)
	self.value = (value-self.min)/(self.max-self.min)
end

Label = Element:new()

function Label:new(x, y, text, font, col, wrap, align)
	local txt = love.graphics.newText(font)
	txt:setf({col or {0,0,0}, text}, wrap or love.graphics.getWidth(), align or "left")
	local fields = Element.new(self, x, y, txt, txt:getWidth(), txt:getHeight())
	fields.align = align or "left"
	return fields
end

function Label:setText(text, font, col, wrap)
	self.tex:setf({col or {0,0,0}, text}, wrap or love.graphics.getWidth(), self.align)
	self.w = self.tex:getWidth()
	self.h = self.tex:getHeight()
end

ChaseBox = Element:new()

function ChaseBox:new(x,y,w,h)
	local fields = Element.new(self, x, y, nil, w, h)
	fields.team = 1
	fields.chaser = 0
	return fields
end

function ChaseBox:draw()
	love.graphics.setColor(0,0,1)
	love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
	for i=1,self.team do
		if self.chaser >= i then
			love.graphics.setColor(1,0,0)
			love.graphics.rectangle("fill",self.x+(i-1)*self.w/self.team,self.y,self.w/self.team,self.h)
			love.graphics.setColor(1,1,1)
		end
		love.graphics.rectangle("line",self.x+(i-1)*self.w/self.team,self.y,self.w/self.team,self.h)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print(self.team,self.x+(self.team-1)*self.w/self.team + self.w/self.team/2 - fontbig:getWidth(self.team)/2,self.y + self.h/2 - fontbig:getHeight()/2)
	if self.chaser > 0 then
		love.graphics.print(self.chaser,self.x+(self.chaser-1)*self.w/self.team + self.w/self.team/2 - fontbig:getWidth(self.chaser)/2,self.y + self.h/2 - fontbig:getHeight()/2)
	end
end

function ChaseBox:chaserUp()
	self.chaser = math.min(self.chaser+1,self.team)
end

function ChaseBox:chaserDown()
	self.chaser = math.max(self.chaser-1,0)
end

function ChaseBox:teamUp()
	self.team = self.team + 1
end

function ChaseBox:teamDown()
	self.team = math.max(self.team-1,1)
	self.chaser = math.min(self.team,self.chaser)
end
