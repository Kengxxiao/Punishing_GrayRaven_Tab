local XUiHintFunctional = XLuaUiManager.Register(XLuaUi, "UiHintFunctional")

function XUiHintFunctional:OnAwake()
    self:InitAutoScript()
end

function XUiHintFunctional:OnStart(openId)
    self.PanelHintBox.gameObject:SetActive(true)
    self.BtnBox.gameObject:SetActive(true)
    self.OpenList = openId
    self.Index = 1
    self:NextHint()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHintFunctional:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHintFunctional:AutoInitUi()
    self.PanelHintBox = self.Transform:Find("SafeAreaContentPane/PanelHintBox")
    self.TxtBox = self.Transform:Find("SafeAreaContentPane/PanelHintBox/TxtBox"):GetComponent("Text")
    self.BtnBox = self.Transform:Find("SafeAreaContentPane/PanelHintBox/BtnBox"):GetComponent("Button")
end

function XUiHintFunctional:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHintFunctional:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiHintFunctional:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHintFunctional:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBox, self.OnBtnBoxClick)
end
-- auto

function XUiHintFunctional:OnBtnBoxClick(...)
    self.Index = self.Index + 1
    if self.Index > #self.OpenList then
        self:Close()
     --   XTipManager.Execute()
        XFunctionManager.IsOpen = false
        XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_COMPLETE)
        return nil
    else
        if XFunctionManager.GetOpenHint(self.OpenList[self.Index]) == 1 then
            self:NextHint()
        -- elseif XFunctionManager.GetOpenHint(self.OpenList[self.Index]) == 2 then
        --     local remainId = {}
        --     for i = self.Index, #self.OpenList do
        --         table.insert(remainId, self.OpenList[i])
        --     end
        --     --CS.XUiManager.TipsManager:Pop()
        --     self:Close()
        --     --CS.XUiManager.TipsManager:Push("UiFunctionalOpen",true, false, remainId)
        --     XLuaUiManager.Open("UiFunctionalOpen", remainId)
        end
    end
end

function XUiHintFunctional:NextHint()
    if XFunctionManager.JudgeOpen(self.OpenList[self.Index]) == false then
        XPlayer.ChangeMarks(self.OpenList[self.Index])
    end
    self.TxtBox.text = ""
    if XFunctionManager.GetFunctionalType(self.OpenList[self.Index]) == XFunctionManager.FunctionType.System then
        self.TxtBox.text = CS.XTextManager.GetText("FunctionOpen", XFunctionManager.GetFunctionalName(self.OpenList[self.Index]))
    elseif XFunctionManager.GetFunctionalType(self.OpenList[self.Index]) == XFunctionManager.FunctionType.Stage then
        self.TxtBox.text = CS.XTextManager.GetText("FunctionOpenStage", XFunctionManager.GetFunctionalName(self.OpenList[self.Index]))
    end
end
