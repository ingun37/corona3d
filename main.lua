

local zf = 100
local zn = 1
local vertices={}
local points={}
local fordepth={}
local e = {}
local v = {}
local u = {}
local cubepos={0,0,0,1}
local camerapos = {0,0,-12,1}
local lookat = {0,0,1,1}


vertices[1] = {-1,1,-1,1}
vertices[2] = {-1,1,1,1}
vertices[3] = {1,1,1,1}
vertices[4] = {1,1,-1,1}

vertices[5] = {-1,-1,-1,1}
vertices[6] = {-1,-1,1,1}
vertices[7] = {1,-1,1,1}
vertices[8] = {1,-1,-1,1}


local function DotProduct(...)
	return arg[1]*arg[1+3] + arg[2]*arg[2+3] + arg[3]*arg[3+3]
end

local function CrossProductNormalize(...)
	local ret = {0,0,0,0}

	ret[1] = arg[2]*arg[3+3] - arg[3]*arg[2+3]
	ret[2] = arg[3]*arg[1+3] - arg[1]*arg[3+3]
	ret[3] = arg[1]*arg[2+3] - arg[2]*arg[1+3]

	ret[1] = ret[1]/math.sqrt(math.pow(ret[1],2) + math.pow(ret[2],2) + math.pow(ret[3],2))
	ret[2] = ret[2]/math.sqrt(math.pow(ret[1],2) + math.pow(ret[2],2) + math.pow(ret[3],2))
	ret[3] = ret[3]/math.sqrt(math.pow(ret[1],2) + math.pow(ret[2],2) + math.pow(ret[3],2))

	return ret[1], ret[2], ret[3], 1
end

local function MultScreen(...)
	
	local matrix = {}
	local ret = {0,0,0,0}
	for i=1,4 do
		matrix[i]={}
		for j=1,4 do
			if (i==1 and j==1) then
				matrix[i][j] = display.contentWidth/2
			elseif (i==1 and j==4) then
				matrix[i][j] = display.contentWidth/2
			elseif (i==2 and j==2) then
				matrix[i][j] = -display.contentWidth/2
			elseif (i==2 and j==4) then
				matrix[i][j] = display.contentWidth/2
			elseif (i==j)then
				matrix[i][j] = 1
			else
				matrix[i][j] = 0
			end
			ret[i] = ret[i] + matrix[i][j]*arg[j]
		end
		
	end
	return ret[1],ret[2],ret[3],ret[4]
end

local function MultProj(...)
	print(arg[1],arg[2],arg[3])
	local trans = math.sqrt(math.pow(arg[1],2) + math.pow(arg[2],2) + math.pow(arg[3],2))
	local matrix = {}
	local ret = {0,0,0,0}
--	print(display.contentHeight, display.contentWidth)
	for i=1,4 do
	matrix[i] = {}
		for j=1,4 do
--			if(i==1 and j==1)then
--				matrix[i][j] = 1
--				matrix[i][j] = 1/arg[3]
--			elseif(i==2 and j==2)then
--				matrix
			if(i==3 and j==3)then
				matrix[i][j] = (zf/(zf-zn))/arg[3]
			elseif (i==3 and j==4)then
				matrix[i][j] = -zn/arg[3]
			elseif (i==4 and j==4)then
				matrix[i][j] = 0
			elseif (i==j)then
				matrix[i][j] = 1/arg[3]
			else
				matrix[i][j] = 0
			end
			ret[i] = ret[i] + matrix[i][j]*arg[j]
		end
	end
	return ret[1],ret[2],ret[3],1
end

local function MultViewMatrix(...)
	local matrix = {}
	local ret = {0,0,0,0}
	matrix[1] = {}
	matrix[2] = {}
	matrix[3] = {}
	matrix[4] = {}
	
	for j=1,4 do
		if(j==4)then
			matrix[1][4]=-DotProduct(camerapos[1],camerapos[2],camerapos[3],v[1],v[2],v[3])
			matrix[2][4]=-DotProduct(camerapos[1],camerapos[2],camerapos[3],u[1],u[2],u[3])
			matrix[3][4]=-DotProduct(camerapos[1],camerapos[2],camerapos[3],e[1],e[2],e[3])
			matrix[4][4]=1

			ret[1] = ret[1] + arg[j]*matrix[1][j]
			ret[2] = ret[2] + arg[j]*matrix[2][j]
			ret[3] = ret[3] + arg[j]*matrix[3][j]
			ret[4] = ret[4] + arg[j]*matrix[4][j]
			break
		end
			
			matrix[1][j] = v[j]
			matrix[2][j] = u[j]
			matrix[3][j] = e[j]
			matrix[4][j] = 0


			ret[1] = ret[1] + arg[j]*matrix[1][j]
			ret[2] = ret[2] + arg[j]*matrix[2][j]
			ret[3] = ret[3] + arg[j]*matrix[3][j]
			ret[4] = ret[4] + arg[j]*matrix[4][j]
		
		
	end
	return ret[1],ret[2],ret[3],ret[4]
end

local function MultWorld(...)
	local ret = {0,0,0,0}
	local matrix = {}
	for i=1, 4 do
		matrix[i]={}
		for j=1, 4 do
			if(i==j)then
				matrix[i][j] = 1
			elseif (j==4) then
				matrix[i][4] = cubepos[i]
			else
				matrix[i][j] = 0
			end
			ret[i] = ret[i] + matrix[i][j]*arg[j]
		end
	end
	return ret[1],ret[2],ret[3],ret[4]
end



local function newStar()

	-- need initial segment to start
	local star = display.newLine( points[1][1],points[1][2], points[2][1],points[2][2] ) 

	for i=2,4 do
		star:append(points[0 + i%4 + 1][1],points[0 + i%4 + 1][2])
	end
	for i=0,4 do
		star:append(points[4 + i%4 + 1][1],points[4 + i%4 + 1][2])
	end
	for i=1,4 do
		star:append(points[5 + i%4 - 4][1],points[5 + i%4 - 4][2])
		star:append(points[5 + i%4 + 0][1],points[5 + i%4 + 0][2])
	end

	-- default color and width (can also be modified later)
	star:setColor( 255, 255, 255, 255 )
	star.width = 1

	return star
end



local function Update()

--	print(camerapos[1],camerapos[2],camerapos[3])


	v[1], v[2], v[3], v[4] = CrossProductNormalize(0,1,0,e[1],e[2],e[3])
	u[1], u[2], u[3], u[4] = CrossProductNormalize(e[1],e[2],e[3],v[1],v[2],v[3])


	for i=1,8 do
		points[i]={}
	
		points[i][1],points[i][2],points[i][3],points[i][4] = MultScreen(MultProj(MultViewMatrix(MultWorld(vertices[i][1],vertices[i][2],vertices[i][3],vertices[i][4]))))
	
	end

end

-------------------------------------------------------rendering start
e[1] = (lookat[1]-camerapos[1])/math.sqrt(math.pow(lookat[1]-camerapos[1],2) + math.pow(lookat[2]-camerapos[2],2) + math.pow(lookat[3]-camerapos[3],2))
e[2] = (lookat[2]-camerapos[2])/math.sqrt(math.pow(lookat[1]-camerapos[1],2) + math.pow(lookat[2]-camerapos[2],2) + math.pow(lookat[3]-camerapos[3],2))
e[3] = (lookat[3]-camerapos[3])/math.sqrt(math.pow(lookat[1]-camerapos[1],2) + math.pow(lookat[2]-camerapos[2],2) + math.pow(lookat[3]-camerapos[3],2))
e[4] = 1

Update()
-------------------------------------------------------rendering init end
---------rotaterightbutton-------------
delta = 0.1
local widget = require( "widget" )

local RotateRight= function( event )

--	delta = delta + 3.14/4
	local ret = {}
	ret[1] = e[1] * math.cos(delta) + e[3] * math.sin(delta)
	ret[2] = e[2]
	ret[3] = e[1] * -math.sin(delta) + e[3]*math.cos(delta)
	
	e[1] ,e[2],e[3] = ret[1],ret[2],ret[3]
	
	Update()

	if(myStar)then
		myStar.parent:remove(myStar)
	end
	myStar = newStar()
	myStar:setColor( math.random(255), math.random(255), math.random(255), 255 )
	myStar.width = 3
	

	myStar:setReferencePoint( display.CenterReferencePoint )
end

local buttonright = widget.newButton{
	default = "buttonBlueSmall.png",
	over = "buttonBlueSmallOver.png",
	onEvent = RotateRight,
	id = "rightBtn",
	label = "turn right",
	fontSize = 12,
	emboss=true
}

buttonright.x = 250; buttonright.y = 400


----------button end-------------

---------rotateleftbutton-------------


local RotateLeft= function( event )

	local ret = {}
	ret[1] = e[1] * math.cos(-delta) + e[3] * math.sin(-delta)
	ret[2] = e[2]
	ret[3] = e[1] * -math.sin(-delta) + e[3]*math.cos(-delta)
	
	e[1] ,e[2],e[3] = ret[1],ret[2],ret[3]

	Update()

	if(myStar)then
		myStar.parent:remove(myStar)
	end
	myStar = newStar()
	myStar:setColor( math.random(255), math.random(255), math.random(255), 255 )
	myStar.width = 3
	

	myStar:setReferencePoint( display.CenterReferencePoint )
end

local buttonleft = widget.newButton{
	default = "buttonBlueSmall.png",
	over = "buttonBlueSmallOver.png",
	onEvent = RotateLeft,
	id = "leftBtn",
	label = "turn left",
	fontSize = 12,
	emboss=true
}

buttonleft.x = 70; buttonleft.y = 400


----------button end-------------

----------------forwardbutton-------------------

local MoveForward= function( event )

	local ret = {}
	camerapos[1] = e[1]*0.5 + camerapos[1]
	camerapos[2] = e[2]*0.5 + camerapos[2]
	camerapos[3] = e[3]*0.5 + camerapos[3]
	
	Update()

	if(myStar)then
		myStar.parent:remove(myStar)
	end
	myStar = newStar()
	myStar:setColor( math.random(255), math.random(255), math.random(255), 255 )
	myStar.width = 3
	

	myStar:setReferencePoint( display.CenterReferencePoint )
end

local buttonforward = widget.newButton{
	default = "buttonBlueSmall.png",
	over = "buttonBlueSmallOver.png",
	onEvent = MoveForward,
	id = "forwardBtn",
	label = "go forward",
	fontSize = 12,
	emboss=true
	
}

buttonforward.x = 160; buttonforward.y = 380

----------button end-------------

----------------backwardbutton-------------------

local Movebackward= function( event )

	local ret = {}
	camerapos[1] = -e[1]*0.5 + camerapos[1]
	camerapos[2] = -e[2]*0.5 + camerapos[2]
	camerapos[3] = -e[3]*0.5 + camerapos[3]
	
	Update()

	if(myStar)then
		myStar.parent:remove(myStar)
	end
	myStar = newStar()
	myStar:setColor( math.random(255), math.random(255), math.random(255), 255 )
	myStar.width = 3
	

	myStar:setReferencePoint( display.CenterReferencePoint )
end

local buttonbackward = widget.newButton{
	default = "buttonBlueSmall.png",
	over = "buttonBlueSmallOver.png",
	onEvent = Movebackward,
	id = "backwardBtn",
	label = "go backward",
	fontSize = 12,
	emboss=true
}

buttonbackward.x = 160; buttonbackward.y = 420


----------button end-------------


-- Create stars with random color and position

local stars = {}

myStar = newStar()
	
myStar:setColor( math.random(255), math.random(255), math.random(255), 255 )
myStar.width = 3

myStar:setReferencePoint( display.CenterReferencePoint )

table.insert(stars,myStar)
------------------------------------------


function stars:enterFrame( event )
	



end

Runtime:addEventListener( "enterFrame", stars)
