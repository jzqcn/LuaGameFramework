module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:refresh(info, index)
   if info~=nil then   
        self.dealerName:setString(info.playerName)
        self.dealerID:setString("ID:" .. info.playerId)
        self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(info.coin))
        if info.headimage ==nil then
            self.imgFrame:loadTexture("resource/Dantiao/csbimages/systemDealer.png")
        else
            -- sdk.account:getHeadImage(info.playerId, info.playerName, self.imgFrame, info.headimage)
            if self:existEvent('LOAD_HEAD_IMG') then
                self:cancelEvent('LOAD_HEAD_IMG')
            end
            sdk.account:loadHeadImage(info.playerId, info.playerName, info.headimage, 
                self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgFrame)

        end
        if info.isDealer==true then
            self.dealerState:setString("正在坐庄")
        else
            self.dealerState:setString("等待坐庄")
        end
   end
end

function prototype:onLoadHeadImage(filename)
    self.imgFrame:loadTexture(filename)
end
