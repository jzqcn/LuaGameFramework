--@todo
do return end


module(..., package.seeall)
Assist.Label = _M



--ttf字体高度自适应函数
--owner,传入self 
--node, ttf node
--str, 写入字符串 ,默认getString() 获取
--defaultNodeSize（width = 0, height = 0） 最大设定高度，默认取getDimensions()
--fontSize 默认字体最大大小, 默认取getFontSize()
--注意：node的宽度需要自己设定好大小，ccb里设定
local adapterLable
function TTFAdapter(_, owner, node, str, defaultNodeSize, fontSize)
    if node == nil then
        log4misc:warn("node is nil !")
        return
    end

    str = str or node:getString()
    if string.len(str) == 0 then
        node:setString("")
--      	log4misc:warn("str is nil or '' ")
      	return
    end
	
    --获取字体初始大小
    if owner then
  		if not owner.saveTTFSize then
  			owner.saveTTFSize = {}
  		end
  		owner.saveTTFSize[node] = owner.saveTTFSize[node] or {}
      owner.saveTTFSize[node].fontSize = owner.saveTTFSize[node].fontSize or node:getFontSize()
    end

    local defaultFontSize
    if owner then
		  defaultFontSize = fontSize or owner.saveTTFSize[node].fontSize
    else
      defaultFontSize = fontSize or node:getFontSize()
    end
  	node:setFontSize(defaultFontSize)

    --获取设定content最大范围值
    if defaultNodeSize and type(defaultNodeSize) == "number" then
       local mHeight = defaultNodeSize
       defaultNodeSize = {}
       defaultNodeSize.height = mHeight
    end
    if owner then
        defaultNodeSize = defaultNodeSize or owner.saveTTFSize[node].nodeSize
    end

    local defaulHeight = defaultNodeSize and defaultNodeSize.height or nil
    local defaulWidth  = defaultNodeSize and defaultNodeSize.width or nil

    local dimSize = node:getDimensions()
    local width  = defaulWidth or dimSize.width
    local height = defaulHeight or dimSize.height

    local nodeSize = node:getContentSize()
    width = width == 0 and nodeSize.width or width
    height = height == 0 and nodeSize.height or height

    if height == 0 or width == 0 then
     		node:setString(str)
     		log4temp:debug("warnning! node demimension is (0, 0) ! ")
     		return
    end
    if owner then
        owner.saveTTFSize[node].nodeSize = owner.saveTTFSize[node].nodeSize or {height = height, width = width}
    end
  	node:setDimensions(width, 0)
    adapterLable(node, defaultFontSize, str, height)
end

-----------------------------内部调用----------------------------------

--添加额外btn
local function addShowBtn(node, defaultFontSize, str, height)
    self.showStr = str 
    defaultFontSize = defaultFontSize + 2
    node:setFontSize(defaultFontSize)

    local lb = cc.Label:create()
    local lbStr = string.sub(str, 0, 4)
    lb:setFontSize(defaultFontSize)
    lb:setString(lbStr)
    --计算一个label的大小，然后根据node大小计算可以容纳的字符串长度
    --超长显示不下的文字用...代替
    local lbSize = lb:getContentSize()
    lbSize = {width = lbSize.width/4, height = lbSize.height}
    local lineCount = math.floor(height/lbSize.height)
    lineCount = lineCount > 1 and lineCount or 1
    local len = math.floor((node:getContentSize().width / lbSize.width) * lineCount)
    len = len > 5 and len - 3 or len 
    local subStr = string.sub(str, 0, len).." ..."
    node:setString(subStr)

    local anchorPoint = node:getAnchorPoint()
    local showSize = node:getContentSize()
    local nodePosX, nodePosY = node:getPosition()
    local parentNode = node:getParent()
    local centerX = nodePosX + (0.5 - anchorPoint.x) * showSize.width
    local centerY = nodePosY + (0.5 - anchorPoint.y) * showSize.height

    --添加额外btn用来弹tip显示完成文本
    local function onBtnShow()
          local info = {
            isShow = true,
            desc = self.showStr,
            node = parentNode,
            orgPos = cc.p(centerX, centerY)
            }
          Logic:Get("ActivityCenter"):showPopTip(info)
    end
    local function onBtnCloseShow()
          local info = {
            isShow = false,
            desc = self.showStr,
            node = parentNode,
            orgPos = cc.p(centerX, centerY)
            }
          Logic:Get("ActivityCenter"):showPopTip(info)
    end

    local showBtn = CCControlButton:create()
    parentNode:addChild(showBtn)
    showBtn:setTag(-199)
    showBtn:setPreferredSize(showSize)
    showBtn:setAnchorPoint(anchorPoint)
    showBtn:setPosition(cc.p(nodePosX, nodePosY))

    showBtn:addHandleOfControlEvent(bind(onBtnShow, self), CCControlEventTouchDown)
    showBtn:addHandleOfControlEvent(bind(onBtnCloseShow, self), CCControlEventTouchUpInside)
    showBtn:addHandleOfControlEvent(bind(onBtnCloseShow, self), CCControlEventTouchUpOutside)
end

--适应文本设定高度
local function adapterLable(node, defaultFontSize, str, height)
    --循环设定更改字体大小，适应高度
    local ok = false
    local i = 0
    repeat
      i = i + 1
      node:setString(str)
      local mSize = node:getContentSize()
      if defaultFontSize > 0 and mSize.height > height then
        defaultFontSize = defaultFontSize - 2
        node:setFontSize(defaultFontSize)
      else
        ok = true
      end
    until ok == true

    --如果字体仍然超出，则添加btn，用来显示全部内容
    if not ok and i >= 4 then
      addShowBtn(node, defaultFontSize, str, height)
    else
      local parentNode = node:getParent()
      local btnNode = parentNode:getChildByTag(-196)
      if btnNode then
        parentNode:removeChildByTag(-196, true)
      end
    end 
end

