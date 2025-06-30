module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local GAME_RULES_LIST = {
	"Kadang",
	"Niuniu",
	"Paodekuai",
	"Shisanshui",
	"Mushiwang"
}

function prototype:enter(gameName)
	--log("GameHelpView ========> "..gameName)
	self:setSelectTabData(gameName)
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:setSelectTabData(gameName)
	local selIndex = 1
    if gameName and gameName ~= "" then
        for i, v in ipairs(GAME_RULES_LIST) do
        	if string.find(gameName, v) then
        		selIndex = i
        		break
        	end
        end
    end

    local data = db.mgr:getDB("gameRules", {itemName = GAME_RULES_LIST[selIndex]})
    if data and #data > 0 then
    	local ruleInfo = data[1]
		self.txtContent:setString(ruleInfo.desc)
	else
		self.txtContent:setString("暂时没有帮助")
    end
end


function prototype:onPanelCloseClick()
	self:close()
end


