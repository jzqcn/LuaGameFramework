module (..., package.seeall)

prototype = Controller.prototype:subclass()

local getDisstance = getDisstance

--显示游戏中坐标关系
function prototype:enter()
	self.rootNode:setVisible(false)
end

function prototype:showDistance(modelName)
	if self:existEvent('SHOW_TIMEOUT_TIMER') then
		return
	end

	local modelData = Model:get(modelName)
	if modelData == nil then
		log4ui:error("[GamePosition::showDistance] : get model data error ! model name == "..modelName)
		return
	end

	local parentLayer = self.rootNode:getParent()
	--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
	local parentProxy = tolua.getpeer(parentLayer:getParent())
	if parentProxy then
		local members = modelData:getRoomMember()
		local fromIndex, toIndex
		local fromPos, toPos
		local fromId, toId
		local fromLocation, toLocation
		local dis = -1
		local memIds = table.keys(members)
		local iMemNum = #memIds
		if iMemNum > 1 then
			for i = 1, iMemNum-1, 1 do
				for j = i + 1, iMemNum, 1 do
					fromId = memIds[i]
					fromIndex = modelData:getPlayerSeatIndex(fromId)
					fromPos = parentProxy["nodeRole_"..fromIndex]:getHeadPos()

					toId = memIds[j]
					toIndex = modelData:getPlayerSeatIndex(toId)
					toPos = parentProxy["nodeRole_"..toIndex]:getHeadPos()

					fromLocation = members[fromId].positionInfo
					toLocation = members[toId].positionInfo
					log(fromLocation)
					log(toLocation)
					local fromLongitude = tonumber(fromLocation.longitude) or 0
					local fromLatitude = tonumber(fromLocation.latitude) or 0
					local toLongitude = tonumber(toLocation.longitude) or 0
					local toLatitude = tonumber(toLocation.latitude) or 0
					if fromLongitude==0 or fromLatitude==0 or toLongitude==0 or toLatitude==0 then
						dis = -1
					else
						dis = getDisstance(fromLongitude, fromLatitude, toLongitude, toLatitude)
					end
					
					self:stretchLine(fromPos, toPos, dis)
				end
			end
		else
			return
		end
	else
		log4ui:error("[GamePosition::showDistance] : get parent Proxy data error ! ")
		return
	end

	self.rootNode:setVisible(true)

	util.timer:after(5*1000, self:createEvent('SHOW_TIMEOUT_TIMER', 'onShowTimeOut'))
end

function prototype:onShowTimeOut()
	self.rootNode:removeAllChildren()
	self.rootNode:setVisible(false)
end

local function RADIANS_TO_DEGREES(angle)  -- PI * 180
	return angle* 57.29577951
end

--画连接直线
function prototype:stretchLine(fromP, toP, dis)
	log("fromP:: x=="..fromP.x..", y=="..fromP.y)
	log("toP:: x=="..toP.x..", y=="..toP.y)
	log("distance : "..dis)

	local spriteLine = cc.Sprite:create("resource/csbimages/Common/line.png")
	if spriteLine then
		local size = spriteLine:getContentSize()

		local dir = cc.p(toP.x - fromP.x, toP.y - fromP.y) 					--矢量
		local length = math.sqrt(dir.x * dir.x + dir.y * dir.y) 			--长度
		local degrees = -RADIANS_TO_DEGREES(math.atan2(dir.y, dir.x)) 	--角度
		local scale = length / size.width 	--拉伸比例

		spriteLine:setAnchorPoint(cc.p(0, 0.5))
		spriteLine:setPosition(fromP)	--起始位置
		spriteLine:setRotation(degrees)	--旋转角度
		spriteLine:setScaleX(scale)		--缩放比例

		self.rootNode:addChild(spriteLine)

		local centerX = fromP.x + (toP.x-fromP.x)/2
		local centerY = fromP.y + (toP.y-fromP.y)/2

		local labTip
		if dis > 0 then
			local numberText
			if dis > 1 then
				numberText = tostring(dis)
				local idx = numberText:find('%.')
			    if idx == nil then
			    else 
			    	numberText = numberText:sub(1, idx+2)	
			    end

			    numberText = numberText .. "千米"
			    labTip = cc.Label:createWithBMFont("resource/csbimages/BMFont/fnt_pos_2.fnt", numberText)
			else				
				numberText = tostring(math.floor(dis * 1000))
				-- local idx = numberText:find('%.')
			 --    if idx == nil then
			 --    else
			 --    	numberText = numberText:sub(1, idx+2)
			 --    end

			    numberText = numberText .. "米"
			    if dis * 1000 <= 200 then
			    	labTip = cc.Label:createWithBMFont("resource/csbimages/BMFont/fnt_pos_1.fnt", numberText)
			    else
			    	labTip = cc.Label:createWithBMFont("resource/csbimages/BMFont/fnt_pos_2.fnt", numberText)
			    end
			end

			-- labTip = cc.Label:createWithTTF(numberText, "resource/fonts/FZY4JW.TTF", 24)

		else
			-- labTip = cc.Label:createWithTTF("未知", "resource/fonts/FZY4JW.TTF", 24)
			labTip = cc.Sprite:create("resource/csbimages/Games/Common/txtUnknownPos.png")
		end

		-- labTip:setRotation(degrees)
		dis = dis * 1000
		if dis <= 200 then
			-- labTip:setTextColor( cc.c4b(255, 122, 150, 255))
			-- labTip:enableOutline(cc.c4b(93, 11, 30, 255))
			labTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2), cc.ScaleTo:create(0.5, 1.0))))
		else
			-- labTip:setTextColor( cc.c4b(221, 251, 255, 255))
			-- labTip:enableOutline(cc.c4b(14, 35, 88, 255))
		end
		-- labTip:enableOutline(cc.c4b(255, 255, 255, 255), 1)
		labTip:setPosition(cc.p(centerX, centerY))
		self.rootNode:addChild(labTip)
	end
end

