local XUiReport = XLuaUiManager.Register(XLuaUi, "UiReport")

function XUiReport:OnStart(playerId, playerName, playerLevel, chatContent)
    self.PlayerId = playerId
    self.PlayerName = playerName
    self.TxtReportName.text = playerName
    self.PlayerLevel = playerLevel
    self.ChatContent = chatContent

    self.BtnClose.CallBack = function() self:OnBtnClose() end
    self.BtnConfirm.CallBack = function() self:OnBtnConfirm() end

    self.TimerId = CS.XScheduleManager.ScheduleForever(function()
        self.TxtCount.text = (self.InputField.textComponent.cachedTextGenerator.characterCount - 1) .. "/100"
    end, 300)

    self.MainTabs = {}
    self.CurSelectMainIndex = 0
    self.SubTabs = {}
    self.CurSelectSubIndex = 0
    self:UpdateTabs()
end

function XUiReport:OnDestroy()
    self:RemoveTimer()
end

function XUiReport:RemoveTimer()
    if self.TimerId then
        CS.XScheduleManager.UnSchedule(self.TimerId)
        self.TimerId = nil
    end
end

function XUiReport:UpdateTabs()
    local data = XReportConfigs.GetReportCfg()
    for k, v in pairs(data) do
        if v.ParentId == 0 then
            if not self.MainTabs[k] then
                local tabObj = CS.UnityEngine.Object.Instantiate(self.UiObj:GetPrefab("BtnReportType"))
                tabObj.transform:SetParent(self.PanelSelectGroup.transform, false)
                local xUiButton = tabObj:GetComponent("XUiButton")
                xUiButton:SetName(v.Name)
                table.insert(self.MainTabs, k, xUiButton)
            end
        end
    end
    self.PanelSelectGroup:Init(self.MainTabs, function(index) self:OnMainTab(index) end)
end

function XUiReport:OnMainTab(index)
    self.InputField.text = ""
    self.CurSelectMainIndex = index
    self:UpdateSubTabs(index)
end

function XUiReport:UpdateSubTabs(index)
    --clean
    for k, v in pairs(self.SubTabs) do
        CS.UnityEngine.GameObject.Destroy(v.gameObject)
    end
    self.SubTabs = {}
    local data = XReportConfigs.GetReportCfg()
    local count = 1
    for k, v in pairs(data) do
        if v.ParentId == index then
            local tabObj = CS.UnityEngine.Object.Instantiate(self.UiObj:GetPrefab("BtnReportSubType"))
            tabObj.transform:SetParent(self.PanelSelectSubGroup.transform, false)
            local xUiButton = tabObj:GetComponent("XUiButton")
            xUiButton:SetName(v.Name)
            self.SubTabs[k] = xUiButton
            count = count + 1
        end
    end
    self.PanelSelectSubGroup:Init(self.SubTabs, function(index) self:OnSubTab(index) end)
end

function XUiReport:OnBtnClose()
    self:Close()
end

--玩法选择
function XUiReport:OnSubTab(index)
    local data = XReportConfigs.GetReportCfg()
    for k, v in pairs(data) do
        if v.Id == index then
            self.InputField.text = CS.XTextManager.GetText("ReportTemplate", tostring(v.Name))
        end
    end
    self.CurSelectSubIndex = index
end

function XUiReport:OnBtnConfirm()
    if self.CurSelectMainIndex == 0 then
        XUiManager.TipText("ReportSelectTypeError")
        return
    end
    XDataCenter.ReportManager.Report(self.PlayerId, self.PlayerName, self.CurSelectMainIndex, self.CurSelectSubIndex, self.InputField.text, self.PlayerLevel, self.ChatContent)
    self:Close()
end