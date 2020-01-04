XUiBtnTitleItem = XClass()

function XUiBtnTitleItem:Ctor(ui,panelChatContent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.PanelChatContent = panelChatContent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBtnTitleItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiBtnTitleItem:AutoInitUi()
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.TxtTitleDis = self.Transform:Find("TxtTitleDis"):GetComponent("Text")
    self.BtnToggle = self.Transform:GetComponent("Toggle")
    self.BgSel = self.Transform:Find("BgSel")
    self.BgDis = self.Transform:Find("BgDis")
    self.BgNol = self.Transform:Find("BgNol")
end

function XUiBtnTitleItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiBtnTitleItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTitleItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBtnTitleItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnToggle, "onValueChanged", self.OnToggleClick)
end
-- auto
function XUiBtnTitleItem:OnToggleClick( code )
    if self.index == 2 or self.index == 3 then
        return
    end
    if code then
        -- self.PanelChatContent:RefreshChatList(self.index)
    end
end

function XUiBtnTitleItem:SetData( title,index,panel )
    self.title = title
    self.index = index
    self.panel = panel
    if index == 1 then
        if self.BtnToggle.isOn then
            self:OnToggleClick(true)
        else
            self.BtnToggle.isOn = true
        end
    else
        if self.BtnToggle.isOn then
            self.BtnToggle.isOn = false
        else
            self:OnToggleClick(false)
        end
    end
     if self.index == 2 or self.index == 3 then
        self.TxtTitleDis.text = title
        self.TxtTitle.gameObject:SetActive(false)
        self.TxtTitleDis.gameObject:SetActive(true)
        self.BgSel.gameObject:SetActive(false)
        self.BgDis.gameObject:SetActive(true)
        self.BgNol.gameObject:SetActive(false)
    else
        self.TxtTitle.text = title
        self.TxtTitle.gameObject:SetActive(true)
        self.TxtTitleDis.gameObject:SetActive(false)
        self.BgSel.gameObject:SetActive(true)
        self.BgDis.gameObject:SetActive(false)
        self.BgNol.gameObject:SetActive(false)
    end
end
return XUiBtnTitleItem
