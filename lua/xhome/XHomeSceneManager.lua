XHomeSceneManager = XHomeSceneManager or {}

HomeSceneViewType = {
    OverView = 0, --总览
    RoomView = 1, --房间视角
    DeviceView = 2, --设备视角
}

HomeSceneLayerMask = {
    Room = "Room",
    Device = "Device",
    HomeSurface = "HomeSurface",
    Block = "Block",
    HomeCharacter = "HomeCharacter",
}

local CurrentScene = nil
local CurrentView = HomeSceneViewType.OverView

function XHomeSceneManager.Init()
    --TODO
end

function XHomeSceneManager.EnterScene(sceneName, sceneAssetUrl,onLoadCompleteCb, onLeaveCb)
    if CurrentScene and CurrentScene.Name == sceneName then
        return
    end

    local scene = XHomeScene.New(sceneName, sceneAssetUrl, onLoadCompleteCb, onLeaveCb)

    XLuaUiManager.Open("UiLoading", LoadingType.Dormitory)

    XHomeSceneManager.LeaveScene()
    CurrentScene = scene
    CurrentScene:OnEnterScene()
    CurrentView = HomeSceneViewType.OverView
end

function XHomeSceneManager.LeaveScene()
    if CurrentScene then
        CurrentScene:OnLeaveScene()
        CurrentScene = nil
    end
end

function XHomeSceneManager.GetCurrentScene()
    return CurrentScene
end

function XHomeSceneManager.GetSceneCamera()
    if CurrentScene then
        return CurrentScene:GetCamera()
    end
    return nil
end

function XHomeSceneManager.GetSceneCameraController()
    if CurrentScene then
        return CurrentScene:GetCameraController()
    end
    return nil
end

function XHomeSceneManager.ChangeAngleYAndYAxis(angleY, isAllowYAxis)
    local cameraController = XHomeSceneManager.GetSceneCameraController()
    if not XTool.UObjIsNil(cameraController) then
        if angleY > 0 then
            cameraController.TargetAngleY = angleY
        end
        cameraController.AllowYAxis = isAllowYAxis
    end
end

function XHomeSceneManager.ChangeView(viewType)
    CurrentView = viewType
    local mask = XHomeSceneManager.GetLayerMask()
    if CurrentScene then
        CurrentScene:SetRaycasterMask(mask)
    end
end

function XHomeSceneManager.GetCurrentView()
    return CurrentView
end

function XHomeSceneManager.GetLayerMask()
    if (CurrentView == HomeSceneViewType.OverView) then
        return CS.UnityEngine.LayerMask.GetMask(HomeSceneLayerMask.Room)
    elseif (CurrentView == HomeSceneViewType.RoomView) then
        return CS.UnityEngine.LayerMask.GetMask(HomeSceneLayerMask.Device) | CS.UnityEngine.LayerMask.GetMask(HomeSceneLayerMask.HomeCharacter)
    else
        return nil
    end
end

function XHomeSceneManager.ChangeBackToOverView()
    if CurrentView == HomeSceneViewType.OverView then
        return false
    end
    CurrentScene:ChangeCameraToScene(function()
        XHomeSceneManager.ChangeView(HomeSceneViewType.OverView)
    end)
    return true
end

----------------------------光照信息接口 start-----------------------------
-- 设置场景光照信息
--function XHomeSceneManager.SetSceneType(sceneType)
--    XLog.Error(sceneType)
--    if CurrentScene then
--        CurrentScene:SetSceneType(sceneType)
--    end
--end
--
-- 重置为当前光照场景类型
--function XHomeSceneManager.ResetToCurrentSceneType()
--    if CurrentScene then
--        CurrentScene:ResetToCurrentSceneType()
--    end
--end

-- 设置全局光照
function XHomeSceneManager.SetGlobalIllumSO(soPath)
    if CurrentScene then
        CurrentScene:SetGlobalIllumSO(soPath)
    end
end

-- 重置为当前场景全局光
function XHomeSceneManager.ResetToCurrentGlobalIllumination()
    if CurrentScene then
        CurrentScene:ResetToCurrentGlobalIllumination()
    end
end
----------------------------光照信息接口 end-----------------------------