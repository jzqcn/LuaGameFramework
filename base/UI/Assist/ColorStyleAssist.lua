--@todo
do return end


module(..., package.seeall)
Assist.ColorStyle = _M

--[[
    1 MAIN_TITLE
    2 PROMPT_TITLE
    3 LABEL_PAGE_SEL
    4 LABEL_PAGE_NOR
    5 BTN_TITLE
    6 DARK_WHITE
    7 BROWN_L
    8 BROWN_M
    9 BROWN_S
    10 WHITE_L
    11 WHITE_M
    12 WHITE_S
    13 GREEN_L
    14 GREEN_M
    15 GREEN_S
    16 RED_L
    17 RED_M
    18 RED_S
    19 PROGRESS_BAR
    20 BTNTITLE_WHITE
    21 YELLOW_L
    22 YELLOW_M
    23 YELLOW_S
    24 BLUE_L
    25 BLUE_M
    26 BLUE_S
    27 UNION_FOLDER
    28 ORANGE_L
    29 ORANGE_M
    30 ORANGE_S
    31 BTN_DISABLED
    32 ITEM_TITLE
]]


local STYPE_ENUM_TYPE = 
{
--public 
    ["MAIN_TITLE"]          =  {color = "#f1e4d3", stroke = "#311209", strokeSize=3, size=20},  --标题文字 
    ["PROMPT_TITLE"]        =  {color = "#ffedd9", stroke = "#1d0c07", strokeSize=2, size=20},  --弹窗标题
    ["ITEM_TITLE"]          =  {color = "#ffedd9", stroke = "#1d0c07", strokeSize=2, size=24},  --Item标题
    ["LABEL_PAGE_SEL"]      =  {color = "#ffffff", stroke = "#1c0b06", strokeSize=2, size=22},  --标签页字 选中 
    ["LABEL_PAGE_NOR"]      =  {color = "#c5c0c6", stroke = "#1d0c07", strokeSize=2, size=22},  --标签页字 正常
    ["BTN_TITLE"]           =  {color = "#ffffff", stroke = "#1c0b06", strokeSize=2, size=22},  --按钮文字
    ["DARK_WHITE"]          =  {color = "#ffffff", stroke = "#301f1f", strokeSize=2, size=22},
  
    ["BROWN_L"]             =  {color = "#451d10", size=24},      --棕色
    ["BROWN_M"]             =  {color = "#451d10", size=22},      --棕色
    ["BROWN_S"]             =  {color = "#451d10", size=20},      --棕色
    ["BROWN_Z"]             =  {color = "#441e0f", size=20},      --资源棕色

    ["WHITE_L"]             =  {color = "#ffffff", size=24},     --白色
    ["WHITE_M"]             =  {color = "#ffffff", size=22},     --白色
    ["WHITE_S"]             =  {color = "#ffffff", size=20},     --白色

    ["GREEN_L"]             =  {color = "#36ff60", size=24},     --绿色
    ["GREEN_M"]             =  {color = "#36ff60", size=22},     --绿色
    ["GREEN_S"]             =  {color = "#36ff60", size=20},     --绿色
 
    ["RED_L"]               =  {color = "#dc1400", size=24},     --红色
    ["RED_M"]               =  {color = "#dc1400", size=22},     --红色
    ["RED_S"]               =  {color = "#dc1400", size=20},     --红色

    ["YELLOW_L"]            =  {color = "#ffe957", size=24},     --黄色
    ["YELLOW_M"]            =  {color = "#ffe957", size=22},     --黄色
    ["YELLOW_S"]            =  {color = "#ffe957", size=20},     --黄色

    ["BLUE_L"]              =  {color = "#136ccf", size=24},     --蓝色
    ["BLUE_M"]              =  {color = "#136ccf", size=22},     --蓝色
    ["BLUE_S"]              =  {color = "#136ccf", size=20},     --蓝色

    ["PROGRESS_BAR"]        =  {color = "#ffffff",  stroke = "#451d10", strokeSize=2, size=18},  --进度条
    ["BTNTITLE_WHITE"]      =  {color = "#ffffff",  stroke = "#1c0b06", strokeSize=2, size=20},
    ["UNION_FOLDER"]        =  {color = "#ffedd9", size=22, stroke="#1d0c07", strokeSize=2}, -- 联盟折叠条

    ["ORANGE_L"]            =  {color = "#ffb923",  size=24},  --橙色
    ["ORANGE_M"]            =  {color = "#ffb923",  size=22},  --橙色
    ["ORANGE_S"]            =  {color = "#ffb923",  size=20},  --橙色
    ["BTN_DISABLED"]        =  {color = "#c9c9c9",  stroke = "#1c0b06", strokeSize=2, size=22},

--other
    ["RANK_WHITE"]          =  {color = "#fff6e9", size=20},    --白色
    ["RANK_GREEN"]          =  {color = "#0cb20a", size=20},    --绿色
    ["RANK_BLUE"]           =  {color = "#33a9da", size=20},    --蓝色
    ["RANK_PURPLE"]         =  {color = "#b22bac", size=20},    --紫色
    ["RANK_ORGINE"]         =  {color = "#cb6724", size=20},    --橙色
    ["RANK_GOLD"]           =  {color = "#edff5b", size=20},    --金色    

    ["MAP_KINGDOM"]         =  {color = "#d0fefe", size=22},
    ["MAP_KING"]            =  {color = "#fce4b0", size=22},
}

--参数 node 控件， 样式字符串 sizeFlag = true 修改字体大小
function setStyle(node, styleType, sizeFlag)
    sizeFlag = sizeFlag ~= false
    if Tw.Controller:getType(node) == "ControlButton" then
        self:setBtnTitleStyle(node, styleType, sizeFlag)
        return
    end

    if node == nil or STYPE_ENUM_TYPE[styleType] == nil then
        log4misc:warn(("node is nil or unknow styleType:%s"):format(styleType or "nil"))
        return
    end

    local styleInfo = STYPE_ENUM_TYPE[styleType]
    self:enableOutline(node, styleInfo, sizeFlag)
end

function setBtnTitleStyle(node, styleType, sizeFlag)
    sizeFlag = sizeFlag ~= false
    if node == nil or STYPE_ENUM_TYPE[styleType] == nil then
        log4misc:warn(("node is nil or unknow styleType:%s"):format(styleType or "nil"))
        return
    end

    local label = node:getTitleLabel()
    local styleInfo = STYPE_ENUM_TYPE[styleType]
    self:enableOutline(label, styleInfo, sizeFlag)

    --
    local labelSize = node:getContentSize()
    local str = label:getString() or ""
	if str ~= "" and label:getContentSize().width > labelSize.width - 20 then
        label:setHorizontalAlignment(kCCVerticalTextAlignmentCenter)
        label:setDimensions(labelSize.width - 20, 0)
		TTFAssist:TTFAdapter(nil, label, str, {height = labelSize.height - 15}, label:getFontSize())
	end
end

--@param:node=节点，styleInfo=描边信息(table)
function setSpecialStyle(node, styleInfo, sizeFlag)
    if node == nil or table.empty(styleInfo or {}) then
        log4misc:warn("node is nil or styleInfo is nil")
        return
    end

    sizeFlag = sizeFlag ~= false
    local isBtn = Tw.Controller:getType(node) == "ControlButton"
    local outlineNode = isBtn and node:getTitleLabel() or node
    self:enableOutline(outlineNode, styleInfo, sizeFlag)
end

function getStyleInfo(styleType)
    styleType = styleType or ""
    return STYPE_ENUM_TYPE[styleType] or {}
end

--内部方法，外部请不要调用
function enableOutline(node, styleInfo, sizeFlag)
    local r, g, b = string.match(styleInfo.color, "#(%w%w)(%w%w)(%w%w)")
    node:setColor(ccc3(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)))
    if styleInfo.stroke then
        local r, g, b = string.match(styleInfo.stroke, "#(%w%w)(%w%w)(%w%w)")
        node:enableOutline(cc.c4b(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16),255),styleInfo.strokeSize)
    end

    if sizeFlag and styleInfo.size then
        node:setFontSize(styleInfo.size)
    end
end
