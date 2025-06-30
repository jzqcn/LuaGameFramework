module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	for i, v in ipairs(data) do
		self["imgFace_"..i]:setTag((index-1)*5+i)
        self["imgFace_"..i]:loadTexture(string.format("%s%d.png", v.res,1))
        self["imgFace_"..i]:setScale(1.5)
	end
	self.data = data
end

function prototype:onImgFaceClick(sender,eventType)
    -- log("sender : "..sender:getTag()%4)
    local num=sender:getTag()%5
    if num==0 then
        num=5
    end
    self:fireUIEvent("GameChat.Text", self.data[num])
end
