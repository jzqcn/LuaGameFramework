

local enum = enum
module(...)


-----------层次图----------
-- scene  transition replaceScene
--	|-rootlayer
--		|-dialoglayer(主窗口)
--			|-dialog(业务窗口SHOW_TYPE.DIALOG) 
--				|-dialogprompt(业务子窗SHOW_TYPE.DIALOGPROMPT)
--		|-windowlayer
--			|-window 顶层窗口 SHOW_TYPE.WINDOW  (一般用于提示框 公告)
--				|-windowprompt (预留)
--
--注意：为了代码功能独立分离 方便维护和扩展 窗口内独立的功能尽量拆分为多个子面板
--		这种面板直接挂在主窗口内 不属于窗口类 多个子面板可以通过隐藏方式来切换

WINDOW_TYPE = enum
{
	"WINDOWBASE",
	"DIALOG",
	"DIALOGPROMPT",
	"WINDOW", 	
}

PRIORITY = enum
{
	NORMAL = 0,  --一般窗口都用默认
	GUID = 100,
}

-----------------------------------------------
--针对同一个级别的窗口栈
--打开和重新打开窗口规则
--根据层次图 有3种栈：dialog dialogprompt windownode
--

--打开方式  打开自己后 对上一个打开窗口的影响
--没使用  暂时用不上
-- OPEN_TYPE = enum  
-- {
-- 	"ONLY",		--关闭其他
-- 	"ADD",	  --叠加
-- }

--打开自己的方式  如果之前已经打开 再次被打开的处理方式
RE_OPEN_TYPE = enum  
{
	"ONLY",			--只有一个实例 第二次不会被重新打开
	"CLOSE_BEFORE", --关闭之前 重新打开(tip类窗口使用)
	"OPEN_NEW",  	--不关闭之前 再开一个实例(错误提示框类窗口使用 可以开多个)
}
--
-----------------------------------------------

--窗口相关事件  打开 关闭 激活
--可以注册监听
WINDOW_EVT = enum
{
	"OPEN",
	"CLOSE",
}

--窗口的zorder
WINDOW_ZORDER = {}
WINDOW_ZORDER[WINDOW_TYPE.DIALOG] = 0
WINDOW_ZORDER[WINDOW_TYPE.DIALOGPROMPT] = 999
WINDOW_ZORDER[WINDOW_TYPE.WINDOW] = 0



------------------------------------------------
--窗口Touch事件 吞噬 不吞噬
WINDOW_TOUCH_TYPE = enum
{
  "SWALLOW",
  "NO_SWALLOW"
}



--[[------------------------------------------------
使用说明：

1 了解接口和细节 直接看源码 UIMgr/Mgr.lua

2 不用require  "Dialog" "DialogPrompt"  直接使用

3 窗口的大小获取规则：ccb第一层级的第一张sprite或sprite9
    如果没有找到 则查找第一个node节点里面的(直系子控件 不会递进进去)第一张sprite或sprite9
 情况1：
  layer
    ...
    bgsprite9
    ...
    
  情况2：
   layer
     node
        ...
        bgsprite9
        ...
    ...
    
 用途：作为窗口大小 在这个范围内 点击都不会穿透  否则窗口会有穿透问题  
 如果本身就需要穿透 避开这个规则就行了
 
4 窗口周边半透  不用自己在ccb里添加  自动添加
function prototype:hasMaskBg()
	return true
end
 可以继承这个函数 来控制是否有半透效果  默认true
 
5 窗口内点击  半透区域点击
--窗口内点击
function prototype:onBtnBlockerBg(sender, event)
end

--半透区域点击
function prototype:onBtnMaskBg(sender, event)
    self:close()  --如果点击外部 要关闭窗口的话
end

6 窗口打开机制 OPEN_TYPE   ---没使用  默认add
function prototype:getOpenType()
	return Define.OPEN_TYPE.ADD
end
 可以继承这个函数 修改效果
 一般主窗口用only 子窗口用add
 一些特殊窗口 如新手引导主窗口也可以用add

7 窗口重开机制	RE_OPEN_TYPE
function prototype:getReOpenType()
	return Define.RE_OPEN_TYPE.ONLY
end
 可以继承这个函数 修改效果 
 比如背包的tip  希望点击不同物品 tip自动刷新 就可以使用CLOSE_BEFORE模式
 比如公共提示框 多个提示消息 可以使用OPEN_NEW模式


6 窗口打开 关闭动画
function prototype:getOpenAction()
	return "MoveIn" 
end

function prototype:getCloseAction()
	return "MoveOut"
end
 默认没有  可以在Actions/下面扩展
 使用方法：
    ui.mgr:open('Account/Login', {action='MoveIn'})
    ui.mgr:close('Account/Login', {action='MoveOut', cbFunc=cbFunc})


7 窗口内部 子控件 向本窗口 传递数据  支持多层嵌套(node套node套node...)
  事件传递方向：从child向parent  刚好和嵌套顺序相反
  
  父亲ccs中
  self:bindUIEvent("PackBox.goodInfo", "uiEvtBtnItem")
  
  子控件中
  self:fireUIEvent("PackBox.goodInfo", self.data)
  
  在公共的控件模块中 更为方便  只要定义发送的事件名称   
  不同业务的父窗口 可以共用   比如背包格式、武将头像格式等


8 窗口之间传递数据
    发送
   ui.mgr:transData("FriendView", friendViewType)

    接收 (FriendView的lua文件)
   function prototype:onTransData(friendType)
 注意：a 只有窗口间才用  Model到UI走event
 	   b 尽量少用 不方便看逻辑的来龙去脉

9 强制改变窗口优先级  一般用于特殊窗口  如：新手引导窗口
	function prototype:getPriority()
		return ui.mgr.Define.PRIORITY.GUID
	end	
--------------------------------------------]]



