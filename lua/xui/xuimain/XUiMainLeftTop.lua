XUiMainLeftTop = XClass()

function XUiMainLeftTop:Ctor(rootUi)
    self.Transform = rootUi.PanelLeftTop.gameObject.transform
    XTool.InitUiObject(self)
    self:UpdateInfo()
    --ClickEvent
    self.BtnRoleInfo.CallBack = function() self:OnBtnRoleInfo() end
    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnRoleInfo.ReddotObj, self.OnCheckRoleNews, self, { XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE, XRedPointConditions.Types.CONDITION_PLAYER_SETNAME, XRedPointConditions.Types.CONDITION_EXHIBITION_NEW,XRedPointConditions.Types.CONDITION_HEADPORTRAIT_RED,XRedPointConditions.Types.CONDITION_MEDAL_RED,})
end

function XUiMainLeftTop:OnEnable()
    self:UpdateInfo()
    XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, self.UpdateInfo, self)
end

function XUiMainLeftTop:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, self.UpdateInfo, self)
end

--个人详情入口
function XUiMainLeftTop:OnBtnRoleInfo()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Player) then
        return
    end
    XLuaUiManager.Open("UiPlayer")
end

--更新等级经验等
function XUiMainLeftTop:UpdateInfo()
    local curExp = XPlayer.Exp
    local maxExp = XPlayerManager.GetMaxExp(XPlayer.Level)
    local fillAmount = curExp / maxExp
    self.ImgExpSlider.fillAmount = fillAmount
    local name = XPlayer.Name
    if name ~= nil then
        self.TxtName.text = name
    end
    local level = XPlayer.Level
    if level ~= nil then
        self.TxtLevel.text = math.floor(level)
    end

    self.TxtId.text = XPlayer.Id
end

--角色红点
function XUiMainLeftTop:OnCheckRoleNews(count)
    self.BtnRoleInfo:ShowReddot(count >= 0)
end