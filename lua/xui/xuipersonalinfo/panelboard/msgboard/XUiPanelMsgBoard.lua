XUiPanelMsgBoard = XClass()

function XUiPanelMsgBoard:Ctor(ui,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.XUiPanelWriteDiary = XUiPanelWriteDiary.New(self.PanelWriteDiary,self.RootUi)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelMsgBoard:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelMsgBoard:AutoInitUi()
    self.PanelScrollView = self.Transform:Find("PanelScrollView"):GetComponent("ScrollRect")
    self.PanelMsgBoardItem = self.Transform:Find("PanelScrollView/Viewport/Content/PanelMsgBoardItem")
    self.PanelBtnBrief = self.Transform:Find("PanelScrollView/Viewport/Content/PanelInfoMsgItem/PanelTxt/PanelBtnBrief")
    self.PanelWriteDiary = self.Transform:Find("PanelWriteDiary")
end

function XUiPanelMsgBoard:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelMsgBoard:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelMsgBoard:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelMsgBoard:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelMsgBoard:SetIsShow( code )
    if self.GameObject ~= nil then
        self.GameObject.gameObject:SetActive(code)
    end
end

function XUiPanelMsgBoard:ResetPanel( ... )
    self.PanelMsgBoardItem.gameObject:SetActive(false)
    self.PanelWriteDiary.gameObject:SetActive(false)
end

function XUiPanelMsgBoard:Refresh()
    XDataCenter.PersonalInfoManager.PanelMsgBoard = self
    self:ResetPanel()
    XDataCenter.PersonalInfoManager.CreateItems(self.RootUi, self.PanelMsgBoardItem, self.PanelMsgBoardItem.gameObject.transform.parent, 1,nil ,XDataCenter.PersonalInfoManager.ItemPanelType.NorDaily,function(items)
        self:SetIsShow(true)
        self:MoveToBottom()
    end)
end

function XUiPanelMsgBoard:MoveToBottom( ... )
    if self.PanelScrollView ~= nil then
        CS.UnityEngine.Canvas.ForceUpdateCanvases();
        self.PanelScrollView.verticalNormalizedPosition = 0
        CS.UnityEngine.Canvas.ForceUpdateCanvases()
    end
end

return XUiPanelMsgBoard
