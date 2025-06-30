module(..., package.seeall)

class = Logic.class:subclass()
 
local NiuNiu_pb = NiuNiu_pb

function class:initialize()
	super.initialize(self)

end

--五小牛：所有牌均小于5，点数总和小于等于10，例如A/A/2/2/3。
function class:isSmallNiu(cards)
	local sum = 0
    local size = 0
    local isLess = true
    for i = 1, #cards do
        size = cards[i].size
        if size >= 5 then
            isLess = false   
            break
        end
        sum = sum + size
    end

    if isLess == false then
        return false
    end

    if sum <= 10 then
        return true
    else
        return false
    end
end

function class:isBomb(cards)
	if cards[1].size == cards[4].size then
        return true  
    elseif cards[2].size == cards[5].size then
        return true
    else  
        return false
    end  
end

function class:isGoldNiu(cards)
	if cards[1].size > 10 then
        return true
    else  
        return false
    end
end

function class:isSilverNiu(cards)
	if cards[2].size > 10 and cards[1].size == 10 then
        return true
    else
        return false
    end  
end

function class:getNiuOrderGroup(cards)
    if not cards or #cards == 0 then
        return {}
    end

    table.sort(cards, function (a, b)
        return a.size < b.size
    end)

    local lave = 0     --余数
    local size = 0
    for i = 1, #cards do
        size = cards[i].size
        if size > 10 then
            size = 10
        end
        lave = lave + size
    end

    lave = lave % 10
    for i = 1, #cards - 1 do
        for j = i + 1, #cards do
            local iSize = cards[i].size
            local jSize = cards[j].size
            if iSize > 10 then iSize = 10 end
            if jSize > 10 then jSize = 10 end

            if(iSize + jSize) % 10 == lave then
                local result = {}
                for index = 1, #cards do
                    if index ~= i and index ~= j then
                        --前三张
                        table.insert(result, 1, cards[index])
                    else
                        --后两张
                        table.insert(result, cards[index])
                    end
                end

                return result
            end
        end
    end
  
    return cards
end

function class:getNiubyCards(cards)
	local lave = 0     --余数
	local size = 0
    for i = 1, #cards do
    	size = cards[i].size
    	if size > 10 then
    		size = 10
    	end
        lave = lave + size
    end

    lave = lave % 10
    for i = 1, #cards - 1 do
        for j = i + 1, #cards do
        	local iSize = cards[i].size
        	local jSize = cards[j].size
        	if iSize > 10 then iSize = 10 end
        	if jSize > 10 then jSize = 10 end

            if(iSize + jSize) % 10 == lave then
                if lave == 0 then
                    return 10
                else
                    return lave
                end  
            end
        end
    end
  
    return 0
end

function class:getTypeByCards(cards)
    if not cards or #cards == 0 then
        return NiuNiu_pb.NiuNone
    end

    table.sort(cards, function (a, b)
	    return a.size < b.size
	end)

    local cardType = NiuNiu_pb.NiuNone

    if self:isSmallNiu(cards) then  
        cardType = NiuNiu_pb.WuXiaoNiu
        return cardType  
    end

    if self:isGoldNiu(cards) then  
        cardType = NiuNiu_pb.WuHuaNiu  
        return cardType  
    end

    if self:isBomb(cards) then  
        cardType = NiuNiu_pb.Bomb  
        return cardType  
    end
  
    cardType = self:getNiubyCards(cards)  
      
    return cardType  
end 

