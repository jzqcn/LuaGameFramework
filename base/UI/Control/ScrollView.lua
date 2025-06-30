local Layout = require "UI.Control.Layout"

module(..., package.seeall)


prototype = Layout.prototype:subclass()

function prototype:enter()
end

function prototype:addContent(node)
    self.content = node

    local size = node:getContentSize()
    local scale = node:getScale()
    size.width = size.width * scale
    size.height = size.height * scale

    self.rootNode:setInnerContainerSize(size)
    self.rootNode:addChild(node)
    self.rootNode:setInertiaScrollEnabled(true)

    self:initScaleInfo(scale, size)
end

-- 相当于：当前可视区域的左下角点 在整个可滑动内容的位置
function prototype:getContentPosition()
    local innerContainer = self:getInnerContainer()
    local x, y = innerContainer:getPosition()
    x = math.ceil(math.abs(x))
    y = math.ceil(math.abs(y))
    return x, y
end

--node为content的一个子节点(可以嵌套)
--@todo func
function prototype:moveToTarget(node, time, func)
    local pos = Assist:translatePos(node, self.content)
    local percent = self:contentPos2Percent(pos.x, pos.y)

    time = time or 1
    self:scrollToPercentBothDirection(percent, time, true)

    local delay =  cc.DelayTime:create(time)
    local function scaleAction()
        self:scaleAction(node, 1.3, time/2, func)
    end
    local callFunc = cc.CallFunc:create(function() scaleAction() end)
    local seq = cc.Sequence:create(delay, callFunc)
    self:runAction(seq)
end

function prototype:jumpToTarget(node)
    local pos = Assist:translatePos(node, self.content)
    local percent = self:contentPos2Percent(pos.x, pos.y)

    self.rootNode:jumpToPercentBothDirection(percent)
end

function prototype:scrollToContent(x, y, time, func)
    local percent = self:contentPos2Percent(x, y)

    time = time or 1
    self:scrollToPercentBothDirection(percent, time, true)
end

function prototype:jumpToContent(x, y)
    local percent = self:contentPos2Percent(x, y)
    self.rootNode:jumpToPercentBothDirection(percent)
end

function prototype:jumpTopMid()
    local size = self.content:getContentSize()
    local scrollSize = self.rootNode:getContentSize()
    self:jumpToContent(size.width/2, size.height - scrollSize.height/2)
end

-- 目标点：屏幕中心
-- 位置是相对于contentNode
function prototype:contentPos2Percent(x, y)
    local size = self.content:getContentSize()
    local scrollSize = self.rootNode:getContentSize()

    local percent = cc.p((x - scrollSize.width / 2) / (size.width - scrollSize.width) * 100, 
                        100 - (y - scrollSize.height / 2) / (size.height - scrollSize.height) * 100)
    return percent
end


-- 目标node  缩放比例 时间 回调
function prototype:scaleAction(node, toScale, time, func)
    self.rootNode:setTouchEnabled(false)

    local pos = Assist:translatePos(node, self.content)
    local innerContainer = self.rootNode:getInnerContainer()
    local width = innerContainer:getContentSize().width
    local height = innerContainer:getContentSize().height

    local curXPos, curYPos = innerContainer:getPosition()
    local curAnchPoint = innerContainer:getAnchorPoint()
    local curScale = innerContainer:getScale()

    local anchPointX = pos.x / width
    local anchPointY = pos.y / height
    local xPos = curXPos + (anchPointX - curAnchPoint.x) * width * curScale
    local yPos = curYPos + (anchPointY - curAnchPoint.y) * height * curScale
    innerContainer:setAnchorPoint(cc.p(anchPointX, anchPointY))
    innerContainer:setPosition(xPos, yPos)

    local magnifyAction = cc.ScaleTo:create(time * 2 / 3, toScale)
    local resumeAction = cc.ScaleTo:create(time / 3, curScale)
    local callFunc = cc.CallFunc:create(function() 
                        local x = xPos + (-anchPointX) * width * curScale
                        local y = yPos + (-anchPointY) * height * curScale
                        innerContainer:setAnchorPoint(cc.p(0, 0))
                        innerContainer:setPosition(x, y)
                        self.rootNode:setTouchEnabled(true)
                        if func then
                            func()
                        end
                    end)

    local seq = cc.Sequence:create(magnifyAction, resumeAction, callFunc)
    innerContainer:runAction(seq)
end

----------------------scale--------------
--prviate
function prototype:initScaleInfo(scale, size)
    self.minScale = scale
    self.maxScale = 3
    self.contentSizeWidth = size.width
    self.contentSizeHeigth = size.height

    self.prePoint1 = nil
    self.prePoint2 = nil
    self.lastPoint1 = nil
    self.lastPoint2 = nil

    self.scaleEnabled = false
    self.sacleTarget = nil
end

function prototype:mulTouches(event)
    if not self.scaleEnabled then
        return
    end

    if event.type == "began" then
        for _, touch in pairs(event.touch) do
            local pos = touch.pos
            local touchId = touch.id
            if touchId == 0 then
                self.prePoint1 = pos
                self.lastPoint1 = pos
            elseif touchId == 1 then
                self.prePoint2 = pos
                self.lastPoint2 = pos
            end
        end

        if self.prePoint1 and self.prePoint2 then
            self.prePoint1 = self.lastPoint1
            self.prePoint2 = self.lastPoint2
            self.scaleMove = true
            self:beganScale()
            self:setMoveStop(true)
        end
    elseif event.type == "moved" then
        if self.scaleMove then
            local curPos1, curPos2
            for _, touch in pairs(event.touch) do
                local pos = touch.pos
                local touchId = touch.id
                if touchId == 0 then
                    curPos1 = pos 
                elseif touchId == 1 then
                    curPos2 = pos
                end
            end
            self:scaleMap(curPos1, curPos2)
            self.lastPoint1 = curPos1
            self.lastPoint2 = curPos2
        end

    elseif event.type == "ended" then
        for _, touch in pairs(event.touch) do
            local touchId = touch.id
            if touchId == 0 then
                self.prePoint1 = nil 
            elseif touchId == 1 then
                self.prePoint2 = nil
            end
        end

        if self.prePoint1 == nil and self.prePoint2 == nil then
            self.scaleMove = false
            self:setMoveStop(false)
        end 
    end
end

function prototype:scaleMap(pos1, pos2)
    if not self.prePoint1 or not self.prePoint2 then
        return
    end

    local length1 = cc.pGetDistance(self.prePoint1, self.prePoint2)
    local length2 = cc.pGetDistance(pos1, pos2)
    local milldePos
    if self.sacleTarget then
        middlePos = cc.p(self.sacleTarget:getPosition())
    else
        middlePos = cc.pMidpoint(pos1, pos2)
    end
    local scale =  (length2 - length1)/length1
    self:setInerScale(scale, middlePos)
end

function prototype:beganScale()
    self.preScale =  self.content:getScale()
end

function prototype:setInerScale(scaleFactor, middlePos)
    local innerContainer = self.rootNode:getInnerContainer()
    local prePosX, prePosY = innerContainer:getPosition()
    local prePoint = self.content:convertToNodeSpace(middlePos)

    local scale = self.preScale * (1 + scaleFactor)
    scale = scale > self.maxScale and self.maxScale or scale
    scale = scale < self.minScale and self.minScale or scale
    self.content:setScale(scale)

    local width = self.contentSizeWidth * scale
    local height = self.contentSizeHeigth * scale
    innerContainer:setContentSize({width = width, height = height})

    local curPoint = self.content:convertToWorldSpace(prePoint)

    local xDis = curPoint.x - middlePos.x
    local yDis = curPoint.y - middlePos.y
    prePosX = prePosX - xDis
    prePosY = prePosY - yDis
    innerContainer:setPosition(cc.p(prePosX, prePosY))
end

--public

--target 缩放以target为中心点进行缩放
function prototype:setScaleTarget(target)
    self.sacleTarget = target
end

--maxScale 缩放最大缩放值
function prototype:setScaleEnabled(enabled, maxScale)
    self.scaleEnabled = enabled
    self.maxScale = maxScale or self.maxScale
end

--是否停止滑动
function prototype:setMoveStop(stop)
    self.rootNode:setTouchmoveStop(stop)
end

--设置最大缩放值
function prototype:setMaxSacle(maxScale)
    self.maxScale = maxScale > self.minScale and maxScale or self.minScale
end
