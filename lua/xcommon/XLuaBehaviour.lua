XLuaBehaviour = XClass()

function XLuaBehaviour:Ctor(rootUi, ui)
    self.Transform = ui.transform
    self.GameObject = ui.gameObject

    local behaviour = self.GameObject:GetComponent(typeof(CS.XLuaBehaviour))
    if not behaviour then
        behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    end

    if self.Start then
        behaviour.LuaStart = function() self:Start() end
    end

    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end

    if self.LateUpdate then
        behaviour.LuaLateUpdate = function() self:LateUpdate() end
    end

    if self.OnDestroy then
        behaviour.LuaOnDestroy = function() self:OnDestroy() end
    end
end

function XLuaBehaviour:Dispose()
    local xLuaBehaviour = self.Transform:GetComponent(typeof(CS.XLuaBehaviour))
    if (xLuaBehaviour) then
        CS.UnityEngine.GameObject.Destroy(xLuaBehaviour)
    end
end
