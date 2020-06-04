require "util"
require "ui"

function love.load()
	fontsmall = love.graphics.newFont("font.ttf",16)
	fontnormal = love.graphics.newFont("font.ttf",32)
	fontbig = love.graphics.newFont("font.ttf",64)
	logo = love.graphics.newImage("42a.png")
	if not love.filesystem.getInfo("questions.txt") then
		love.filesystem.write("questions.txt","Put questions in here.")
	end
	qstr = love.filesystem.read("questions.txt")
	questions = {}
	for s in qstr:gmatch("[^\r\n]+") do
	    table.insert(questions, s)
	end
	print(questions[1])
	love.graphics.setFont(fontbig)
	chasebox = ChaseBox:new(love.graphics.getWidth()/2-1000/2,love.graphics.getHeight()/2-200/2,1000,200)
	timer = Label:new(love.graphics.getWidth()/2-fontnormal:getWidth("2:00")/2,logo:getHeight()+fontbig:getHeight(),"2:00",fontnormal,{1,1,1})
	ticking = false
	t = 120 --replace with default time
	question = 0
	questionbox = Label:new(0,chasebox.y+chasebox.h+10,"",fontnormal,{1,1,1},love.graphics.getWidth(),"center")
	love.resize(love.graphics.getWidth(),love.graphics.getHeight())
end

function love.resize(w,h)
	chasebox.x,chasebox.y=love.graphics.getWidth()/2-1000/2,love.graphics.getHeight()/2-200/2
	timer.x,timer.y=love.graphics.getWidth()/2-fontnormal:getWidth("2:00")/2,logo:getHeight()+fontbig:getHeight()
	questionbox:setText(questions[question], fontnormal, {1,1,1})
	questionbox.x,questionbox.y=0,chasebox.y+chasebox.h+10
	local h = questionbox.y+questionbox.h+fontnormal:getHeight()*2
	elements = {
				Slider:new("Time Limit", 32, 32, 10, 60*5, 10, 120, 256, 32),
				Element:new(love.graphics.getWidth()/2-logo:getWidth()/2,0,logo,logo:getWidth(),logo:getHeight()),
				Label:new(love.graphics.getWidth()/2-fontbig:getWidth("The Chase")/2,logo:getHeight(),"The Chase",fontbig,{1,1,1}),
				timer,
				Button:new(love.graphics.getWidth()/2-fontnormal:getWidth("2:00")/2-fontsmall:getWidth("Reset Clock")-10,logo:getHeight()+fontbig:getHeight()+fontnormal:getHeight()/2-fontsmall:getHeight()/2,love.graphics.newText(fontsmall,"Reset Clock"), function (b,button) t = elements[1]:get() ticking = false end),
				chasebox,
				questionbox,
				Label:new(love.graphics.getWidth()/2-fontbig:getWidth("Start/Stop Clock")/2-50-fontsmall:getWidth("Chaser")/2,h,"Chaser",fontsmall,{1,0,0}),
				Button:new(love.graphics.getWidth()/2-fontbig:getWidth("Start/Stop Clock")/2-50-fontnormal:getWidth("<")-1,h+20,love.graphics.newText(fontnormal,{{1,0,0},"<"}), function (b,button) chasebox:chaserDown() end),
				Button:new(love.graphics.getWidth()/2-fontbig:getWidth("Start/Stop Clock")/2-50+1,h+20,love.graphics.newText(fontnormal,{{1,0,0},">"}), function (b,button) chasebox:chaserUp() end),
				Label:new(love.graphics.getWidth()/2+fontbig:getWidth("Start/Stop Clock")/2+50-fontsmall:getWidth("Team")/2,h,"Team",fontsmall,{0,0,1}),
				Button:new(love.graphics.getWidth()/2+fontbig:getWidth("Start/Stop Clock")/2+50-fontnormal:getWidth("<")-1,h+20,love.graphics.newText(fontnormal,{{0,0,1},"<"}), function (b,button) chasebox:teamDown() end),
				Button:new(love.graphics.getWidth()/2+fontbig:getWidth("Start/Stop Clock")/2+50+1,h+20,love.graphics.newText(fontnormal,{{0,0,1},">"}), function (b,button) chasebox:teamUp() end),
			   	Button:new(love.graphics.getWidth()/2-fontbig:getWidth("Start/Stop Clock")/2,h+20 + fontnormal:getHeight()/2 - fontbig:getHeight()/2,love.graphics.newText(fontbig,"Start/Stop Clock"), function (b,button) ticking = not ticking end)
			   }
end

function love.keypressed(k)
	for i=1,#elements do
		elements[i]:key(k)
	end
	if k == "space" then
		question = ((question + 1) % #questions) + 1
		questionbox:setText(questions[question], fontnormal, {1,1,1})
	end
end

function love.mousepressed(x, y, button)
	for i=1,#elements do
		if elements[i]:clicked(x,y,button) then
			return
		end
	end
end

function love.mousereleased(x, y, button)
	for i=1,#elements do
		if elements[i]:unclicked(x,y,button) then
			return
		end
	end
end

function love.update(dt)
	if ticking then
		t = math.max(0, t - dt)
	end
	--time = time + dt
	local min = math.floor(t/60)
	local sec = math.floor(t % 60)
	timer:setText(min..":"..((sec < 10) and "0"..sec or sec), fontnormal,{1,1,1})
    for i=1,#elements do
    	elements[i]:update(dt)
    end
end

function love.draw()
	if chasebox.team <= chasebox.chaser then
		love.graphics.clear(1,0,0,1)
	else
		love.graphics.clear(0,0,0,1)
	end
    for i=1,#elements do
    	elements[i]:draw()
    end
end