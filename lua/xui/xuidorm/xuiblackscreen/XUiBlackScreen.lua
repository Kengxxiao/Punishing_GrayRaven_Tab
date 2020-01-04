-- 镜头黑幕界面
local XUiBlackScreen = XLuaUiManager.Register(XLuaUi, "UiBlackScreen")

local ADJUST_DISTANCE = 0.2
--local ADJUST_DISTANCE_CON = 2
local FADE_TIME = 0.1
local DURATION_TIME = 0.25

function XUiBlackScreen:OnStart(targetTrans, paramName, cb)
    local distance
    local cameraController = XHomeSceneManager.GetSceneCameraController()
    -- if not XTool.UObjIsNil(cameraController) then
    --     local old_distance = cameraController.Distance
    --     local old_target = cameraController.TargetObj
    --     XCameraHelper.SetCameraTarget(cameraController, old_target, old_distance * (ADJUST_DISTANCE + 1))
    --     --XCameraHelper.SetCameraTarget(cameraController, old_target, old_distance + ADJUST_DISTANCE_CON)
    -- end

    self.ImgBackground:DOFade(1.0, FADE_TIME):OnComplete(function()
        if not XTool.UObjIsNil(cameraController) then
            cameraController.IsTweenCamera = false
            if paramName and string.len(paramName) > 0 then
                cameraController:SetParam(paramName)
                distance = cameraController.Distance
            end
            XCameraHelper.SetCameraTarget(cameraController, targetTrans, distance * (ADJUST_DISTANCE + 1))
            --XCameraHelper.SetCameraTarget(cameraController, targetTrans, distance + ADJUST_DISTANCE_CON)
        end

        if cb then
            cb()
        end

        local isCalled = false
        self.ImgBackground:DOFade(0.0, FADE_TIME):SetDelay(DURATION_TIME):OnUpdate(function()
            if not isCalled then
                if not XTool.UObjIsNil(cameraController) then
                    cameraController.IsTweenCamera = true
                    XCameraHelper.SetCameraTarget(cameraController, targetTrans, distance)
                end
                isCalled = true
            end
        end):OnComplete(function()
            self:Close()
        end)
    end)
end