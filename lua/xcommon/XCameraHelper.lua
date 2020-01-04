XCameraHelper = XCameraHelper or {}

function XCameraHelper.SetUiCameraParam(id)
    --local ctrl = CS.XUiManager.CameraController
    --if ctrl then
    --    ctrl:SetParam(id)
    --end
end

function XCameraHelper.SetCameraTarget(cameraCtrl, targetTrans, distance)
    if cameraCtrl and cameraCtrl:Exist() then
        distance = distance or 0
        cameraCtrl:SetLookAt(targetTrans, distance)
    end
end