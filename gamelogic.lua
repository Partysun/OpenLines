require 'middleclass'
-------------------------------------------------------------------
-- GameLogic - is a main game class , which describe game logic ;)
-- Argument:
--   sides:
--     sides - xCount , yCount - Size of x and y sides of game screen.
--   maxTypes:
--	 	desribe how much types of ball. Standart for classic Lines - 7 types ob ball
--	 addCountBalls:
--		describe how much add balls on the game tabel after each step
-------------------------------------------------------------------
Gamelogic = class('Gamelogic') --this is the same as class('Person', Object) or Object:subclass('Person')

-- Default game screen size in Lines = 9x9
Gamelogic.xCount =  9
Gamelogic.yCount =  9
-- Default ball types = 7
Gamelogic.maxTypes = 7
-- Default Max added Count Balls
Gamelogic.addCountBalls = 3

-- Оснавная таблица всех объектов игрового поля
local _body = {}
-- Вспомогательная таблица для вычисления поиска путей
local _temp = {}

-- Флаг описывающий состояние выделен ли шар или нет
local ballClick = false

-- Метод обнуления и создания таблицы игрового поля
local _initGameTable = function()
	local body = {}
	for i=1,Gamelogic.xCount do
		-- вставляем новую "строку" в двухмерный массив, т.е. заполнение по вертикали
		table.insert(body,{})
		for j=1,Gamelogic.yCount do
			-- заполняем массив по горизонтали
			table.insert(body[i],0)
		end
	end
return (body)
end

-- Gamelogic constructor
function Gamelogic:initialize(sides,maxTypes,addCountBalls)
	self.xCount , self.yCount = sides[1], sides[2]
	if maxTypes<=7 then
		self.maxTypes = maxTypes
	end
	self.addCountBalls = addCountBalls
	_body = _initGameTable()
	_temp = _initGameTable()
	Gamelogic:print()
end

----------------------------------
-- Generator game objects block --
----------------------------------
-- Temp fuction for set new value in any position of game table
function Gamelogic:setNewBall( i, j, typeBall)
	if _body[i][j] == 0 then
		print("Spawn ball: ",i,j,typeBall)
		_body[i][j] = typeBall
		return true
	end
	return false
end

--Generate balls on the game table
-- Max Count of balls = self.addCountBalls
function Gamelogic:genBalls()
	local _count = 0
	repeat
		local x = math.random(1,self.xCount)
		local y = math.random(1,self.yCount)
		local ballType = math.random(1,self.maxTypes)
		if self:setNewBall( x, y, ballType) then
			_count = _count + 1
		end
	until _count == self.addCountBalls
end

function Gamelogic:getGameTable()
	return(_body)
end

function Gamelogic:getPathTable()
	return(_temp)
end

-- Check all lines  for delete
local _deleteBallLine = function()
	print("Check game table...")
	-- Delete line or not
	local isDelLine = false
	-- vertical line check:
	for i=1,7 do
		for j=1,9 do
			if (_body[i][j]==_body[i+1][j]) and (_body[i][j]==_body[i+2][j]) and (_body[i][j]>0) then
				_temp[i][j] = -1
				_temp[i+1][j] = -1
				_temp[i+2][j] = -1
			end
		end
	end
	-- horizontal line check:
	for i=1,9 do
		for j=1,7 do
			if (_body[i][j]==_body[i][j+1]) and (_body[i][j]==_body[i][j+2]) and (_body[i][j]>0) then
				_temp[i][j] = -1
				_temp[i][j+1] = -1
				_temp[i][j+2] = -1
			end
		end
	end
	-- main diagonal line check:
	for i=1,7 do
		for j=1,7 do
			if (_body[i][j]==_body[i+1][j+1]) and (_body[i][j]==_body[i+2][j+2]) and (_body[i][j]>0) then
				_temp[i][j] = -1
				_temp[i+1][j+1] = -1
				_temp[i+2][j+2] = -1
			end
		end
	end

	-- not main diagonal line check:
	for i=1,7 do
		for j=2,9 do
			if (_body[i][j]==_body[i+1][j-1]) and (_body[i][j]==_body[i+2][j-2]) and (_body[i][j]>0) then
				_temp[i][j] = -1
				_temp[i+1][j-1] = -1
				_temp[i+2][j-2] = -1
			end
		end
	end



	for i=1,9 do
		for j=1,9 do
			if _temp[i][j] == -1 then
				_body[i][j] = 0
				_temp[i][j] = 0
				isDelLine = true
				print("Delete ball")
			end
		end
	end
	return (isDelLine)
end

-- Move Ball
function Gamelogic:moveBall(xPosBall,yPosBall,xTarget,yTarget)
		--MOVE BALL
		print("Move ball")
		_body[xTarget][yTarget] = _body[xPosBall][yPosBall]
		_body[xPosBall][yPosBall] = 0
		if _deleteBallLine() == false then
			--generate new balls
			Gamelogic:genBalls()
		end
end

-- Рекурсивная функция обхода ячеек таблицы.
-- Проверяем соседнии и если ячейки заняты то ставим 1
-- Продолжаем проверять пока не пройдем все возможные варианты.
pathFinder = function(x,y)
	for i=x-1,x+1 do
		for j=y-1,y+1 do
			if (i >= 1) and (i <= Gamelogic.xCount) and (j >= 1) and (j <= Gamelogic.yCount)
			and ((_body[i][j]==0) or (_body[i][j] == Gamelogic.KEY) or (_body[i][j] == Gamelogic.CHEST)) and (_temp[i][j]==0) then
				 local continue = false
				 if (i==x-1) and (j==y-1) then continue = true
				 end
				 if (i==x+1) and (j==y-1) then continue = true
				 end
				 if (i==x+1) and (j==y+1) then continue = true
				 end
			     if (i==x-1) and (j==y+1) then continue = true
				 end
				 if continue ~= true then
					_temp[i][j] = 1
					pathFinder(i,j)
				 end
			end
		end
	end
end

-- Event onClickTable , when smb click on the game table ;) Yes! Click!!!
function Gamelogic:onClickTable(i,j)
	x , y = j , i
	print ("MouseClick",x,y)
	print (_body[x][y])
	-- If ball?
	if _body[x][y]>0 and _body[x][y] <= 7 then
		--очистка массива для последующего поиска пути
		for i=1,self.xCount do
			for j=1,self.yCount do
				_temp[i][j]=0
			end
		end
		xTemp = x
		yTemp = y
		ballClick = true
		--
		-- path find for x,y ball..
		--
		pathFinder(x,y)
		return true
	end
	-- If Zero?
	if _body[x][y]==0 and ballClick == true and _temp[x][y]==1 then
		ballClick = false
		Gamelogic:moveBall(xTemp,yTemp,x,y)

		return false
	end

	return false
end

function Gamelogic:print()
	--print('{' .. self.xCount ..'.'.. self.yCount .. '}')
	--print('maxTypes = ' .. self.maxTypes)
	-- выводим содержимое двухмерного массива
	local str = "";
	for i=1,self.xCount do
	-- каждую "строку" массива будем сначала собирать в строку, чтобы
	-- привести ее к удобочитаемому табличному виду
	for j=1,self.yCount do
		str = str.."\t".._body[i][j]
	end
	-- выводим строку
	str= str.."\r\n"
	end
	print("\r\n"..str,"")
	--
end

print("Gamelogic class init...")




