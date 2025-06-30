
CNetMgr.SendMsg = bind(CNetMgrSendMsg, CNetMgr:GetSingleton())


--REFLECT_EVENT_CHECK_NETWORK
--无论状态是否改变 都会调用
function OnNetworkStatusChanged(newStatus, oldStatus)
	util:setNetType(newStatus, oldStatus)
end

function OnNetworkConnect(socketId, succ)
	net.mgr:onNetworkConnect(socketId, succ)
end

function OnNetworkRead(socketId, data)
	net.mgr:onNetworkRead(socketId, data)
end

function OnNetworkClosed(socketId)
	net.mgr:onNetworkClosed(socketId)
end

function OnHttpRespose(reqId, data)
	net.http:onRespose(reqId, data)
end

function OnHttpError(reqId, code)
	net.http:onError(reqId, code)
end



