XUiBtnTab = XClass()

function XUiBtnTab:Ctor(ui, index, callback, isLockClick)
    self.IsLockClick = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Index = index
    self.Callback = callback
    self.IsLockClick = isLockClick

    self:InitAutoScript()

    if (self.ImgLock) then
        self.ImgLock.gameObject:SetActive(false)
    end
    if (self.TxtNormal) then
        self.TxtNormal.gameObject:SetActive(true)
    end
    if (self.TxtSelected) then
        self.TxtSelected.gameObject:SetActive(false)
    end

    if self.Btn.gameObject:GetComponent(typeof(CS.XUiClickWidget)) == nil then
        self.WgtBtn = self.Btn.gameObject:AddComponent(typeof(CS.XUiClickWidget))
    end
    -- self.WgtBtn:AddPointerDownListener(function(eventData) self:OnDown() end)
end

-- function XUiBtnTab:OnDown()
--     if (self.TxtNormal) then
--         self.TxtNormal.gameObject:SetActive(false)
--     end
--     if (self.TxtSelected) then
--         self.TxtSelected.gameObject:SetActive(true)
--     end
-- end
-- auto
-- Automatic generation of code, forbid to edit
function XUiBtnTab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiBtnTab:AutoInitUi()
    self.Btn = self.Transform:GetComponent("Button")
    self.Image = self.Transform:GetComponent("Image")

    local lock = self.Transform:Find("ImgLock")
    if (lock) then
        self.ImgLock = lock:GetComponent("Image")
    end

    local normal = self.Transform:Find("TxtNormal")
    if (normal) then
        self.TxtNormal = normal:GetComponent("Text")
    end

    local normalEn = self.Transform:Find("TxtNormal/TxtNormalEn")
    if (normalEn) then
        self.TxtNormalEn = normalEn:GetComponent("Text")
    end

    local locktxt = self.Transform:Find("TxtLock")
    if (locktxt) then
        self.TxtLock = locktxt:GetComponent("Text")
    end

    local lockEn = self.Transform:Find("TxtLock/TxtLockEn")
    if (lockEn) then
        self.TxtLockEn = lockEn:GetComponent("Text")
    end

    local selected = self.Transform:Find("TxtSelected")
    if (selected) then
        self.TxtSelected = selected:GetComponent("Text")
    end

    local selectedEn = self.Transform:Find("TxtSelected/TxtSelectedEn")
    if (selectedEn) then
        self.TxtSelectedEn = selectedEn:GetComponent("Text")
    end

    self.tag = self.Transform:Find("PanelTag")
    if (self.tag) then
        self.TxtTag = self.Transform:Find("PanelTag/TxtTag"):GetComponent("Text")
    end
end

function XUiBtnTab:RegisterListener(uiNode, eventName, func)
    if not uiNode then return end
    local key = eventName .. uiNode:GetHashCode()
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTab:RegisterListener: func is not a function")
        end

        listener = function(...)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBtnTab:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.Btn, "onClick", self.OnBtnClick)
end
-- auto
function XUiBtnTab:OnBtnClick(...)
    if (self.Callback) then
        self.Callback(self.Index)
    end
end

function XUiBtnTab:OnSelect(isSelected)
    self.Btn.interactable = not isSelected
    if (self.TxtNormal) then
        self.TxtNormal.gameObject:SetActive(not isSelected)
    end
    if (self.TxtSelected) then
        self.TxtSelected.gameObject:SetActive(isSelected)
    end

    if (self.TxtLock) then
        self.TxtLock.gameObject:SetActive(false)
    end
end

function XUiBtnTab:Lock(isLocked)
    if self.IsLockClick then
        self.Image.enabled = true
    else
        self.Image.enabled = not isLocked
    end

    if (self.ImgLock) then
        self.ImgLock.gameObject:SetActive(isLocked)
    end

    if (self.TxtLock) then
        self.TxtLock.gameObject:SetActive(isLocked)
    end

    if (self.TxtSelected) then
        self.TxtSelected.gameObject:SetActive(isLocked)
    end

    if (self.TxtNormal) then
        self.TxtNormal.gameObject:SetActive(isLocked)
    end
end

function XUiBtnTab:SetName(name, nameEn)
    if (self.TxtNormal) then
        self.TxtNormal.text = name
    end
    if (self.TxtSelected) then
        self.TxtSelected.text = name
    end
    if (self.TxtLock) then
        self.TxtLock.text = name
    end

    if self.TxtNormalEn and nameEn then
        self.TxtNormalEn.text = nameEn
    end
    if self.TxtSelectedEn and nameEn then
        self.TxtSelectedEn.text = nameEn
    end
    if self.TxtLockEn and nameEn then
        self.TxtLockEn.text = nameEn
    end
end

function XUiBtnTab:Dispose()
    self.Callback = nil
    self.GameObject = nil
    self.Transform = nil
    self.Index = nil
    self.Btn = nil
    self.Image = nil

    if self.ImgLock then
        self.ImgLock = nil
    end

    if self.TxtNormal then
        self.TxtNormal = nil
    end

    if self.TxtSelectedEn then
        self.TxtSelectedEn = nil
    end

    if self.TxtNormalEn then
        self.TxtNormalEn = nil
    end

    if self.TxtLock then
        self.TxtLock = nil
    end
    if self.TxtLockEn then
        self.TxtLockEn = nil
    end
    if self.TxtTag then
        self.TxtTag = nil
    end
end