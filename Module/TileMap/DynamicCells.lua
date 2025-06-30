module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, viewSize)
    self.map = map
    self.viewSize = viewSize

    self.cells = {}
    self.pos = { x = math.huge, y = math.huge, }
end

function class:dispose()
    super.dispose(self)
end

function class:update(x, y)
    local size = self.viewSize
    local cx, cy = self.pos.x, self.pos.y
    -- log("dy update")
    -- log(size, cx, cy, x, y)
    if math.abs(x - cx) < size.width and math.abs(y - cy) < size.height then
    	self.cells = {}
        return
    end

    self.pos.x, self.pos.y = x, y
    self.cells = self:updateCells(x, y)
end

function class:getCells()
	return self.cells
end

--  private  --
function class:updateCells(x, y)
    local x1, y1 = x + self.viewSize.width * 3, y + self.viewSize.height * 2.5
    local x2, y2 = x - self.viewSize.width * 2, y - self.viewSize.height * 1.5

    local cx1, cy1 = self.map:world2cell(x1, y1)
    local cx2, cy2 = self.map:world2cell(x2, y2)

    local x3, y3 = x2, y1
    local x4, y4 = x1, y2
    local cx3, cy3 = self.map:world2cell(x3, y3)
    local cx4, cy4 = self.map:world2cell(x4, y4)

    local d = cx1 - cx3
    local cols = d + ((cy3 -d) >= cy1 and 1 or 0)

    local cells = {}
    for i = 0, cols - 1 do
        local cx = cx3 + i
        local cy = cy3 - i

        local cxe = cx2 + i
        local cye = cy2 - i

        self:updateVLine(cx, cy, cxe, cye, cells)
         if cx == cx1 and cy == cy1 then
            break   
         end

        self:updateVLine(cx+1, cy, cxe, cye-1, cells)
    end
    return cells
end

function class:updateVLine(cx1, cy1, cx2, cy2, cells)
    for cx = cx1, cx2 do
        local cy = cy1 + cx - cx1
        local index = self.map:cell2index(cx, cy)
        cells[index] = index
    end
end

function class:updateCells_old(x, y)
    local wx1, wy1 = x + self.viewSize.width * 2, y + self.viewSize.height * 2
    local wx2, wy2 = x - self.viewSize.width * 1, y - self.viewSize.height * 1
    local cx1, cy1 = self.map:world2cell(wx1, wy1)
    local cx2, cy2 = self.map:world2cell(wx2, wy2)

    cy1 = cy1 - 0
    cy2 = cy2 + 2

    local cells = {}
    for i = 0, (cy2 + cx2) - (cy1 + cx1) do
        local lx = cx1 + math.modf((i + 1) / 2)
        local ly = cy1 + math.modf((i + 0) / 2)
        for j = 0, (cy2 - cx2) - (cy1 - cx1), 2 do
            local cx = lx - j / 2
            local cy = ly + j / 2
            local index = self.map:cell2index(cx, cy)
            cells[index] = index
        end
    end
    return cells
end
