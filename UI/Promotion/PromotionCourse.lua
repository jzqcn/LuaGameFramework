module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	if not Model:get("Account"):isEnabledPromotion() then
		self.imgBg:loadTexture("resource/csbimages/Promotion/promotionCourse.png")
	end
end

function prototype:setPromotionInfo(info)

end
