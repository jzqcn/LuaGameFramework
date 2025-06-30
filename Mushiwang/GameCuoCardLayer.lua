local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter(data)
    if data==nil then
        return
    end
    --初始偏移
    self.beginoffset = 10
    self.m_pListenerNodes = {}; -- 监听的牌
    self.m_pShowedNode = {};  -- 已经显示出来的牌
    self.widget = {};
    self.m_endRub = false;
    local clipper = cc.ClippingNode:create();
    clipper:setPosition(0, 50 );
    self.widget.Panel_out = clipper;
    self.widget.Panel_out.m_srcPosition = cc.p( 0, 50  )

    --牌
    local faceNode = cc.Node:create()
    local cardImg = ccui.ImageView:create() 
    cardImg:loadTexture(string.format("resource/Mushiwang/big_card/%d%d.png",data.color,data.size));
    cardImg:setPosition(cc.p( 640,-268 ))

    cardImg:setRotation(90 );
    faceNode:addChild( cardImg,10)
    cardImg:setScale( 1.2 );
    self.widget.Panel_out[ "Image_card" ] = cardImg;
    self.widget.Panel_out[ "Image_card" ].m_srcPositionY = -268;

    --白片
    local writeImg = ccui.ImageView:create() 
    writeImg:loadTexture("resource/Mushiwang/big_card/zhedang.png");--
    writeImg:setAnchorPoint(cc.p(0, 1));
    writeImg:setPosition(cc.p( 0, 680 ))
    cardImg:addChild( writeImg, 11 )
    self.widget.Panel_out[ "Image_card" ].writeImg1 = writeImg;

    local writeImg2 = ccui.ImageView:create() 
    writeImg2:loadTexture("resource/Mushiwang/big_card/zhedang.png");
    writeImg2:setAnchorPoint(cc.p(0, 1));
    writeImg2:setPosition(cc.p( 446, 0 ))
    writeImg2:setRotation( 180 );
    cardImg:addChild( writeImg2, 11 )
    self.widget.Panel_out[ "Image_card" ].writeImg2 = writeImg2;

    --牌背
    local pbImg2 = ccui.ImageView:create() 
    pbImg2:loadTexture("resource/Mushiwang/big_card/CardBack.png");
    pbImg2:setPosition(cc.p( 640, 224 ))
    pbImg2:setRotation( 90 );
    faceNode:addChild( pbImg2 )
    self.widget.Panel_out[ "Image_card_0" ] = pbImg2;
    self.widget.Panel_out[ "Image_card_0" ].m_srcPositionY = 224;

    ---///////////////裁剪模板
    local stencil = cc.Sprite:create("resource/Mushiwang/big_card/Bg.jpg");
    stencil:setAnchorPoint(cc.p(0.5, 1 ));
    stencil:setPosition(cc.p( 640, 0 ))
    
    local stencil2 = cc.Sprite:create("resource/Mushiwang/big_card/zhezhao.png");
    stencil2:setAnchorPoint(cc.p(0, 0));
    stencil2:setPosition(cc.p( 667 - (340 * 1.024), 720 ))
    stencil:addChild( stencil2 );

    
    stencil2:setScaleX( 0.2 );

    local stencil3 = cc.Sprite:create("resource/Mushiwang/big_card/zhezhao.png" );
    stencil3:setAnchorPoint(cc.p(0, 0));
    stencil3:setPosition(cc.p( 667 + (340 * 1.024), 720 )) 
    stencil:addChild( stencil3 );
    stencil3:setScaleX( -0.2 );
    ---------------------------------------------------------------------------------------------------------
 
    self.widget.Panel_out.m_stencil2 = stencil2;
    self.widget.Panel_out.m_stencil3 = stencil3;
    self.widget.Panel_out.m_stencil = stencil;
    ----------------------------------------------------------------------------------------------------

    clipper:setStencil(stencil);    -- 设置裁剪模板 //3
    clipper:setInverted(true);     -- 设置底板可见
    clipper:setAlphaThreshold(0.1); -- 设置绘制底板的Alpha值为0
    clipper:addChild( faceNode ); -- 5
    self:addChild( clipper, 100 )
  
    self:registerTouchEvend()
    self:beginRubCardAction()
    if data.needCuoCard==false then
        self:setRubEnd()
    end
end 

--[[立刻关闭自己
function prototype:immediatelyClose()
    self:close()
end]]
--开始搓牌动画
function prototype:beginRubCardAction()
    --更新
    local function update()
        self:update();
    end
    self:scheduleUpdateWithPriorityLua( update, 0)
end

--更新
function prototype:update()
    local diffy = self.widget.Panel_out:getPositionY() - self.widget.Panel_out.m_srcPosition.y;
    self.widget.Panel_out[ "Image_card" ]:setPositionY( self.widget.Panel_out[ "Image_card" ].m_srcPositionY + diffy );
    self.widget.Panel_out[ "Image_card_0" ]:setPositionY( self.widget.Panel_out[ "Image_card_0" ].m_srcPositionY - diffy);
    --放大
    local sc = 1 + (diffy - 50 )/ 50 * 0.05;
    if sc > 1.2 then
        sc = 1.2;
    elseif sc < 1.024 then
        sc = 1.024;
    end
    self.widget.Panel_out[ "Image_card" ]:setScale( sc );

    --裁剪
    local sctmp1 = 0.8 * ( sc - 1.024 )  / 0.2;
    local sctmp2 = (340 * sc);

    self.widget.Panel_out.m_stencil2:setPositionX( 667 - sctmp2 );
    self.widget.Panel_out.m_stencil2:setScaleX( 0.2 + sctmp1 );

    self.widget.Panel_out.m_stencil3:setPositionX( 667 + sctmp2 );
    self.widget.Panel_out.m_stencil3:setScaleX( -0.2 - sctmp1 );
end


-- 触摸事件
function prototype:registerTouchEvend()
    if self.m_pListener then
        return;
    end 
    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler( function(touch, event) 

        if self.m_endRub == true then
            return true;
        end

        self.widget.Panel_out:stopAllActions();

        local diffy = self.widget.Panel_out:getPositionY() - self.widget.Panel_out.m_srcPosition.y;
        if math.abs( diffy ) < self.beginoffset then
            self.widget.Panel_out:setPositionY( self.widget.Panel_out.m_srcPosition.y + self.beginoffset  );
        end

        self.widget.Panel_out.m_touchSrcPosition = cc.p( self.widget.Panel_out:getPosition() );
        return true; 
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    self.m_pListener:registerScriptHandler( function(touch, event)  
            if self.m_endRub then
                return;
            end

            local startPos = touch:getStartLocation();
            local movetPos = touch:getLocation();

            if self.widget.Panel_out.m_touchSrcPosition == nil then
                self.widget.Panel_out.m_touchSrcPosition = cc.p( self.widget.Panel_out:getPosition() );
            end

            local diffy = self.widget.Panel_out.m_touchSrcPosition.y + (movetPos.y - startPos.y);

            if  diffy  - self.widget.Panel_out.m_srcPosition.y < self.beginoffset then
                --最小
                self.widget.Panel_out:setPositionY( self.widget.Panel_out.m_srcPosition.y + self.beginoffset  );
            else
                --最大
                if diffy  - self.widget.Panel_out.m_srcPosition.y > 268 then
                    self.widget.Panel_out:setPositionY( self.widget.Panel_out.m_srcPosition.y + 268  );

                    --搓翻
                    self:setRubEnd();
                else
                    self.widget.Panel_out:setPositionY( diffy );
                end
        
            end
            
    end, cc.Handler.EVENT_TOUCH_MOVED)

    self.m_pListener:registerScriptHandler( function(touch, event)  
            --回退
            if self.m_endRub == false then
                self.widget.Panel_out:runAction( cc.MoveTo:create( 0.1, self.widget.Panel_out.m_srcPosition ) )
            end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_pListener, self )
end 


--检测搓完
function prototype:setRubEnd()
    --end
    --结束
    self.m_endRub = true;

    --开始动画阶段
    self:RubCardAction();
end


--搓牌动画阶段
function prototype:RubCardAction()

    --牌背不可见
    self.widget.Panel_out[ "Image_card_0" ]:setVisible( false );

    -- self.widget.Panel_out:runAction( cc.MoveTo:create( 0.1, self.widget.Panel_out.m_srcPosition ) )
    --self.widget.Panel_out[ "Image_card" ]:runAction( cc.ScaleTo:create(0.4, 1, 1 )  );

    performWithDelay( self, function()
        --动画结束回调
        self:spineEnd();
    end, 0.4)

    
end


--spine动画结束
function prototype:spineEnd()
    self:unscheduleUpdate();
    self.widget.Panel_out:setPosition( self.widget.Panel_out.m_srcPosition )
    self.widget.Panel_out[ "Image_card" ]:setScale( 1 );
    self.widget.Panel_out[ "Image_card" ]:setPositionY( self.widget.Panel_out[ "Image_card_0" ].m_srcPositionY );
    self.widget.Panel_out[ "Image_card_0" ]:setVisible( false );

    local act = cc.Sequence:create( cc.FadeOut:create( 0.5 ), cc.DelayTime:create( 0.7 ), cc.CallFunc:create(function ()
            self:fireUIEvent("Game.CuoCard")
            self:close()
    end)  )
    self.widget.Panel_out[ "Image_card" ].writeImg1:runAction( act );
    self.widget.Panel_out[ "Image_card" ].writeImg2:runAction(cc.FadeOut:create( 0.5 ));
end
