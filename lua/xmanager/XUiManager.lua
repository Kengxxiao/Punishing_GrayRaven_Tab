XUi = XClass()

function XUi:Ctor(name, ui)
    self.Name = name
    self.CsUi = ui
    self.Transform = ui.Transform
    self.GameObject = ui.GameObject
    self.UiAnimation = ui.UiAnimation
end

function XUi:OnOpen(...)
end

function XUi:OnClose()
end

function XUi:OnShow()
end

function XUi:OnHide()
end

function XUi:SetUiSprite(image, name, callBack)
    if not XTool.UObjIsNil(self.CsUi) then
        self.CsUi:SetUiSprite(image, name, callBack)
    end
end

XUiManager = XUiManager or {}

local ClassTable = {}
local ClassObj = {}

function XUiManager.Register(name, super)
    super = super or XUi
    --CS.XUiManager.Register(name)
    local class = XClass(super)
    ClassTable[name] = class
    return class
end

function XUiManager.FindClassType(name)
    for k, v in pairs(ClassObj) do
        if k == name then
            return v
        end
    end
    return nil
end

function XUiManager.RemoveClassType(name)
    for k, v in pairs(ClassObj) do
        if k == name then
            ClassObj[k] = nil
        end
    end
end

function XUiManager.New(name, ui)
    local baseName = name
    local class = ClassTable[baseName]
    if not class then
        baseName = string.match(baseName, '%w*[^(%d)$*]')       -- 解析包含数字后缀的界面
        class = ClassTable[baseName]
        if not class then
            XLog.Error("XUiManager.New error, class not exist, name: " .. name)
            return nil
        end
    end
    local obj = class.New(name, ui)
    ClassObj[name] = obj
    return obj
end

XUiManager.XUiEvent = {
    Show = 1,
    Hide = 2,
    Open = 3,
    Close = 4,
}

XUiManager.UiTipType = {
    Tip = 1,
    Wrong = 2,
    Success = 3,
}

XUiManager.DialogType = {
    Normal = "Normal",
    OnlyClose = "OnlyClose",
    OnlySure = "OnlySure",
}

function XUiManager.TipMsg(msg, type, cb, hideCloseMark)
    if not msg then
        XLog.Error("XUiManager.TipMsg error, msg is nil")
        return
    end

    if not type then
        type = XUiManager.UiTipType.Tip
    end

    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_small)
    --CS.XUiManager.TipsManager:Push("UiTipLayer", true, true, msg, type)
    XLuaUiManager.Open("UiTipLayer", msg, type, cb, hideCloseMark)
end

function XUiManager.TipText(key, type)
    if not type then
        type = XUiManager.UiTipType.Wrong
    end
    local text = CS.XTextManager.GetText(key)
    XUiManager.TipMsg(text, type)
end

function XUiManager.TipSuccess(msg, hideCloseMark)
    XUiManager.TipMsg(msg, XUiManager.UiTipType.Success, nil, hideCloseMark)
end

function XUiManager.TipError(msg)
    XUiManager.TipMsg(msg, XUiManager.UiTipType.Wrong)
end

function XUiManager.TipCode(code, ...)
    local text = CS.XTextManager.GetCodeText(code, ...)
    if code == XCode.Success then
        XUiManager.TipSuccess(text)
    else
        XUiManager.TipError(text)
    end
end

function XUiManager.DialogTip(title, content, dialogType, closeCallback, sureCallback)
    if not title or not content then
        XLog.Error("XUiManager.DialogTip error, title or content is nil")
        return
    end

    if not XUiManager.DialogType[dialogType] then
        XLog.Error("XUiManager.DialogTip error, dialogType is error")
        return
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_UIDIALOG_VIEW_ENABLE)

    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_Big)

    --CS.XUiManager.DialogManager:Push("UiDialog", true, true, title, content, dialogType, closeCallback, sureCallback)
    CsXUiManager.Instance:Open("UiDialog", title, content, dialogType, closeCallback, sureCallback)
end

--弹出系统提示
function XUiManager.SystemDialogTip(title, content, dialogType, closeCallback, sureCallback)
    if not title or not content then
        XLog.Error("XUiManager.SystemDialogTip error, title or content is nil")
        return
    end

    if not XUiManager.DialogType[dialogType] then
        XLog.Error("XUiManager.SystemDialogTip error, dialogType is error")
        return
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_UIDIALOG_VIEW_ENABLE)

    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_Big)

    CsXUiManager.Instance:Open("UiSystemDialog", title, content, dialogType, closeCallback, sureCallback)
end

--显示Tip
function XUiManager.ShowHelpTip(funcName)
    local config = XHelpCourseConfig.GetHelpCourseTemplateByFunction(funcName)
    if not config then
        return
    end


    if config.IsShowCourse == 1 then
        XLuaUiManager.Open("UiHelp", config)
    else
        XUiManager.UiFubenDialogTip(config.Name, config.Describe)
    end
end


function XUiManager.UiFubenDialogTip(title, content, closeCallback, sureCallback)
    if not title or not content then
        XLog.Error("XUiManager.UiFubenDialog error, title or content is nil")
        return
    end

    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_Big)
    --CS.XUiManager.DialogManager:Push("UiFubenDialog", true, true, title, content, closeCallback, sureCallback)
    XLuaUiManager.Open("UiFubenDialog", title, content, closeCallback, sureCallback)
end

function XUiManager.OpenBuyAssetPanel(id, successCallback)
    --CS.XUiManager.ViewManager:Push("UiBuyAsset", true, false, id, successCallback, nil)
    XDataCenter.ItemManager.SelectBuyAssetType(id, successCallback, nil, nil)
end

function XUiManager.OpenUiObtain(data, title, closeCallback, sureCallback)
    XLuaUiManager.Open("UiObtain", data, title, closeCallback, sureCallback)
end

function XUiManager.OpenUiTipReward(data, title, closeCallback, sureCallback)
    --CS.XUiManager.ViewManager:Push("UiTipReward", true, false, data, title, closeCallback, sureCallback)
    XLuaUiManager.Open("UiTipReward", data, title, closeCallback, sureCallback)
end

function XUiManager.WhenUiLoaded(cb)
    CS.XUiManager.WhenUiLoaded(cb)
end

function XUiManager.LoadUiWithCb(name, root, cb, cache, ...)
    cache = cache and true or false
    local result = CS.XUiManager.Load(name, root, cb, cache, ...)
    return result
end

function XUiManager.PushLoadUiWithCb(name, root, cb, cache, ...)
    cache = cache and true or false
    return CS.XUiManager.PushLoad(name, root, cb, cache, ...)
end

function XUiManager.OpenMainUi()
    local guideFight = XDataCenter.GuideManager.GetNextGuideFight()
    if guideFight then
        XLuaUiManager.Close("UiGuide")
        XDataCenter.FubenManager.EnterGuideFight(guideFight.Id, guideFight.StageId, guideFight.NpcId, guideFight.Weapon)
    else
        XLuaUiManager.RunMain()
    end
end