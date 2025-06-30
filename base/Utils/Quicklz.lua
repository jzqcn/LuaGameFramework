module("util.quicklz", package.seeall)


function zip(_, data)
	return UtilQuickLZDeflate(data)
end	


function unzip(_, data)
	return UtilQuickLZInflate(data)
end	

