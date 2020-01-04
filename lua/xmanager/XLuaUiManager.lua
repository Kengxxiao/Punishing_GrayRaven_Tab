-------------------------------------------------------------------------------------------------------------
CsXUiType = CS.XUiType
CsXUiResType = CS.XUiResType
CsXUiManager = CS.XUiManager
CsIBaseEventListener = CS.IBaseEventListener
CsXGameEventManager = CS.XGameEventManager
CsXLuaEventProxy = CS.XLuaEventProxy
CsXUi = CS.XUi
CsXChildUi = CS.XChildUi
CsXGameUi = CS.XGameUi
CsXMaskManager = CS.XMaskManager
CsXUguiEventListener = CS.XUguiEventListener
CsXUiData = CS.XUiData
CsXUiStackContainer = CS.XUiStackContainer
CsXUiListContainer = CS.XUiListContainer
CsXUiChildContainer = CS.XUiChildContainer
CsXUiHelper = CS.XUiHelper
------------------------------------------------LuaUI---------------------------------------------------------
XLuaUi = Class("XLuaUi")

function XLuaUi:Ctor(name, uiProxy)

    self.Name = name
    self.UiProxy = uiProxy
    self.Ui = uiProxy.Ui

end

function XLuaUi:SetGameObject()
    self.Transform = self.Ui.Transform
    self.GameObject = self.Ui.GameObject
    self.UiAnimation = self.Ui.UiAnimation
    self:InitUiObjects()
end

function XLuaUi:OnAwake(...)
end

function XLuaUi:OnStart(...)
end

function XLuaUi:OnEnable()
end

function XLuaUi:OnDisable()
end

function XLuaUi:OnDestroy()
end

--用于释放lua的内存
function XLuaUi:OnRelease()

    --self.Name = nil
    self.UiProxy = nil
    self.Ui = nil

    self.Transform = nil
    self.GameObject = nil
    self.UiAnimation = nil

    if self.Obj and self.Obj:Exist() then
        local nameList = self.Obj.NameList
        for _,v in pairs(nameList) do
            self[v] = nil
        end
        self.Obj = nil
    end

    for k,v in pairs(self) do
        local t = type(v)
        if t == 'userdata' and CsXUiHelper.IsUnityObject(v) then
            self[k] = nil
        end
    end

end

function XLuaUi:OnNotify(evt, ...)
end

function XLuaUi:OnGetEvents()
end

function XLuaUi:SetUiSprite(image, spriteName, callBack)
    self.UiProxy:SetUiSprite(image, spriteName, callBack)
end

function XLuaUi:GetSceneRoot()
    local root = self.Ui:GetSceneRoot()

    if not root then
        XLog.Error("ui ".. self.Name .. " 没有配置对应的3D场景")
        return nil
    end

    return root
end


--快捷隐藏界面（不建议使用）
function XLuaUi:SetActive(active)
    local temp = active and true or false
    self.UiProxy:SetActive(temp)
end

--快捷关闭界面
function XLuaUi:Close()

    if self.UiProxy == nil then
        XLog.Error(self.Name.."重复Close")
    else
        self.UiProxy:Close()
    end

end

--快捷移除UI,移除的UI不会播放进场、退场动画
function XLuaUi:Remove()
    if self.UiProxy then
        self.UiProxy:Remove()
    end
end

--注册点击事件
function XLuaUi:RegisterClickEvent(button, handle, clear)

    clear = clear and true or false
    self.UiProxy:RegisterClickEvent(button, function(eventData)
            if handle then
                handle(self, eventData)
            end
        end, clear)

end

--返回指定名字的子节点的Component
--@name 子节点名称
--@type Component类型
function XLuaUi:FindComponent(name, type)
    return self.UiProxy:FindComponent(name, type)
end


--通过名字查找GameObject 例如:A/B/C
--@name 要查找的名字
function XLuaUi:FindGameObject(name)
    return self.UiProxy:FindGameObject(name)
end

--通过名字查找Transfrom 例如:A/B/C
--@name 要查找的名字
function XLuaUi:FindTransform(name)
    return self.UiProxy:FindTransform(name)
end

--打开一个子UI
--@childUIName 子UI名字
--@... 传到OnStart的参数
function XLuaUi:OpenChildUi(childUIName, ...)
    self.UiProxy:OpenChildUi(childUIName, ...)
end

--打开一个子UI,会关闭其他已显示的子UI
--@childUIName 子UI名字
--@... 传到OnStart的参数
function XLuaUi:OpenOneChildUi(childUIName, ...)
    self.UiProxy:OpenOneChildUi(childUIName, ...)
end

--关闭子UI
--@childUIName 子UI名字
function XLuaUi:CloseChildUi(childUIName)
    self.UiProxy:CloseChildUi(childUIName)
end

--查找子窗口对应的lua对象
--@childUiName 子窗口名字
function XLuaUi:FindChildUiObj(childUiName)
    local childUi = self.UiProxy:FindChildUi(childUiName)
    if childUi then
        return childUi.UiProxy.UiLuaTable
    end
end

function XLuaUi:InitUiObjects()
    self.Obj = self.Transform:GetComponent("UiObject")
    if self.Obj ~= nil then
        for i = 0, self.Obj.NameList.Count - 1 do
            self[self.Obj.NameList[i]] = self.Obj.ObjList[i]
        end
    end
end

--播放动画（只支持Timeline模式）
function XLuaUi:PlayAnimation(animName, callback, beginCallback)
    self.UiProxy:PlayAnimation(animName, callback, beginCallback)
end

--播放动画（只支持Timeline模式, 增加Mask阻止操作打断动画）
function XLuaUi:PlayAnimationWithMask(animName, callback)
    self.UiProxy:PlayAnimation(animName, function()
        XLuaUiManager.SetMask(false)
        if callback then callback() end
    end, function()
        XLuaUiManager.SetMask(true)
    end)
end

------------------------------------------------------------------------------------------------------------------------
XLuaUiManager = Class("XLuaUiManager")

local ClassType = {}

--注册UI
-- @super 父类
-- @uiName UI名字
function XLuaUiManager.Register(super, uiName)

    super = super or XLuaUi
    local uiObject = Class(uiName, super)
    ClassType[uiName] = uiObject
    return uiObject

end

--创建一个LuaUI的实例
--@name LuaUI脚本名字
--@gameUI C#的GameUI
function XLuaUiManager.New(uiName, uiProxy)

    local baseName = uiName
    local class = ClassType[baseName]
    if not class then
        baseName = string.match(baseName, '%w*[^(%d)$*]')       -- 解析包含数字后缀的界面
        class = ClassType[baseName]
        if not class then
            XLog.Error("XLuaUiManager.New error, class not exist, name: " .. uiName)
            return nil
        end
    end
    local obj = class.New(uiName, uiProxy)
    uiProxy:SetLuaTable(obj)
    return obj

end

--打开UI
--@uiName 打开的UI名字
function XLuaUiManager.Open(uiName, ...)
    CsXUiManager.Instance:Open(uiName, ...)
end

--打开UI，完成后执行回调
--@uiName 打开的UI名称
--@callback 打开完成回调
--@... 传递到OnStart的参数
function XLuaUiManager.OpenWithCallback(uiName, callback, ...)
    CsXUiManager.Instance:OpenWithCallback(uiName, callback, ...)
end

--关闭UI，完成后执行回调
--@uiName 打开的UI名称
--@callback 打开完成回调
function XLuaUiManager.CloseWithCallback(uiName, callback)
    CsXUiManager.Instance:CloseWithCallback(uiName, callback)
end

--针对Normal类型的管理，关闭上一个界面，然后打开下一个界面（无缝切换）
--@uiName 需要打开的UI名字
--@... 传递到OnStart的参数
function XLuaUiManager.PopThenOpen(uiName, ...)
    CsXUiManager.Instance:PopThenOpen(uiName, ...)
end

--针对Normal类型的管理，关闭栈中所有界面，然后打开下一个界面（无缝切换）
--@uiName 需要打开的UI名字
--@... 传递到OnStart的参数
function XLuaUiManager.PopAllThenOpen(uiName, ...)
    CsXUiManager.Instance:PopAllThenOpen(uiName, ...)
end

--关闭UI
--@uiName 关闭的UI名字
function XLuaUiManager.Close(uiName)
    CsXUiManager.Instance:Close(uiName)
end

--移除UI,移除的UI不会播放进场、退场动画
--@uiName 关闭的UI名字
function XLuaUiManager.Remove(uiName)
    CsXUiManager.Instance:Remove(uiName)
end

--某个UI是否显示
function XLuaUiManager.IsUiShow(uiName)
    return CsXUiManager.Instance:IsUiShow(uiName)
end

--某个UI是否已经加载
function XLuaUiManager.IsUiLoad(uiName)
    return CsXUiManager.Instance:IsUiLoad(uiName)
end

--设置mask，visible=true时不能操作
function XLuaUiManager.SetMask(visible)
    visible = visible and true or false
    CsXUiManager.Instance:SetMask(visible)
end

--设置animationMask，visible=true时不能操作，2秒后会展示菊花
function XLuaUiManager.SetAnimationMask(visible)
    visible = visible and true or false
    CsXUiManager.Instance:SetAnimationMask(visible)
end

function XLuaUiManager.ClearMask()
    CsXUiManager.Instance:ClearMask()
end

function XLuaUiManager.ClearAnimationMask()
    CsXUiManager.Instance:ClearAnimationMask()
end

function XLuaUiManager.ClearAllMask()
    CsXUiManager.Instance:ClearMask()
    CsXUiManager.Instance:ClearAnimationMask()
end

--返回主界面
function XLuaUiManager.RunMain()
    if XDataCenter.RoomManager.RoomData then
        -- 如果在房间中，需要先弹确认框
        local title = CS.XTextManager.GetText("TipTitle")
        local quitRoomMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, quitRoomMsg, XUiManager.DialogType.Normal, nil, function()
                XDataCenter.RoomManager.Quit(function()
                        CsXUiManager.Instance:RunMain()
                    end)
            end)
    elseif XDataCenter.RoomManager.Matching then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceCancelMatch")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
                XDataCenter.RoomManager.CancelMatch(function()
                        CsXUiManager.Instance:RunMain()
                    end)
            end)
    else
        CsXUiManager.Instance:RunMain()
    end
end

function XLuaUiManager.ShowTopUi()
    CsXUiManager.Instance:ShowTopUi()
end