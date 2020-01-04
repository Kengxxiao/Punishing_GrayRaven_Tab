local XUiDormBgm = XClass()
local XUiDormBgmGrid = require("XUi/XUiDormSecond/XUiDormBgmGrid")

function XUiDormBgm:Ctor(uiroot, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.PlayingIndex = -1
    self.PlayingId = -1
    self.PlayRecordId = -1
    self.IsSelfRoom = false
    self.ShowList = false
    XTool.InitUiObject(self)
    self:InitBgmList()

    self.UiRoot:RegisterClickEvent(self.BtnClick, function() self:OnBtnClick()
    end)

    self.BtnNext.CallBack = function() self:PlayNext() end
end

function XUiDormBgm:InitBgmList()
    self.DynamicTable = XDynamicTableNormal.New(self.ViewSongList.gameObject)
    self.DynamicTable:SetProxy(XUiDormBgmGrid)
    self.DynamicTable:SetDelegate(self)
end

function XUiDormBgm:UpdateBgmList(dormId, isSelf)
    self.IsSelfRoom = isSelf
    local room = XHomeDormManager.GetRoom(dormId)
    local configs = room:GetAllFurnitureCongfig()

    local result, musicList = XDormConfig.GetDormBgm(configs)
    self.Data = musicList


    self.ShowList = false
    if not result then
        self.PlayingIndex = 1
        self:Play(result, musicList[self.PlayingIndex])
        self.ShowList = false
        self.ViewSongList.gameObject:SetActiveEx(self.ShowList)
        self.GameObject:SetActiveEx(false)
        return
    end

    if not musicList then
        return
    end

    self.GameObject:SetActiveEx(isSelf)

    self.BtnNext.gameObject:SetActiveEx(#musicList > 1)
    self.BtnClick.gameObject:SetActiveEx(#musicList > 1)

    self.PlayingIndex = 1
    self.PlayRecordId = isSelf and CS.UnityEngine.PlayerPrefs.GetInt(tostring(dormId), -1) or -1

    for i, v in ipairs(musicList) do
        if self.PlayRecordId == v.BgmId then
            self.PlayingIndex = i
        end
    end

    self:Play(result, musicList[self.PlayingIndex])
    self.ViewSongList.gameObject:SetActiveEx(self.ShowList and #musicList > 1)


    if self.ShowList then
        self:ReloadBgmList()
    end
end

function XUiDormBgm:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(index, self.Data[index])
        grid:SetSelect(self.PlayingIndex == index)
        if self.PlayingIndex == index then
            self.SelectGrid = grid
        end
    end
end

function XUiDormBgm:SelectBgm(index, bgmConfig)
    self.ShowList = false
    self.ViewSongList.gameObject:SetActiveEx(self.ShowList)

    if self.PlayingIndex == index then
        return
    end

    if self.SelectGrid then
        self.SelectGrid:SetSelect(false)
    end

    self.SelectGrid = self.DynamicTable:GetGridByIndex(index)
    if self.SelectGrid then
        self.SelectGrid:SetSelect(true)
    end

    self.PlayingIndex = index
    self:Play(true, bgmConfig)
end

function XUiDormBgm:ReloadBgmList()
    self.DynamicTable:SetDataSource(self.Data)
    self.DynamicTable:ReloadDataSync()
end

function XUiDormBgm:PlayNext()
    local index = self.PlayingIndex + 1
    if index > #self.Data then
        index = 1
    end

    self:SelectBgm(index, self.Data[index])
end

function XUiDormBgm:Play(result, bgmConfig)
    self.TxtSong.text = bgmConfig.Name

    if self.PlayingId == bgmConfig.BgmId then
        return
    end

    self.PlayingId = bgmConfig.BgmId
    self.UiRoot:PlayBgmMusic(result, bgmConfig)
end

function XUiDormBgm:OnBtnClick()
    self.ShowList = not self.ShowList
    self.ViewSongList.gameObject:SetActiveEx(self.ShowList)
    self:ReloadBgmList()
end

function XUiDormBgm:OnEnable(dormId)
    self:ResetBgmList(dormId, self.IsSelfRoom)
end

function XUiDormBgm:IsMusicListChange(newList)

    if not newList or not self.Data then
        return true
    end

    if #newList ~= #self.Data then
        return true
    end


    for i, v in ipairs(newList) do
        local isChanged = true
        for idx, var in ipairs(self.Data) do
            if v.BgmId == var.BgmId then
                isChanged = false
            end
        end


        if isChanged then
            return true
        end
    end

    return false
end

function XUiDormBgm:ResetBgmList(dormId, isSelf)
    local room = XHomeDormManager.GetRoom(dormId)
    local configs = room:GetAllFurnitureCongfig()
    local result, musicList = XDormConfig.GetDormBgm(configs)

    local isChanged = self:IsMusicListChange(musicList)

    self.Data = musicList
    self.PlayRecordId = isSelf and CS.UnityEngine.PlayerPrefs.GetInt(tostring(dormId), -1) or -1

    if isChanged then
        self.PlayRecordId = -1
    end

    if not result then
        self.PlayingIndex = 1
        self:Play(result, musicList[self.PlayingIndex])
        self.ShowList = false
        self.ViewSongList.gameObject:SetActiveEx(self.ShowList)
        self.GameObject:SetActiveEx(false)
        return
    end


    if not musicList then
        return
    end
    self.GameObject:SetActiveEx(isSelf)

    self.BtnNext.gameObject:SetActiveEx(#musicList > 1)
    self.BtnClick.gameObject:SetActiveEx(#musicList > 1)

    self.ViewSongList.gameObject:SetActiveEx(self.ShowList and #musicList > 1)
    if self.ShowList then
        self:ReloadBgmList()
    end

    local isExist = false
    for i, v in ipairs(self.Data) do
        if self.PlayRecordId == v.BgmId then
            self.PlayingIndex = i
            isExist = true
        end
    end


    if not isExist then
        self.PlayingIndex = 1
        self:Play(result, musicList[self.PlayingIndex])
    end
end

function XUiDormBgm:OnDisable()
    self.ViewSongList.gameObject:SetActiveEx(self.ShowList)
end

return XUiDormBgm