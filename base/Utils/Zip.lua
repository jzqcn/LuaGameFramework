module("util.zip", package.seeall)


function zip(_, data)
	return UtilZlibDeflate(data)
end	


function unzip(_, data)
	return UtilZlibInflate(data)
end	

