module (..., package.seeall)

prototype = Controller.prototype:subclass()

-- local ImgBgRes = 
-- {
-- 	"resource/csbimages/Msg/lan.png",
-- 	"resource/csbimages/Msg/zi.png",
-- }

function prototype:enter()

end

function prototype:playAction()
	self.rootNode:setVisible(false)

	--贝塞尔曲线动画
	-- local bc = {}
	-- bc.startPoint = 0.6
	-- bc.endPoint = 1.0
	-- bc.ctrlPoint_1 = 1.1
	-- bc.ctrlPoint_2 = 1.2

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	-- local action = require ("UI.Mgr.BezierScale").class:new(self.rootNode, bc, 0.5, 0.1*self.index, actionOver)
	-- action:restart()
	-- self.rootNode:scheduleUpdateWithPriorityLua(bind(action.update, action), 0)

	local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15+0.1*self.index)
	self.action = action
end

---tableView cell使用 began------------
function prototype:refresh(cell_data, idx, sec_idx)
	self.index = idx
	-- self.txtTitle:setString(cell_data.title)
	self:setIsRead(cell_data.isRead)

	-- local bgIndex = idx % #ImgBgRes
	-- if bgIndex == 0 then
	-- 	bgIndex = #ImgBgRes
	-- end
	-- self.imgBg:loadTexture(ImgBgRes[bgIndex])

	--[[local tb = {}
	local color = "#3C5A92"
	local fontSize = 28
	local style = {face = "resource/fonts/FZY4JW.TTF", size = fontSize, color = color, underLine = false}
	tb.style = style
	tb.list = {{str = cell_data.title}}

	self.panelBg:removeAllChildren()

	local assistNode = Assist.RichText:createRichText(tb)
	assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
	assistNode:ignoreContentAdaptWithSize(false)
	assistNode:setContentSize(cc.size(480, 60))
	self.panelBg:addChild(assistNode)

	local size = self.panelBg:getContentSize()
	assistNode:setPosition(size.width/2, size.height/2)--]]

	self.txtTitle:setString(cell_data.title)


	local time = math.floor(cell_data.createTime / 1000)
	local time_t = util.time:getTimeDate(time)
	-- log(time_t)
	self.txtTime:setString(string.format("%d-%02d-%02d  %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min))

	-- util.timer:after(500, self:createEvent("playAction"))
	-- self:playAction()

	self.cell_data = cell_data
end

--必要,返回继承cellBase的node
function prototype:getCellBase()
	return self.node_Cell
end

--每次刷新前重置调用
function prototype:reset()
	
end

--cell移动方法 
--time 时间
--size 移动的距离
function prototype:doMoveAction(time, size)
	local disPos = cc.p(size.width, size.height)
	local act = cc.MoveBy:create(time, disPos)
	self.rootNode:runAction(act)
end

--cell删除动画
--actList 删除动画结束的后的操作，不需要自己设定，只需要用就可以了
-- table.insert(actList, 1, act)
function prototype:doExitAction(actList)
	local act = cc.MoveBy:create(0.5, cc.p(600, 0))
	table.insert(actList, 1, act)
	local sqe = cc.Sequence:create(actList)
	self.rootNode:runAction(sqe)
end

---tableView cell使用 end------------

function prototype:setIsRead(isRead)
	self.btnCheck:setVisible(not isRead)
	self.btnChecked:setVisible(isRead)
end

function prototype:onBtnCheckClick()
	-- if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Msg/MsgReadView", self.cell_data)

		if self.cell_data.isRead == false then
			Model:get("Announce"):requestReadMsg({self.cell_data.id}, Announce_pb.Mail)
			self.cell_data.isRead = true
			self:setIsRead(true)
		end
	-- end
end


