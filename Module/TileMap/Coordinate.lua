module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(info)
    self.info = info

    self.cellMask = 10 ^ string.len(tostring(info.rows))
    self.cellMaskAdd = info.rows * 2
end

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
