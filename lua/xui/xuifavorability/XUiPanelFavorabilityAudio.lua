XUiPanelFavorabilityAudio = XClass()
local CurrentAudioSchedule = nil

function XUiPanelFavorabilityAudio:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    XTool.InitUiObject(self)
end

-- [刷新界面]
function XUiPanelFavorabilityAudio:OnRefresh()
        self:RefreshDatas()
end

function XUiPanelFavorabilityAudio:RefreshDatas()
    local currentCharacterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local audioDatas = XFavorabilityConfigs.GetCharacterVoiceById(currentCharacterId)
    for k, v in pairs(audioDatas or {}) do
        v.IsPlay = false
    end
    self:UpdateAudioList(audioDatas, 1)
    
    local castName = XFavorabilityConfigs.GetCharacterCvById(currentCharacterId)
    local cast = (castName ~= "") and CS.XTextManager.GetText("FavorabilityCast", tostring(castName)) or "" 
    self.TxtCV.text = cast
end

-- [装载数据]
function XUiPanelFavorabilityAudio:UpdateAudioList(audioDatas, selectIdx)
    if not audioDatas then
        XLog.Warning("XUiPanelFavorabilityAudio:UpdateAudioList error: audioList is nil")
        return 
    end

    self:SortAudios(audioDatas)
    self.AudioList = audioDatas
    self.CurAudio = self.AudioList[selectIdx]

    if not self.DynamicTableAudios then
        self.DynamicTableAudios = XDynamicTableNormal.New(self.SViewAudioList.gameObject)
        self.DynamicTableAudios:SetProxy(XUiGridLikeAudioItem)
        self.DynamicTableAudios:SetDelegate(self)
    end

    self.DynamicTableAudios:SetDataSource(self.AudioList)
    self.DynamicTableAudios:ReloadDataASync()
end

function XUiPanelFavorabilityAudio:SortAudios(audios)
    -- 已解锁，可解锁，未解锁
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    for k, audio in pairs(audios) do
        local isUnlock = XDataCenter.FavorabilityManager.IsVoiceUnlock(characterId, audio.Id)
        local canUnlock = XDataCenter.FavorabilityManager.CanVoiceUnlock(characterId, audio.Id)
        
        audio.priority = 2
        if not isUnlock then
            audio.priority = canUnlock and 1 or 3
        end
    end
    table.sort(audios, function(audioA, audioB)
        if audioA.priority == audioB.priority then
            return audioA.Id < audioB.Id
        else
            return audioA.priority < audioB.priority
        end
    end)
end

-- [监听动态列表事件]
function XUiPanelFavorabilityAudio:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.AudioList[index]
        if data ~= nil then
            grid:OnRefresh(self.AudioList[index], index)
        end
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if self.CurAudio and self.AudioList[index] then
            if self.CurAudio.Id == self.AudioList[index].Id and self.CurrentPlayAudio and self.CurAudio.IsPlay then
                self:UnScheduleAudio()
                self.CurAudio.IsPlay = false
                grid:OnRefresh(self.CurAudio, index)
                return 
            end
        end
        self.CurAudio = self.AudioList[index]
        if not self.CurAudio then return end
        self:OnAudioClick(self.CurAudio, grid, index)
    end
end

function XUiPanelFavorabilityAudio:ResetPlayStatus(index)
    for k, v in pairs(self.AudioList) do
        v.IsPlay = (k==index)
        local grid = self.DynamicTableAudios:GetGridByIndex(k)
        if grid then
            grid:OnRefresh(v, k)
        end
    end
end

function XUiPanelFavorabilityAudio:UpdateGrids()
    for i=1, #self.AudioList do
        local grid = self.DynamicTableAudios:GetGridByIndex(i)
        if grid then
            grid:UpdatePlayStatus()
        end
    end
end

-- [音频按钮点击事件]
function XUiPanelFavorabilityAudio:OnAudioClick(clickAudio, grid, index)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsVoiceUnlock(characterId, clickAudio.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanVoiceUnlock(characterId, clickAudio.Id)

    if isUnlock then
        self:UnScheduleAudio()
        self:ResetPlayStatus(index)
        local isFinish = false
        local progress = 0
        local updateCount = 0
        self.CurrentPlayAudio = CS.XAudioManager.PlayCv(clickAudio.CvId)
        self.UiRoot:PlayCvContent(clickAudio.CvId)
        CurrentAudioSchedule = CS.XScheduleManager.Schedule(function()
            if self.CurrentPlayAudio.Done then
                if self.CurrentPlayAudio.Duration <= 0 then return end
                progress = self.CurrentPlayAudio.Time / self.CurrentPlayAudio.Duration
                if progress >= 1 then
                    progress = 1
                    isFinish = true
                end
                if grid:GetAudioDataId() == clickAudio.Id then
                    grid:UpdateProgress(progress)
                    grid:UpdateMicroAlpha(updateCount)
                end
                updateCount = updateCount + 1
            end
            if not self.CurrentPlayAudio or isFinish then 
                self:UnScheduleAudio()
                clickAudio.IsPlay = false
                if grid:GetAudioDataId() == clickAudio.Id then
                    grid:UpdatePlayStatus()
                    grid:UpdateProgress(0)
                end
            end
        end, 20, 0)
    else
        if canUnlock then
            XDataCenter.FavorabilityManager.OnUnlockCharacterVoice(characterId, clickAudio.Id, function(res)
                self:RefreshDatas()
            end, clickAudio.Name)
        else
            XUiManager.TipMsg(clickAudio.ConditionDescript)
        end
    end
end

function XUiPanelFavorabilityAudio:UnScheduleAudio()
    if CurrentAudioSchedule then
        CS.XScheduleManager.UnSchedule(CurrentAudioSchedule)
        CurrentAudioSchedule = nil
    end
    if self.CurrentPlayAudio then
        CS.XAudioManager.Stop(self.CurrentPlayAudio)
        self.UiRoot:StopCvContent()
        self.CurrentPlayAudio = nil
    end
end

function XUiPanelFavorabilityAudio:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    else
        self:UnScheduleAudio()
    end
end

function XUiPanelFavorabilityAudio:OnClose()
    self:UnScheduleAudio()
end

return XUiPanelFavorabilityAudio
