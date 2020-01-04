XHomeScene = XClass()

local SCENE_FAR_CLIP_PLANE = 350

function XHomeScene:Ctor(name,sceneAssetUrl, onLoadCompleteCb, onLeaveCb)
    self.OnLoadCompleteCb = onLoadCompleteCb
    self.OnLeaveCb = onLeaveCb

    self.Name = name 
    self.SceneAssetUrl = sceneAssetUrl
    self.Resource = nil
    self.GameObject = nil

    self.CameraFollowTarget = nil
    self.Camera = nil
    self.CameraController = nil
    self.PhysicsRaycaster = nil

    -- 光照信息相关变量
    --self.IlluminationSceneType = nil
    self.CurrentGlobalIllumSoPath = nil
    self.GlobalIllumSOResourceMap = {}
    self.CurrentPointLightPath = nil
    self.CurrentPintLightParent = nil
    self.GlobalPointLightMap = {}
end

function XHomeScene:OnEnterScene()
    XSceneResourceManager.InitPool()
    self.Resource = CS.XResourceManager.LoadAsync(self.SceneAssetUrl)
    CS.XTool.WaitCoroutine(self.Resource, function()
        if not self.Resource.Asset then
            XLog.Error("XHomeScene LoadScene error, instantiate error, name: " .. self.SceneAssetUrl)
            return
        end

        self.GameObject = CS.UnityEngine.Object.Instantiate(self.Resource.Asset)
        self:OnLoadComplete()
    end)
end

function XHomeScene:OnLeaveScene()
    if self.OnLeaveCb then
        self.OnLeaveCb()
    end

    CS.UnityEngine.GameObject.Destroy(self.GameObject)
    self.GameObject = nil

    --self.IlluminationSceneType = nil
    self.CurrentGlobalIllumSoPath = nil
    for _, v in pairs(self.GlobalIllumSOResourceMap) do
        if v then
            v:Release()
        end
    end
    self.GlobalIllumSOResourceMap = nil

    self.CurrentPointLightPath = nil
    self.CurrentPintLightParent = nil
    for _, v in pairs(self.GlobalPointLightMap) do
        if v.Resource then
            v.Resource:Release()
        end

        if not XTool.UObjIsNil(v.SoTrans) then
            CS.UnityEngine.GameObject.Destroy(v.SoTrans.gameObject)
        end
    end
    self.GlobalPointLightMap = nil

    CS.XGlobalIllumination.SetSceneType(CS.XSceneType.Ui)

    if self.Resource then
        self.Resource:Release()
    end
end

function XHomeScene:OnLoadComplete()
    self:InitCamera()

    if self.OnLoadCompleteCb then
        self.OnLoadCompleteCb(self.GameObject)
    end
end

function XHomeScene:InitCamera()
    self.Camera = self.GameObject.transform:Find("Camera"):GetComponent("Camera")
    self.PhysicsRaycaster = self.Camera.gameObject:AddComponent(typeof(CS.UnityEngine.EventSystems.PhysicsRaycaster))

    CS.XGraphicManager.BindCamera(self.Camera)
    local target = CS.UnityEngine.GameObject.Find("@Target")
    if not XTool.UObjIsNil(target) then
        self.CameraFollowTarget = target.transform
    end
    --self.CameraController = self.Camera.gameObject:AddComponent(typeof(CS.XCameraController))
    self.CameraController = self.Camera.gameObject:GetComponent(typeof(CS.XCameraController))

    self.CameraController:SetParam(self.Name)
    XCameraHelper.SetCameraTarget(self.CameraController, self.CameraFollowTarget)
    self.DefaultCameraDistance = self.CameraController.Distance
end

function XHomeScene:ChangeCameraToScene(cb)
    -- if not distance then
    --     self.CameraController:SetParam(self.Name)
    -- end
    XLuaUiManager.Open("UiBlackScreen", self.CameraFollowTarget, self.Name, cb)
    local camera = self:GetCamera()
    if not XTool.UObjIsNil(camera) then
        camera.farClipPlane = SCENE_FAR_CLIP_PLANE
    end
end

function XHomeScene:GetCamera()
    return self.Camera
end

function XHomeScene:GetCameraController()
    return self.CameraController
end

function XHomeScene:SetRaycasterMask(mask)
    self.PhysicsRaycaster:SetEventMask(mask)
end

----------------------------光照信息接口 start-----------------------------
-- 设置光照场景类型
--function XHomeScene:SetSceneType(sceneType)
--    if not sceneType then
--        return
--    end
--
--    self.IlluminationSceneType = sceneType
--    CS.XGlobalIllumination.SetSceneType(sceneType)
--end
--
-- 重置为当前光照场景类型
--function XHomeScene:ResetToCurrentSceneType()
--    if self.IlluminationSceneType then
--        CS.XGlobalIllumination.SetSceneType(self.IlluminationSceneType)
--    end
--end

-- 设置全局光照
function XHomeScene:SetGlobalIllumSO(soPath)
    if not soPath or string.len(soPath) <= 0 then
        return
    end

    self.CurrentGlobalIllumSoPath = soPath

    local resource = self.GlobalIllumSOResourceMap[soPath]
    if not resource then
        resource = CS.XResourceManager.Load(soPath)
        self.GlobalIllumSOResourceMap[soPath] = resource
    end

    CS.XGlobalIllumination.SetGlobalIllumSO(resource.Asset)
end

-- 重置为当前场景全局光
function XHomeScene:ResetToCurrentGlobalIllumination()
    local resource = self.GlobalIllumSOResourceMap[self.CurrentGlobalIllumSoPath]
    if resource then
        CS.XGlobalIllumination.SetGlobalIllumSO(resource.Asset)
    end
end

-- 设置全局点光源
function XHomeScene:SetGlobalPointLight(path, rootTrans)
    if not path or string.len(path) <= 0 then
        return
    end

    self.CurrentPointLightPath = path
    self.CurrentPintLightParent = rootTrans

    local temp = self.GlobalPointLightMap[path]
    if not temp then
        temp = {}
        self.GlobalPointLightMap[path] = temp
    end

    if not temp.Resource then
        temp.Resource = CS.XResourceManager.Load(path)
    end

    if XTool.UObjIsNil(rootTrans) then
        return
    end

    if XTool.UObjIsNil(temp.SoTrans) then
        local go = CS.UnityEngine.Object.Instantiate(temp.Resource.Asset)
        temp.SoTrans = go.transform
    end

    temp.SoTrans:SetParent(rootTrans, false)
    temp.SoTrans.localPosition = CS.UnityEngine.Vector3.zero
    temp.SoTrans.localEulerAngles = CS.UnityEngine.Vector3.zero
    temp.SoTrans.localScale = CS.UnityEngine.Vector3.one
    local pointLight = temp.SoTrans:GetComponent(typeof(CS.XGlobalPointLight))

    CS.XGlobalIllumination.SetGlobalPointLight(pointLight)
end

-- 重置为当前场景点光源
function XHomeScene:ResetToCurrentGlobalPointLight()
    local temp = self.GlobalPointLightMap[self.CurrentPointLightPath]
    if not temp then
        return
    end

    if not temp.Resource then
        return
    end

    if XTool.UObjIsNil(self.CurrentPintLightParent) then
        return
    end

    if XTool.UObjIsNil(temp.SoTrans) then
        local go = CS.UnityEngine.Object.Instantiate(temp.Resource.Asset)
        temp.SoTrans = go.transform
    end

    temp.SoTrans:SetParent(self.CurrentPintLightParent, false)
    temp.SoTrans.localPosition = CS.UnityEngine.Vector3.zero
    temp.SoTrans.localEulerAngles = CS.UnityEngine.Vector3.zero
    temp.SoTrans.localScale = CS.UnityEngine.Vector3.one
    local pointLight = temp.SoTrans:GetComponent(typeof(CS.XGlobalPointLight))

    CS.XGlobalIllumination.SetGlobalPointLight(pointLight)
end
----------------------------光照信息接口 end-----------------------------