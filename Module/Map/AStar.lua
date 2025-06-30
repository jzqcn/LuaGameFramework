
module (..., package.seeall)

local POS_TYPE = enum
{
    "NEW", 
    "OPEN",
    "CLOSE",
}

class = objectlua.Object:subclass()

function class:initialize(map)
    super.initialize(self)

    self.map = map
end

function class:dispose()
    super.dispose(self)
end

function class:reset()
    self.cellsInfo = {}
    self.openList = {}
    self.closeList = {}
    self.startIdx = nil
    self.endIdx = nil
    self.find = false
end

function class:getPath(startIdx, endIdx)
    endIdx = self:getNearTargetPos(startIdx, endIdx)

    if startIdx == endIdx then
        return {}
    end

    self:reset()

    self.startIdx = startIdx
    self.endIdx = endIdx

    self:putToOpen(startIdx)

    local passTimes = 0 
    local MAX_STEP_TIMES = 1000;   --防止数据出错 死循环

    while #self.openList > 0 and not self.find and passTimes < MAX_STEP_TIMES do
        self:stepFind()
        passTimes = passTimes + 1
    end

    if table.empty(self.openList) then
        return {}
    end

    local cells = self:getFindPath()
    return cells
end



----------private-------------
function class:getNearTargetPos(startIdx, endIdx)
    if not self.map:isBlock(endIdx) then
        return endIdx
    end

    local x1, y1 = self.map:maskIndex2cell(startIdx)
    local x2, y2 = self.map:maskIndex2cell(endIdx)

    for i = x2, x1, (x2>x1 and -1 or 1) do
        for j = y2, y1, (y2>y1 and -1 or 1) do
            if not self.map:isBlock(i, j) then
                return self.map:maskCell2index(i, j)
            end
        end
    end
    return startIdx
end


function class:refCellInfo(cellIdx)
    local info = self.cellsInfo[cellIdx]
    if nil == info then
        info =
        {
            index = cellIdx, 
            isBlock = self.map:isBlock(cellIdx),
            parent = nil,
            posType = POS_TYPE.NEW,
            F = 0, G = 0, H = 0,
        }
        self.cellsInfo[cellIdx] = info
    end
    return info
end

function class:putToOpen(cellIdx)
    local cellInfo = self.cellsInfo[cellIdx]
    if nil == cellInfo then
        cellInfo = self:refCellInfo(cellIdx)
        table.insert(self.openList, cellIdx)
    else
        local pos = 1
        for i = #self.openList, 1, -1 do
            local openInfo = self.cellsInfo[self.openList[i]]
            if openInfo.F >= cellInfo.F then
                pos = i + 1
                break
            end
        end
        table.insert(self.openList, pos, cellIdx)
    end

    cellInfo.posType = POS_TYPE.OPEN
end

function class:putToClose(cellIdx)
    table.insert(self.closeList, cellIdx)
    local cellInfo = self:refCellInfo(cellIdx)
    cellInfo.posType = POS_TYPE.CLOSE
end

function class:popMinFInOpen()
    return table.remove(self.openList)
end

function class:getStepGValue(cellIdx, cellIdxParent)
    local x1, y1 = self.map:maskIndex2cell(cellIdx)
    local x2, y2 = self.map:maskIndex2cell(cellIdxParent)

    if x1 == x2 or y1 == y2 then
        return 10
    else
        return 14
    end
end

function class:getHValue(cellIdx, endIdx)
    local x1, y1 = self.map:maskIndex2cell(cellIdx)
    local x2, y2 = self.map:maskIndex2cell(endIdx)

    return (math.abs(x2-x1) + math.abs(y2-y1)) * 10
end

function class:computeStepCell(cellIdx, cellIdxParent)
    local cellInfo = self:refCellInfo(cellIdx)
    local parentCellInfo = self:refCellInfo(cellIdxParent)

    local stepG = self:getStepGValue(cellIdx, cellIdxParent)
    local G = parentCellInfo.G + stepG
    local H = self:getHValue(cellIdx, self.endIdx)
    local F = G + H
    return F, G, H
end

function class:stepFind()
    local cellIdx = self:popMinFInOpen()
    self:putToClose(cellIdx)

    local cellInfo = self:refCellInfo(cellIdx)
    local cells = self.map:getCellAround(cellIdx)

    for _, info in ipairs(cells) do
        repeat
            local subCellIdx = self.map:maskCell2index(info.x, info.y)
            local subCellInfo = self:refCellInfo(subCellIdx)

            if subCellIdx == self.endIdx then
                self.find = true
                subCellInfo.parent = cellInfo
                return
            end

            if subCellInfo.isBlock then
                break
            end

            local F, G, H = self:computeStepCell(subCellIdx, cellIdx)
            if subCellInfo.posType == POS_TYPE.NEW then  --新点 直接入open队列
                subCellInfo.F = F
                subCellInfo.G = G
                subCellInfo.H = H
                subCellInfo.parent = cellInfo
                self:putToOpen(subCellIdx)

            elseif subCellInfo.posType == POS_TYPE.OPEN then --已在open队列的点 如果f更小 则更新之
                if subCellInfo.F > F then
                    subCellInfo.F = F
                    subCellInfo.G = G
                    subCellInfo.H = H
                    subCellInfo.parent = cellInfo
                end
            end
        until true
    end
end

function class:getFindPath()
    local path = {}
    local cellInfo = self.cellsInfo[self.endIdx]
    while cellInfo and cellInfo.parent do
        table.insert(path, cellInfo.index)
        cellInfo = cellInfo.parent
    end

    return list.reverse(path)
end
