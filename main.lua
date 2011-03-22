require 'gamelogic'


function love.load()
    -- GL - Model of Game
    gl = Gamelogic:new({9,9},6,4)
    gl:genBalls()
    love.graphics.setBackgroundColor(200, 200, 200)
end



local drawscreen = function()
--                 Желтый ,    Голубой ,    Синий ,      Зеленый ,    Оранжевый ,   Розовый ,      Красный
	typeColors = { {255,255,0},{0,255,255},{0,51,255},{51,255,51},{255,153,0},{255,51,102},{255,0,0}}
	for i=1,gl.xCount do
		for j=1,gl.yCount do
			love.graphics.setColor(160, 160, 160, 255)
			love.graphics.rectangle("fill", 53.5*j, 30*i, 51, 28 )
			_typeBalls =gl:getGameTable()[i][j]
			if _typeBalls ~= 0 and _typeBalls <= 7 then
				love.graphics.setColor(typeColors[_typeBalls][1],typeColors[_typeBalls][2],typeColors[_typeBalls][3], 255)
				love.graphics.circle("fill", 53.5*j+27, 30*i+15, 12)
			end
		end
	end
end

function love.mousepressed( x, y, button )
	if love.mouse.isDown("l") then
		local x, y = love.mouse.getPosition( )
		x = math.floor(x / 53.5)
		y = math.floor(y / 30)
		gl:onClickTable(x,y)
		drawscreen()
    end
end

function love.draw()
    love.graphics.setColor(255, 40, 40, 100)
    love.graphics.print('Lines ALPHA VER: 0.01', 10, 10)
    love.graphics.setColor(40, 40, 40, 100)
    drawscreen()
end
