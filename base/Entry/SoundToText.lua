
function OnSTTStart()
	local stage = StageMgr:GetStage()
	if stage and stage.OnSTTStart then
		stage:OnSTTStart()
	end
end

function OnSTTUpdateVolume(volume)
	local stage = StageMgr:GetStage()
	if stage and stage.OnSTTUpdateVolume then
		stage:OnSTTUpdateVolume(volume)
	end
end

function OnSTTEnd(text, flag)
	local stage = StageMgr:GetStage()
	if stage and stage.OnSTTEnd then
		stage:OnSTTEnd(text, flag)
	end
end

function OnSTTRecord(pcm)
	local stage = StageMgr:GetStage()
	if stage and stage.OnSTTRecord then
		stage:OnSTTRecord(pcm)
	end
end


