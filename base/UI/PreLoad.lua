
module (..., package.seeall)

local DEBUG =  false

function loadImages(_, imgList, callback, loadingBar)
	local loadCallback = function (idx, texture)
        if texture == nil then
            log4t:w("load image failed ! image res : "..imgList[idx])
        else
            if DEBUG then
                log4t:d(texture:getPath())
                -- log4t:d(texture:getDescription())
            end
        end

        -- if loadingBar then
        -- 	local percent = idx / #imgList * 100
        -- 	loadingBar:setPercent(percent, 0.1)
        -- end

        if callback then
            callback(idx / #imgList * 100)
        end

        -- if idx == #imgList then
        -- 	if callback then
        -- 		callback()
        -- 	end
        -- end
    end

    -- if loadingBar then
    -- 	loadingBar:setPercent(0)
    -- end

    local director = cc.Director:getInstance()
    local textureCache = director:getTextureCache()

	for idx, file in ipairs(imgList) do
        textureCache:addImageAsync(file, bind(loadCallback, idx))
    end
end

function clearCache()
	local director = cc.Director:getInstance()
    local textureCache = director:getTextureCache()

	if DEBUG then
		log4t:d("-----before clear-----")
	    log4t:d(textureCache:getCachedTextureInfo())
	end
	
    -- textureCache:removeAllTextures()  --移除所有图片 texturecache不再管理 
    textureCache:removeUnusedTextures()  --能清理不用的图片

	if DEBUG then
	    log4t:d("-----end clear----")
	    log4t:d(textureCache:getCachedTextureInfo())
	end
end

