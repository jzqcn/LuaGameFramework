module("Assist.RichText", package.seeall)

local getFontStyleHeader
local getStringStyle
local getImgStyle
local getEmojiStyle
local createEmoGif

-- 	local format = {
-- 		style = {size = 20, color = "#0ff000", underLine = true}, -- 设置字体信息,大小，颜色，以及其他属性
-- 		list = 
-- 		{
-- 			{img  = "resource/csbimages/User/female.png"},  -- 添加的图片 设置图片信息 img,  可选，width, height
-- 			{str= "testdfsfasfas"}, 						-- 字符串
-- 			{str = "te44444", link = "testBack"},			-- 字符串 可更改属性
-- 		    {emoji = ""},									-- 静态图  --现在么有资源，不可用
-- 			{gif = "role1"},								-- 动态图 --现在没有资源，不可用
-- 			{												-- 如果设置不同字体的，可嵌套
-- 				style = {size = 15, color = "#0ff0f0"},     
-- 				list = {
-- 					{str = "smalltextStrsad", bold = true},
-- 				}
-- 			}	
-- 		}
-- 	}

-------------字符串可设置属性 
--------bold = true 加粗
--------italic = true 倾斜
--------delLine = true 删除划线
--------underLine = true 下划线
--------small = true 小字体 0.8 
--------big = true 打字图 1.2
--------link = "link str" 设置点击的回调，在回调函数参数里返回此参数，如果回调未注册，则默认打开此链接
--------outLine = {color = "#000000", size = 2}  设置描边
--------shadow = {offsetWidth = 2, offsetHeight = -2, color = "#000000", blurRadius = 0} 设置阴影
--------glow = ｛color = "#0fff0f"} 设置发光
-------------------------------
---gif原理是创建一个帧动画，这里传入帧动画的名字就可以了

function getTempText(_, richTb)
	local tempText = ""
	local customNodeTb = {}
	local insertTag = 0

	local function _formatStr(formatTb)
		local textTb = {}
		for _, tb in pairs(formatTb.list) do
			repeat 
				if tb.style then
					local fontStr = _formatStr(tb)
					table.insert(textTb, fontStr)
				else
					if tb.img then
						if not getImgStyle(tb, textTb) then
							break
						end
					elseif tb.str then
						getStringStyle(tb, textTb)
					elseif tb.emoji then
						if not getEmojiStyle(tb, textTb) then
							break
						end
					elseif tb.gif then
						local node = createEmoGif(tb)
						if not node then
							break
						end
						table.insert(customNodeTb, {idx = insertTag, node = node})
					end
					insertTag = insertTag + 1
				end

			until true
		end
		local style = formatTb.style

		formatStringStyle(style, textTb)

		local header = getFontStyleHeader(style)
		table.insert(textTb, 1, header)
		table.insert(textTb, "</font>")

		return table.concat(textTb)
	end


	local tempText =  _formatStr(richTb)

	return tempText, customNodeTb
end

function createRichText(_, richTb, defaults)
	defaults = defaults or {}
	local tempText, customNodeTb = getTempText(nil, richTb)

	local richTextNode = ccui.RichText:createWithXML(tempText, defaults)
	richTextNode:setTouchEnabled(true)
	richTextNode:ignoreContentAdaptWithSize(false)

	for i, custom in ipairs(customNodeTb) do
		local customNode = ccui.RichElementCustomNode:create(i, cc.c3b(255,255,255), 255, custom.node)
		richTextNode:insertElement(customNode, custom.idx)
	end
	return richTextNode
end

function getFontStyleHeader(styleTb)
	styleTb = styleTb or {size=20, color = "#ffffff"}

	local textTb = {}
	table.insert(textTb, "<font")
	local size = styleTb.size or 20
	table.insert(textTb, " size='"..size.."'")
	local color = styleTb.color or "#ffffff"
	table.insert(textTb, " color='"..color.."'")
	if styleTb.face then
		table.insert(textTb, " face='"..styleTb.face.."'")
	end
	table.insert(textTb, ">")

	return table.concat(textTb)
end

function getImgStyle(styleTb, textTb)
	if styleTb.img == "" then 
		return
	end

	table.insert(textTb, "<img ")
	table.insert(textTb, "src='"..styleTb.img.."'")
	if styleTb.width and styleTb.width>0 then
		table.insert(textTb, " width='"..styleTb.width.."'")
	end
	if styleTb.height and styleTb.height>0 then
		table.insert(textTb, " height='"..styleTb.height.."'")
	end
	table.insert(textTb, ">")

	table.insert(textTb,"</img>")
end

function getStringStyle(styleTb, textTb)
	if styleTb.str == "" then
		return
	end

	local textStr = {}
	table.insert(textStr, styleTb.str)
	formatStringStyle(styleTb, textStr)
	table.insert(textTb, table.concat(textStr))
end

function formatStringStyle(styleTb, textStr)

	if styleTb.bold then
		table.insert(textStr, 1, "<b>")
		table.insert(textStr, "</b>")
	end

	if styleTb.italic then
		table.insert(textStr, 1, "<i>")
		table.insert(textStr, "</i>")
	end
	if styleTb.delLine then
		table.insert(textStr, 1, "<del>")
		table.insert(textStr, "</del>")
	end
	if styleTb.underLine then
		table.insert(textStr, 1, "<u>")
		table.insert(textStr, "</u>")
	end
	if styleTb.small then
		table.insert(textStr, 1, "<small>")
		table.insert(textStr, "</small>")
	end
	if styleTb.big then
		table.insert(textStr, 1, "<big>")
		table.insert(textStr, "</big>")
	end
	if styleTb.link then
		table.insert(textStr, 1, "<a href='"..styleTb.link.."'>")
		table.insert(textStr, "</a>")
	end
	if styleTb.outLine then
		local size = styleTb.outLine.size or 2
		local color = styleTb.outLine.color or "#000000"
		local str = string.format("<outline size='%d' color='%s'>", size, color)
		table.insert(textStr, 1, str)
		table.insert(textStr, "</outline>")
	end
	if styleTb.shadow then
		local offsetWidth = styleTb.shadow.offsetWidth or 2
		local offsetHeight = styleTb.shadow.offsetHeight or -2
		local color = styleTb.shadow.color or "#000000"
		local blurRadius = styleTb.shadow.blurRadius or 0
		local str = string.format("<shadow offsetWidth='%d' offsetHeight='%d' color='%s' blurRadius='%d'>", offsetWidth, offsetHeight, color, blurRadius)
		table.insert(textStr, 1, str)
		table.insert(textStr, "</shadow>")
	end
	if styleTb.glow then
		local color = styleTb.glow.color or "#000000"
		table.insert(textStr, 1, "<glow color='"..color.."'")
		table.insert(textStr, "</glow>")
	end
end

function getEmojiPath(emoji)
	return ""
end

function getEmojiStyle(styleTb, textTb)
	if styleTb.emoji == "" then 
		return
	end
	local emojiPath = getEmojiPath(styleTb.emoji)

	table.insert(textTb, "<img ")
	table.insert(textTb, "src='"..emojiPath.."'")
	if styleTb.width and styleTb.width>0 then
		table.insert(textTb, " width='"..styleTb.width.."'")
	end
	if styleTb.height and styleTb.height>0 then
		table.insert(textTb, " height='"..styleTb.height.."'")
	end	

	table.insert(textTb, ">")
	table.insert(textTb,"</img>")
end

--返回node，注意contentSize的大小，richText计算布局需要

function createEmoGif(styleTb)
	local key = styleTb.gif
	local animFrames = {}
	local emo = Model:get("Chat"):getEmojiGifPath(key)
	if emo == nil then 
		return 
	end

	for i = 1 ,#emo do 
		local sprEmo = cc.Sprite:create(emo[i])
		local sprFra = sprEmo:getSpriteFrame()
		table.insert(animFrames,sprFra)
	end
	local spr = cc.Sprite:create(emo[1])

	local ani = cc.Animation:createWithSpriteFrames(animFrames, 0.3)
	local emo = cc.RepeatForever:create(cc.Animate:create(ani))

	spr:runAction(emo)
	spr:setAnchorPoint(cc.p(0.5, 0.5))

	return spr
end