XUiPanelPersonalDetailsCombat = XClass()

function XUiPanelPersonalDetailsCombat:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
    self.ItemsList = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPersonalDetailsCombat:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelPersonalDetailsCombat:AutoInitUi()
    self.PanelGird = self.Transform:Find("PanelGird")
    self.PanelPersonalDetailsCombatItem = self.Transform:Find("PanelGird/PanelPersonalDetailsCombatItem")
end

function XUiPanelPersonalDetailsCombat:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelPersonalDetailsCombat:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelPersonalDetailsCombat:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelPersonalDetailsCombat:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiPanelPersonalDetailsCombat:Refresh(combatData)
    self.PanelPersonalDetailsCombatItem.gameObject:SetActive(false)
    if combatData ~= nil then
        local i = 1
        XTool.LoopCollection(combatData,function (data)
            if data then
                local go = nil
                if i <= #self.ItemsList then
                    go = self.ItemsList[i]
                else
                    go = self:InsObj()
                    table.insert(self.ItemsList,go)
                end
                local item = XUiPanelPersonalDetailsCombatItem.New(go,self.Parent)
                item:Refresh(data)
                i = i + 1
            end
        end)
    end
end

function XUiPanelPersonalDetailsCombat:InsObj( ... )
    local go = CS.UnityEngine.GameObject.Instantiate(self.PanelPersonalDetailsCombatItem.gameObject)
    if go ~= nil then
        go.transform:SetParent(self.PanelGird, false)
    end
    return go
end

return XUiPanelPersonalDetailsCombat
