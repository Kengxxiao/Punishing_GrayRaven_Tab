XUiPanelWriteDiary = XClass()

function XUiPanelWriteDiary:Ctor(ui,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    if self.Update then
        behaviour.LuaUpdate = function() 
            self:Update()
         end
    end
    self.inputText = self.Transform:Find("PanelInput/BtnInputField/Text"):GetComponent("Text")
end

function XUiPanelWriteDiary:Update( ... )
    self.TxtNum.text = (self.inputText.cachedTextGenerator.characterCount - 1).."/".."100"
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelWriteDiary:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelWriteDiary:AutoInitUi()
    self.BtnBack = self.Transform:Find("BtnBack"):GetComponent("Button")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.PanelInput = self.Transform:Find("PanelInput")
    self.TxtNum = self.Transform:Find("PanelInput/TxtNum"):GetComponent("Text")
    self.BtnInputField = self.Transform:Find("PanelInput/BtnInputField"):GetComponent("InputField")
    self.BtnConfirm = self.Transform:Find("BtnConfirm"):GetComponent("Button")
end

function XUiPanelWriteDiary:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelWriteDiary:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelWriteDiary:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelWriteDiary:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnConfirm, "onClick", self.OnBtnConfirmClick)
end
-- auto

function XUiPanelWriteDiary:OnBtnBackClick(...)
    self.GameObject.gameObject:SetActive(false)
end

function XUiPanelWriteDiary:OnBtnInputFieldClick(...)

end

function XUiPanelWriteDiary:OnBtnConfirmClick(...)
    local content = self.BtnInputField.text
    if string.IsNilOrEmpty(content) then
        self.BtnInputField.text = ''
        return
    end
    self.BtnInputField.text = ''
    if self.Callback then
        self.Callback(content)
    end
    self.GameObject.gameObject:SetActive(false)
end

function XUiPanelWriteDiary:InitializationView( ... )
    self.BtnInputField.characterLimit = 100;
    self.BtnInputField.lineType = 1
    self.BtnInputField.text = ''
end

function XUiPanelWriteDiary:OpenView(cb)
    self:InitializationView()
    self.Callback = cb
    self.GameObject.gameObject:SetActive(true)
end
return XUiPanelWriteDiary
