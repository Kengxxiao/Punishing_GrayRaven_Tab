XUiPanelFriendEmoji = XClass()

function XUiPanelFriendEmoji:Ctor(ui, mainPanel)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.MainPanel = mainPanel
    self:InitAutoScript()

    self.EmojiPrefab = self.GridEmoji.gameObject
    self.EmojiList = {}
    self:Init()
end

function XUiPanelFriendEmoji:Init()
    self.EmojiPrefab:SetActive(false)
    if self.EmojiPrefab == nil then
        return
    end

    local templates = XDataCenter.ChatManager.GetEmojiTemplates()
    for id, cfg in pairs(templates) do
        local luaObj = self:CreateEmoji()
        if luaObj ~= nil then
            luaObj:Refresh(id, cfg.Path)
            luaObj:Show()
            table.insert(self.EmojiList, luaObj)
        end
    end
end

function XUiPanelFriendEmoji:SetClickCallBack(cb)
    for index = 1, #self.EmojiList do
        local emoji = self.EmojiList[index]
        if emoji ~= nil then
            emoji:SetClickCallBack(cb)
        end
    end
end

function XUiPanelFriendEmoji:CreateEmoji()
    local parent = self.EmojiPrefab.transform.parent
    if parent ~= nil and self.EmojiPrefab ~= nil then
        local gameObject = CS.UnityEngine.GameObject.Instantiate(self.EmojiPrefab)
        if gameObject ~= nil then
            gameObject.transform:SetParent(parent, false)
            local luaObj = XUiGridEmoji.New(self.MainPanel, gameObject, self.MainPanel)
            return luaObj
        end
    end
    return nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelFriendEmoji:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelFriendEmoji:AutoInitUi()
    self.GridEmoji = self.Transform:Find("PanelEmojiItems/EmojiItem")
    self.BtnBack = self.Transform:Find("BtnBack"):GetComponent("Button")
end

function XUiPanelFriendEmoji:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelFriendEmoji:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelFriendEmoji:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelFriendEmoji:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
end
-- auto

function XUiPanelFriendEmoji:OnBtnBackClick( ... )
    self:Hide()
end
function XUiPanelFriendEmoji:Show()
    if not XTool.UObjIsNil(self.GameObject) and self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    end
end

function XUiPanelFriendEmoji:Hide()
    if not XTool.UObjIsNil(self.GameObject) and self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end

function XUiPanelFriendEmoji:OpenOrClosePanel(hide)
    if self.GameObject == nil then
        return
    end
    if hide ~= nil then
        self.GameObject:SetActive(hide)
        return
    end
    if self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    else
        self.GameObject:SetActive(false)
    end
end