XUiPanelEmoji = XClass()

function XUiPanelEmoji:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.GameObject.gameObject:SetActive(false)
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()

    self.BtnBack.CallBack = function() self:Hide() end

    self.EmojiPrefab = self.GridEmoji.gameObject
    self.EmojiList = {}
    self:Init()
end

function XUiPanelEmoji:Init()
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

function XUiPanelEmoji:SetClickCallBack(cb)
    for index = 1, #self.EmojiList do
        local emoji = self.EmojiList[index]
        if emoji ~= nil then
            emoji:SetClickCallBack(cb)
        end
    end
end

function XUiPanelEmoji:CreateEmoji()
    local parent = self.EmojiPrefab.transform.parent
    if parent ~= nil and self.EmojiPrefab ~= nil then
        local gameObject = CS.UnityEngine.GameObject.Instantiate(self.EmojiPrefab)
        if gameObject ~= nil then
            gameObject.transform:SetParent(parent, false)
            local luaObj = XUiEmojiItem.New(self.RootUi, gameObject)
            return luaObj
        end
    end
    return nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelEmoji:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelEmoji:AutoInitUi()
    self.GridEmoji = self.Transform:Find("EmojiList/EmojiItem")
end

function XUiPanelEmoji:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelEmoji:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPanelEmoji:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelEmoji:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelEmoji:Show()
    if not XTool.UObjIsNil(self.GameObject) and self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    end
end

function XUiPanelEmoji:Hide()
    if not XTool.UObjIsNil(self.GameObject) and self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end

function XUiPanelEmoji:OpenOrClosePanel()
    if self.GameObject == nil then
        return
    end
    self.GameObject:SetActive(not self.GameObject.activeSelf)
end