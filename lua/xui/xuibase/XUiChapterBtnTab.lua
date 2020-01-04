XUiChapterBtnTab = XClass()

function XUiChapterBtnTab:Ctor(ui, index, callback, isLockClick)
    self.IsLockClick = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Index = index
    self.Callback = callback
    self.IsLockClick = isLockClick
    self.IsLock = false
    XTool.InitUiObject(self)
    self.Btn = self.Transform:GetComponent("Button")
    self:AutoAddListener()
    if self.Btn.gameObject:GetComponent(typeof(CS.XUiClickWidget)) == nil then
        self.WgtBtn = self.Btn.gameObject:AddComponent(typeof(CS.XUiClickWidget))
    end
end

function XUiChapterBtnTab:RegisterListener(uiNode, eventName, func)
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

function XUiChapterBtnTab:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.Btn, "onClick", self.OnBtnClick)
end

function XUiChapterBtnTab:OnBtnClick(...)
    if (self.Callback) then
        self.Callback(self.Index)
    end
end

function XUiChapterBtnTab:OnSelect(isSelected)
    if not self.IsLock then
        self.Normal.gameObject:SetActive(not isSelected)
        self.Press.gameObject:SetActive(isSelected)
    end
end

function XUiChapterBtnTab:Lock(isLocked)
    self.IsLock = isLocked
    self.Normal.gameObject:SetActive(not isLocked)
    self.Press.gameObject:SetActive(not isLocked)
    self.Disable.gameObject:SetActive(isLocked)
end

function XUiChapterBtnTab:SetName(name1, name2)
    self.TxtNormal1.text = name1
    self.TxtNormal2.text = name2
    self.TxtPress1.text = name1
    self.TxtPress2.text = name2
end

function XUiChapterBtnTab:SetPic(pic)
    self.RImgNormal:SetRawImage(pic)
    self.RImgPress:SetRawImage(pic)
end

function XUiChapterBtnTab:SetRedPoint(isActive)
    self.ImgRedTag.gameObject:SetActive(isActive)
end

function XUiChapterBtnTab:Dispose()

end