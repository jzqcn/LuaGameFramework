module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:getConfigInfo()
	return {}
end

function prototype:refresh(data)
	self.clubId = data.clubId
	self.data = data
	self.configItem = {}
	-- log(data)
	if data.config then
		local y = self.size.height
		local lastHight = 0
		local configInfo = self:getConfigInfo(true)
		for i, v in ipairs(configInfo) do
			local msg = data.config[v.key]
			if type(msg) == "string" and string.len(msg) > 0 then
				local beignIndex, endIndex = string.find(msg,"|")
               	local name = string.sub(msg, 1, beignIndex - 1)
	            local param = string.sub(msg, endIndex + 1, -1)
	            -- log("beignIndex:"..beignIndex..", endIndex:"..endIndex..", name:"..name..", param:"..param)
	            beignIndex, endIndex = string.find(param, "#")
	            
	            local showStrTable = nil
	            local valueStrTable = nil
	            if beignIndex then
	            	showStrTable = string.split(string.sub(param, 1, beignIndex - 1), ";")
	           	 	valueStrTable = string.split(string.sub(param, endIndex + 1, -1), ";")
	            else
	            	showStrTable = string.split(param, ";")
	            end
	            	
            	local txtType = v.txtType
            	local node = self:getLoader():loadAsLayer("Hall/CreateRoom/"..txtType)
            	node:setConfigParam(name, v, showStrTable, valueStrTable)

            	if v.hide then
            		node:setVisible(false)
            	else
            		y = y - lastHight
            		lastHight = node:getShowHeight()
            	end
            	
            	node:setPosition(0, y-node:getContentSize().height)
            	
            	self.rootNode:addChild(node)

            	self[v.key] = node
            	self.configItem[v.key] = node
	        end
		end
	else
		log4ui:warn("get game card config error !")
	end
end

function prototype:createCardRoomByConfig()
	log("CommonConfig::createCardRoomByConfig")
end
