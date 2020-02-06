XUiPanelMsgBoardItem = XClass()

local BriefStatus = {
    Open = 1,
    Close = 2,
}
function XUiPanelMsgBoardItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.XUiPanelLeaveMsgDetail = XUiPanelLeaveMsg.New(self.PanelLeaveMsg, self.RootUi)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelMsgBoardItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelMsgBoardItem:AutoInitUi()
    self.PanelTxt = self.Transform:Find("PanelTxt")
    self.TxtContent = self.Transform:Find("PanelTxt/TxtContent"):GetComponent("Text")
    self.BtnContent = self.Transform:Find("PanelTxt/BtnContent"):GetComponent("Button")
    self.TxtLeaveMsg = self.Transform:Find("PanelTxt/BtnContent/BtnLeaveMsg/TxtLeaveMsg"):GetComponent("Text")
    if not XTool.UObjIsNil(self.Transform:Find("PanelTxt/BtnContent/BtnLeaveMsg")) then
        self.BtnLeaveMsg = self.Transform:Find("PanelTxt/BtnContent/BtnLeaveMsg"):GetComponent("Button")
    end
    if not XTool.UObjIsNil(self.Transform:Find("PanelTxt/BtnContent/BtnComment")) then
        self.BtnComment = self.Transform:Find("PanelTxt/BtnContent/BtnComment"):GetComponent("Button")
    end
    if not XTool.UObjIsNil(self.Transform:Find("PanelTop/BtnEditor")) then
        self.BtnBan = self.Transform:Find("PanelTop/BtnEditor"):GetComponent("Toggle")
        self.BtnBan.isOn = false
    end
    if not XTool.UObjIsNil(self.Transform:Find("PanelTxt/BtnContent/BtnDelete")) then
        self.BtnDelete = self.Transform:Find("PanelTxt/BtnContent/BtnDelete"):GetComponent("Button")
    end
    self.BtnPraise = self.Transform:Find("PanelTxt/BtnContent/BtnPraise"):GetComponent("Button")
    self.TxtLeaveMsgA = self.Transform:Find("PanelTxt/BtnContent/BtnPraise/TxtLeaveMsg"):GetComponent("Text")
    self.PanelLeaveMsg = self.Transform:Find("PanelTxt/PanelLeaveMsg")
    self.BtnBackBrief = self.Transform:Find("PanelTxt/PanelBtnBrief/BtnBackBrief"):GetComponent("Button")
    self.PanelTop = self.Transform:Find("PanelTop")
    self.ImgIcon = self.Transform:Find("PanelTop/ImgIcon"):GetComponent("Image")
    self.TxtName = self.Transform:Find("PanelTop/TxtName"):GetComponent("Text")
    if not XTool.UObjIsNil(self.Transform:Find("PanelTxt/BtnContent/Image/TxtTime")) then
        self.TxtTime = self.Transform:Find("PanelTxt/BtnContent/Image/TxtTime"):GetComponent("Text")
    else
        self.TxtTime = self.Transform:Find("PanelTop/TxtTime"):GetComponent("Text")
    end
end

function XUiPanelMsgBoardItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelMsgBoardItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelMsgBoardItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelMsgBoardItem:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnContent, self.OnBtnContentClick)
    if not XTool.UObjIsNil(self.BtnLeaveMsg) then
        XUiHelper.RegisterClickEvent(self, self.BtnLeaveMsg, self.OnBtnLeaveMsgClick)
    end
    if not XTool.UObjIsNil(self.BtnComment) then
        XUiHelper.RegisterClickEvent(self, self.BtnComment, self.OnBtnCommentClick)
    end
    if not XTool.UObjIsNil(self.BtnBan) then
        self:RegisterListener(self.BtnBan, "onValueChanged", self.OnBtnBanClick)
    end
    if not XTool.UObjIsNil(self.BtnDelete) then
        XUiHelper.RegisterClickEvent(self, self.BtnDelete, self.OnBtnDeleteClick)
    end
    XUiHelper.RegisterClickEvent(self, self.BtnPraise, self.OnBtnPraiseClick)
    XUiHelper.RegisterClickEvent(self, self.BtnBackBrief, self.OnBtnBackBriefClick)
end
-- auto
function XUiPanelMsgBoardItem:OnBtnContentClick(...)

end

function XUiPanelMsgBoardItem:OnBtnLeaveMsgClick(...)--打开留言
    XDataCenter.PersonalInfoManager.RefreshLeaveMsgData(self.data.Id,self.pageNum, function(...)
            self.XUiPanelLeaveMsgDetail:Refresh(self)
            self.BtnBackBrief.gameObject.transform.parent.gameObject:SetActive(true)
        end)
end

function XUiPanelMsgBoardItem:OnBtnCommentClick(...)
    XDataCenter.PersonalInfoManager.OpenInputView(function(content)
            XDataCenter.PersonalInfoManager.AddLeaveMsg(self.data.PlayerId, self.data.Id, content, function(...)
                    self.data.LeaveMsgCount = self.data.LeaveMsgCount + 1
                    self.TxtLeaveMsg.text = "(" .. self.data.LeaveMsgCount .. ")"
                    self:OnBtnLeaveMsgClick()
                end)
        end)
end

function XUiPanelMsgBoardItem:OnBtnBanClick(isOn)
    if isOn then
        XDataCenter.PersonalInfoManager.BanWriteMsg(self.data.Id, function(...)
            end)--禁止留言
    end
end

function XUiPanelMsgBoardItem:OnBtnDeleteClick(...)
    local removeTip = CS.XTextManager.GetText("IsSureDelete")
    XUiManager.DialogTip("", removeTip, XUiManager.DialogType.Normal, nil, function(...)
            XDataCenter.PersonalInfoManager.DeleteDaily(self.data.Id, function(...)
                    XDataCenter.PersonalInfoManager.RefreshDailyData(self.pageNum,
                        function( ... )
                            XDataCenter.PersonalInfoManager.PanelMsgBoard:Refresh()
                        end)
                end)--删除日记
        end)
end

function XUiPanelMsgBoardItem:OnBtnPraiseClick(...)
    if self.data ~= nil then
        XDataCenter.PersonalInfoManager.GiveALike(self.data.PlayerId, self.data.Id, function(code)
                local text = code and tonumber(self.data.UpCount) + 1 or tonumber(self.data.UpCount) - 1
                self.data.UpCount = text
                self.TxtLeaveMsgA.text = "(" .. tostring(text) .. ")"
            end)
    end
end

function XUiPanelMsgBoardItem:OnBtnBackBriefClick(...)--合起
    self.PanelLeaveMsg.gameObject:SetActive(false)
    self.BtnBackBrief.gameObject.transform.parent.gameObject:SetActive(false)
end

function XUiPanelMsgBoardItem:SetIsShow(code)
    if self.GameObject then
        self.GameObject.gameObject:SetActive(code)
    end
end

function XUiPanelMsgBoardItem:SetProperty(data, index, pageNum)
    self.data = data
    if(self.data.CurrHeadPortraitId==0) then self.data.CurrHeadPortraitId=1001 end
    self.index = index
    self.pageNum = pageNum
    self:RefreshPanel()
end

function XUiPanelMsgBoardItem:RefreshPanel()
    if not self.data then
        return
    end
    self.PanelLeaveMsg.gameObject:SetActive(false)
    self.BtnBackBrief.gameObject.transform.parent.gameObject:SetActive(false)
    self.TxtName.text = self.data.Name
    self.TxtContent.text = self.data.Content
    self.TxtLeaveMsg.text = "(" .. self.data.LeaveMsgCount .. ")"
    self.TxtLeaveMsgA.text = "(" .. self.data.UpCount .. ")"
    self.TxtTime.text = XUiHelper.CalcLatelyLoginTime(self.data.CreateTime)
    self.RootUi:SetUiSprite(self.ImgIcon, XPlayerManager.GetHeadPortraitInfoById(self.data.CurrHeadPortraitId).ImgSrc)
    self:SetIsShow(true)
end

return XUiPanelMsgBoardItem