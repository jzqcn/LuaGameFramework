module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize()
    self.nottipAtAll = {}
    self.popupTextNum = 0
end


-- data =
-- {
--  content        : 内容
--  okFunc         : 确认回调
--  cancelFunc     : 取消回调
--  okBtnTitle     : 确认按钮标题
--  cancelBtnTitle : 取消按钮标题
--  notTipAtAll    : 不再提示
-- }
function class:open(data)
    if type(data) == "string" then
        data = {content = data,}
    end

    if data.notTipAtAll == nil then
        ui.mgr:open("Dialog/ConfirmDlg", data)
        return
    end

    if self.nottipAtAll[data.notTipAtAll] ~= nil then
        data.okFunc()
    else
        self.nottipAtAll[data.notTipAtAll] = true
        ui.mgr:open("Dialog/ConfirmDlg", data)
    end
end



-- data = 
-- {
--     content         : 内容
--     color           : 字符颜色
--     fontSize        : 字体大小
-- }
function class:popup(data)
    local node = cc.Node:create()
    local labTip =  ccui.Text:create()

    if type(data) == "string" then
        data = {content = data, color = cc.c3b(0, 255, 0),}
    end

    labTip:setString(data.content)
    labTip:setFontSize(data.fontSize or 20)

    if data.color then
        data.color.a = data.color.a or 255
        labTip:setTextColor(data.color)
    end
    node:addChild(labTip)

    self.popupTextNum = self.popupTextNum + 1

    local viewsize = cc.Director:getInstance():getWinSize()
    local runningScence = cc.Director:getInstance():getRunningScene()
    node:setPosition(cc.p(viewsize.width/2, viewsize.height/2))
    runningScence:addChild(node)

    local action = cc.MoveBy:create(0.6, cc.p(0, viewsize.height/2 - 30 * self.popupTextNum))
    local delay = cc.DelayTime:create(1)
    local fadeOut = cc.FadeOut:create(0.2)
    local callFunc = cc.CallFunc:create(function() 
                            node:removeFromParent(true)
                            self.popupTextNum = self.popupTextNum - 1
                        end)

    local seq = cc.Sequence:create(action, delay, fadeOut, callFunc)
    node:runAction(seq)
end