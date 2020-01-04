---
--- 场景基类对象
---
local XSceneObject = XClass()

function XSceneObject:Ctor()
    --
end

function XSceneObject:Dispose()
    XSceneEntityManager.RemoveEntity(self.GameObject)

    if self.ModelPath then
        XSceneResourceManager.ReturnGoToPool(self.ModelPath, self.GameObject)
    end
    self.ModelPath = nil

    self.GameObject = nil
    self.Transform = nil
end

function XSceneObject:SetModel(go,loadtype)
    self.GameObject = go
    self.Transform = go.transform

    XSceneEntityManager.AddEntity(self.GameObject, self)
    self:OnLoadComplete(loadtype)
end

function XSceneObject:LoadModel(modelPath, root)
    self.ModelPath = modelPath
    local model = XSceneResourceManager.GetGoFromPool(modelPath)

    self:BindToRoot(model, root)

    self:SetModel(model)
end

function XSceneObject:BindToRoot(model, root)
    model.transform:SetParent(root)
    model.transform.localPosition = CS.UnityEngine.Vector3.zero
    model.transform.localEulerAngles = CS.UnityEngine.Vector3.zero
    model.transform.localScale = CS.UnityEngine.Vector3.one
end

function XSceneObject:OnLoadComplete()
    -- body
end

return XSceneObject