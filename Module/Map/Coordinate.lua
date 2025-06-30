module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map)
    self.map = map
    self.info = map:getInfo()

    self.cellMaskAdd = self.info.rows * 2
    self.cellMask = 10 ^ string.len(tostring(self.cellMaskAdd))
    self.signMaskAdd = self.info.mRows * 2
    self.signMask = 10 ^ string.len(tostring(self.signMaskAdd))
end

--tileMap use
function class:cell2world(cx, cy)
    local x = self.info.ox + (cx - cy) * self.info.cw / 2
    local y = self.info.oy + (cx + cy) * self.info.ch / 2

    y = self.info.h - y
    return x, y
end

function class:world2cell(x, y)
    x = math.modf(x)
    y = math.modf(y)
    y = self.info.h - y

    x = x - self.info.ox
    y = y - self.info.oy

    local cx = (y / self.info.ch + x / self.info.cw)
    local cy = (y / self.info.ch - x / self.info.cw)
    cx = math.modf(cx + 0.5 * (cx < 0 and -1 or 1))
    cy = math.modf(cy + 0.5 * (cy < 0 and -1 or 1))
    cx = cx == -0 and 0 or cx
    cy = cy == -0 and 0 or cy
    return cx, cy
end

function class:cell2index(cx, cy)
    cx = cx + self.cellMaskAdd
    cy = cy + self.cellMaskAdd
    return cy * self.cellMask + cx
end

function class:index2cell(index)
    local x = index % self.cellMask 
    local y = (index - x) / self.cellMask 
    x = x - self.cellMaskAdd
    y = y - self.cellMaskAdd
    return x, y
end

---mask use
function class:maskCell2world(cx, cy)
    local x = self.info.mOx + (cx - cy) * self.info.mw / 2
    local y = self.info.mOy + (cx + cy) * self.info.mh / 2

    y = self.info.h - y
    return x, y
end

function class:maskWorld2cell(x, y)
    x = math.modf(x)
    y = math.modf(y)
    y = self.info.h - y

    x = x - self.info.mOx
    y = y - self.info.mOy

    local cx = (y / self.info.mh + x / self.info.mw)
    local cy = (y / self.info.mh - x / self.info.mw)
    cx = math.modf(cx + 0.5 * (cx < 0 and -1 or 1))
    cy = math.modf(cy + 0.5 * (cy < 0 and -1 or 1))
    cx = cx == -0 and 0 or cx
    cy = cy == -0 and 0 or cy
    return cx, cy
end

function class:maskCell2index(cx, cy)
    cx = cx + self.signMaskAdd
    cy = cy + self.signMaskAdd
    return cy * self.signMask + cx
end

function class:maskIndex2cell(index)
    local x = index % self.signMask 
    local y = (index - x) / self.signMask 
    x = x - self.signMaskAdd
    y = y - self.signMaskAdd
    return x, y
end

function class:getCellAround(cx, cy)
    local x, y
    if nil == cy then
        local cellIdx = cx
        x, y = self:maskIndex2cell(cellIdx)
    else
        x, y = cx, cy
    end

    local cells = {}
    for i = x - 1, x + 1 do
        for j = y - 1, y + 1 do
            if not (i == x and j == y) then
                table.insert(cells, {x = i, y = j})
            end
        end
    end
    return cells
end

function class:getCtrlLine(cx, cy, pA, pB)
    local cellIdx = self:maskCell2index(cx, cy)
    if(not self.info.partBlockListMap[cellIdx]) then
        return false, nil
    end 

    local lineIndex = self.info.blockLineListMap[cellIdx]
    local line = self.info.blockLineList[lineIndex]
    local posList = self:getIntersectPointList(line, pA, pB)
    if(table.empty(posList)) then
        return true, nil
    end

    return self:getClosedPoint(posList, pA)
end

function class:getBlockIntersectPos(cx, cy, pA, pB)
    local line = {}
    local x, y = self:maskCell2world(cx, cy)

    local p1 = {}
    p1[1] = x
    p1[2] = y - self.info.mh/2
    table.insert(line, p1)

    local p2 = {}
    p2[1] = x - self.info.mw/2
    p2[2] = y
    table.insert(line, p2)

    local p3 = {}
    p3[1] = x 
    p3[2] = y + self.info.mh/2
    table.insert(line, p3)

    local p4 = {}
    p4[1] = x + self.info.mw/2
    p4[2] = y
    table.insert(line, p4)

    local posList = self:getIntersectPointList(line, pA, pB)
    if(table.empty(posList)) then
        return false, nil
    end

    return self:getClosedPoint(posList, pA)
end

function class:getIntersectPointList(line, pA, pB)
    local posList = {}
    for i = 1, #line do 
        local pC, pD
        if(i == #line) then
            pC = cc.p(line[i][1], line[i][2])
            pD = cc.p(line[1][1], line[1][2])
        else 
            pC = cc.p(line[i][1], line[i][2])
            pD = cc.p(line[i+1][1], line[i+1][2])
        end

        if(cc.pIsSegmentIntersect(pA, pB, pC, pD)) then
            local intersectPos = cc.pGetIntersectPoint(pA, pB, pC, pD)
            if(intersectPos.x ~= 0 or intersectPos.y ~= 0) then
                table.insert(posList, intersectPos)
            end
        end
    end

    return posList
end

function class:getClosedPoint(posList, pA)
    if(table.empty(posList)) then
        return true, nil
    else
        local minPos = nil
        local minDis = 0
        for _, pos in pairs(posList) do 
            local dis = cc.pGetDistance(pA, pos)
            if(minDis == 0) then
                minDis = dis
                minPos = pos 
            elseif(dis < minDis) then
                minDis = dis 
                minPos = pos 
            end
        end 
        return true, minPos
    end
end

function class:getBlockCellList(bPosx, bPosy, cellx1, celly1, cellx2, celly2, ePosx, ePosy)
    local blockCellList = {}
    local mapInfo = self.info

    if(self.map:isBlock(cellx1, celly1)) then
        local index = self:maskCell2index(cellx1, celly1)
        blockCellList[index] = {x = cellx1, y =celly1}
    end
    if(self.map:isBlock(cellx2, celly2)) then
        local index = self:maskCell2index(cellx2, celly2)
        blockCellList[index] = {x = cellx2, y =celly2}
    end


    if(cellx1 == cellx2 and celly1 == celly2) then
        return blockCellList
    end

    --获取行走射线方向经过的blockcell
    if(math.abs(cellx2 - cellx1) >= math.abs(celly1 - celly2)) then
        local minX = math.min(cellx1, cellx2)
        local maxX = math.max(cellx1, cellx2)

        for i = minX, maxX-1 do
            repeat
                local pos1x, pos1y = self:maskCell2world(i, celly1)
                local pos2x, pos2y = self:maskCell2world(i, celly2)

                if(celly1 == celly2) then
                    if(self.map:isBlock(i, celly1)) then
                        local index = self:maskCell2index(i, celly1)
                        blockCellList[index] = {x = i, y =celly1}
                    end
                    break
                elseif(celly1 > celly2) then
                    pos2x = pos2x + mapInfo.mh/2
                    pos1y = pos1y - mapInfo.mw/2
                elseif(celly1 < celly2) then
                    pos1x = pos1x + mapInfo.mw/2
                    pos2y = pos2y - mapInfo.mh/2            
                end

                local intersectPos = cc.pGetIntersectPoint(cc.p(bPosx, bPosy), cc.p(ePosx, ePosy), cc.p(pos1x, pos1y), cc.p(pos2x, pos2y))
                --第一个cell
                local mx, my = self:maskWorld2cell(intersectPos.x, intersectPos.y)
                mx = i
                if(self.map:isBlock(i, my)) then
                    local index = self:maskCell2index(mx, my)
                    blockCellList[index] = {x = mx, y =my}
                end
                --第一个cell
                mx = i + 1
                if(self.map:isBlock(mx, my)) then
                    local index = self:maskCell2index(mx, my)
                    blockCellList[index] = {x = mx, y =my}
                end
                break
            until true
        end

        --修正计算影响cell数量
        if math.abs(cellx2 - cellx1) == math.abs(celly1 - celly2) then
            local dv = cellx2 - cellx1 > 0 and 1 or -1
            local mx = cellx1
            local my = celly1
            for i = cellx1 + dv, cellx2 - dv, dv do 
                mx = mx + dv
                if (cellx2 - cellx1) == (celly2 - celly1) then
                    my = my + dv
                else 
                    my = my - dv
                end
                if(self.map:isBlock(mx, my)) then
                    local index = self:maskCell2index(mx, my)
                    blockCellList[index] = {x = mx, y = my}
                end
            end

        end
    else 
        local minY = math.min(celly1, celly2)
        local maxY = math.max(celly1, celly2)

        for i = minY, maxY-1 do
            repeat
                local pos1x, pos1y = self:maskCell2world( cellx1, i)
                local pos2x, pos2y = self:maskCell2world( cellx2, i)

                if(cellx1 == cellx2) then
                    if(self.map:isBlock(cellx1, i)) then
                        local index = self:maskCell2index(cellx1, i)
                        blockCellList[index] = {x = cellx1, y = i}
                    end
                    break
                elseif(cellx1 > cellx2) then
                    pos1y = pos1y - mapInfo.mh/2
                    pos2x = pos2x - mapInfo.mw/2
                elseif(cellx1 < cellx2) then
                    pos1x = pos1x - mapInfo.mw/2
                    pos2y = pos2y - mapInfo.mh/2                
                end
                local intersectPos =  cc.pGetIntersectPoint(cc.p(bPosx, bPosy), cc.p(ePosx, ePosy), cc.p(pos1x, pos1y), cc.p(pos2x, pos2y))
                --第一个cell
                local mx, my = self:maskWorld2cell(intersectPos.x, intersectPos.y)
                my = i
                if(self.map:isBlock(mx, my)) then
                    local index = self:maskCell2index(mx, my)
                    blockCellList[index] = {x = mx, y =my}
                end
                --第一个cell
                my = i + 1
                if(self.map:isBlock(mx, my)) then
                    local index = self:maskCell2index(mx, my)
                    blockCellList[index] = {x = mx, y =my}
                end
                break
            until true
        end
    end

    return blockCellList
end