module("Assist.Shader", package.seeall)

function create(_, vsh, fsh, node, uniform)
	-- local program = cc.GLProgram:create("resource/shaders/simple.vsh", "resource/shaders/gray.fsh")
    -- program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    -- program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    -- program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    -- program:link()
    -- program:updateUniforms()

    local program = CCGLProgramProxy:createByFile(vsh, fsh)
	local state = cc.GLProgramState:create(program)

    if node then
	    node:setGLProgramState(state)
    end

    local binds =
    {
    	["float"] = "setUniformFloat",
    	["vec2"] = "setUniformVec2",
    	["vec3"] = "setUniformVec3",
    	["vec4"] = "setUniformVec4",
    	["texture"] = "setUniformTexture",
	}

	--{type="vec2", name="u_speed", value=cc.p(10.0, -2.0)}
    for _, info in ipairs(uniform or {}) do
    	local call = state[binds[info.type]]
    	if call then
    		call(state, info.name, info.value)
    	end
    end
    return state
end

function createGray(_, sprite)
    local vsh = "resource/shaders/simple.vsh"
    local fsh = "resource/shaders/gray.fsh"
    return Assist.Shader:create(vsh, fsh, sprite)
end

function createUV(_, sprite, uSpeed, vSpeed)
    local vsh = "resource/shaders/move2right.vsh"
    local fsh = "resource/shaders/move2right.fsh"
    local info =
    {
        {type="vec2", name = "u_speed", value = cc.p(uSpeed or 0, vSpeed or 0)}
    }
    return Assist.Shader:create(vsh, fsh, sprite, info)
end


function createShade(_, sprite, spriteShade, updatePos)
    local size = sprite:getTexture():getContentSize()  --图片大小
    local sizeShade = spriteShade:getTexture():getContentSize()
    
    local anchor = sprite:getAnchorPoint()
    local anchorShade = spriteShade:getAnchorPoint()  --anchor相对于rect 可以使图片的一部分
    local scale = cc.p(size.width/sizeShade.width, size.height/sizeShade.height)
    local rectShade = spriteShade:getTextureRect()

    local info =
    {
        {type="vec2", name = "u_scale", value = scale},
        {type="texture", name = "u_texture1", value = spriteShade:getTexture()}
    }

    local vsh = "resource/shaders/simple.vsh"
    local fsh = "resource/shaders/shade.fsh"
    local programState = Assist.Shader:create(vsh, fsh, sprite, info)

    --w1 w2 h1 h2是纹理的大小
    --offx offy是两个纹理左下角的偏差
    -- p2x = (w1/w2)*p1 + (offx - rect1.x)/w2
    -- p2y = (h1/h2)*p1 + (h2 - h1 - offy - rect1.y)/w2

    --rect:实际显示的图片区域大小
    -- offx = (pos1.x - anchor1.x*rect1.w) - (pos2.x - anchor2.x*rect2.w)
    -- offy = (pos1.y - anchor1.y*rect1.h) - (pos2.y - anchor2.y*rect2.h)

    local function update()
        local posx1, posy1 = sprite:getPosition()
        local tempPos = Assist:translatePos(spriteShade, sprite:getParent())
        local posx2, posy2 = tempPos.x, tempPos.y
        local rect = sprite:getTextureRect()  --显示区域  拼图后会变化

        local frameOffset = sprite:getOffsetPosition()
        local contentSize = sprite:getContentSize()
        --拼图trim后 删除了空白部分  新图中点与原始图中点有个offset的差距
        --uv按trim后的图 而position按原始图
        local offsetPositionFromCenter = {x = frameOffset.x - (contentSize.width - rect.width) / 2, 
                                          y = frameOffset.y - (contentSize.height - rect.height)/2}

        local offsetx = (posx1 - posx2) - (anchor.x * rect.width - anchorShade.x * rectShade.width)
        offsetx = (offsetx + offsetPositionFromCenter.x - rect.x) / sizeShade.width 

        local offsety = (posy1 - posy2) - (anchor.y * rect.height - anchorShade.y * rectShade.height)
        offsety = (sizeShade.height - rect.height - offsety - offsetPositionFromCenter.y - rect.y) / sizeShade.height 

        programState:setUniformVec2("u_offset", cc.p(offsetx, offsety))
    end

    if updatePos then
        sprite:scheduleUpdateWithPriorityLua(update, 0)
    else
        update()  --执行一次
    end

    return programState
end

function createShade2(_, sprite, spriteShade, spriteShade2, updatePos)
    local size = sprite:getTexture():getContentSize()
    local sizeShade = spriteShade:getTexture():getContentSize()
    local sizeShade2 = spriteShade2:getTexture():getContentSize()    

    local anchor = sprite:getAnchorPoint()

    local scale = cc.p(size.width/sizeShade.width, size.height/sizeShade.height)
    local anchorShade = spriteShade:getAnchorPoint()
    local rectShade = spriteShade:getTextureRect()

    local scale2 = cc.p(size.width/sizeShade2.width, size.height/sizeShade2.height)
    local anchorShade2 = spriteShade2:getAnchorPoint()
    local rectShade2 = spriteShade2:getTextureRect()

    local info =
    {
        {type="vec2", name = "u_scale", value = scale},
        {type="vec2", name = "u_scale2", value = scale2},
        {type="texture", name = "u_texture1", value = spriteShade:getTexture()},
        {type="texture", name = "u_texture2", value = spriteShade2:getTexture()},
    }

    local vsh = "resource/shaders/simple.vsh"
    local fsh = "resource/shaders/shade2.fsh"
    local programState = Assist.Shader:create(vsh, fsh, sprite, info)

    local function update()
        local posx1, posy1 = sprite:getPosition()
        local tempPos = Assist:translatePos(spriteShade, sprite:getParent())
        local posx2, posy2 = tempPos.x, tempPos.y
        local rect = sprite:getTextureRect() 

        local frameOffset = sprite:getOffsetPosition()
        local contentSize = sprite:getContentSize()
        local offsetPositionFromCenter = {x = frameOffset.x - (contentSize.width - rect.width) / 2, 
                                          y = frameOffset.y - (contentSize.height - rect.height)/2}

        local offsetx = (posx1 - posx2) - (anchor.x * rect.width - anchorShade.x * rectShade.width)
        offsetx = (offsetx + offsetPositionFromCenter.x - rect.x) / sizeShade.width 

        local offsety = (posy1 - posy2) - (anchor.y * rect.height - anchorShade.y * rectShade.height)
        offsety = (sizeShade.height - rect.height - offsety - offsetPositionFromCenter.y - rect.y) / sizeShade.height 


        local posx1, posy1 = sprite:getPosition()
        local tempPos = Assist:translatePos(spriteShade2, sprite:getParent())
        local posx2, posy2 = tempPos.x, tempPos.y
        local offsetx2 = (posx1 - posx2) - (anchor.x * rect.width - anchorShade2.x * rectShade2.width)
        offsetx2 = (offsetx2 + offsetPositionFromCenter.x - rect.x) / sizeShade2.width 

        local offsety2 = (posy1 - posy2) - (anchor.y * rect.height - anchorShade2.y * rectShade2.height)
        offsety2 = (sizeShade2.height - rect.height - offsety2 - offsetPositionFromCenter.y - rect.y) / sizeShade2.height 

        programState:setUniformVec2("u_offset", cc.p(offsetx, offsety))
        programState:setUniformVec2("u_offset2", cc.p(offsetx2, offsety2))
    end

    if updatePos then
        sprite:scheduleUpdateWithPriorityLua(update, 0)
    else
        update()
    end
    
    return programState
end









