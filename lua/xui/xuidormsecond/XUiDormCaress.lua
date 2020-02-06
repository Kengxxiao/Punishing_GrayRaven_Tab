local XUiPanelFurnitureLike = require("XUi/XUiDormSecond/XUiPanelFurnitureLike")
local XUiDormCaress = XClass(XLuaBehaviour)
local TextManager = CS.XTextManager
local TouchState = XDormConfig.TouchState

function XUiDormCaress:Ctor(uiroot,ui)
    self.DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.OnBtnBackClickCb = function() self:OnBtnBackClick() end

    XTool.InitUiObject(self)
    self:RefreshData()
    self:InitAddListen()
    self:InitTabGroup()

    self.FurnitureLike = XUiPanelFurnitureLike.New(uiroot, self.PanelFurnitureLike)
end

function XUiDormCaress:InitAddListen()
    self.UiRoot:RegisterClickEvent(self.BtnBack, self.OnBtnBackClickCb)
end

function XUiDormCaress:OnBtnBackClick()
    self.UiRoot:OnCloseedCaress()
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_HIDE)
    XDataCenter.DormManager.SetInTouch(false)
    XDataCenter.DormManager.GetNextShowEvent()
end

function XUiDormCaress:InitTabGroup()
    self.BtnList = {}
    table.insert(self.BtnList, self.BtnCaress)
    table.insert(self.BtnList, self.BtnGun)
    table.insert(self.BtnList, self.BtnPlay)

    self.PanelParticularCaressGroup:Init(self.BtnList, function(index)
        self.CurTouchState = index
    end)
end

function XUiDormCaress:Show(characterId, curRoomId)
    self.IsTouchCD = false
    self:RefreshData()
    self.TxtTouchDesc.text = CS.XTextManager.GetText("DormTouchDesc")

    self.CharacterId = characterId
    self.Camera = XHomeSceneManager.GetSceneCamera()
    self.CurSelectCharacter = XHomeCharManager.GetSelectCharacter()
    self.FurnitureLike:Refresh(characterId, curRoomId)
    self.FurnitureLike.GameObject:SetActiveEx(true)

    -- 设置默认开启
    self.PanelParticularCaressGroup:SelectIndex(TouchState.Touch)
    -- 拉近摄像头
    local cameraController = XHomeSceneManager.GetSceneCameraController()
    self.TargetAngleX = cameraController.TargetAngleX
    self.TargetAngleY = cameraController.TargetAngleY
    self.MinDistance = cameraController.MinDistance
    self.Distance = cameraController.Distance
    self.AllowZoom = cameraController.AllowZoom

    if not XTool.UObjIsNil(cameraController) then
        cameraController:SetWorldOffset(CS.UnityEngine.Vector2(0, -0.39))
        cameraController:SetTartAngle(CS.UnityEngine.Vector2(self.CurSelectCharacter.Transform.eulerAngles.y - 180, 10))
        cameraController:SetMinDistance(XDormConfig.DRAFT_DIS)
        XCameraHelper.SetCameraTarget(cameraController, self.CurSelectCharacter.Transform, XDormConfig.DRAFT_DIS)
        CS.XDofManager.Instance:SetDormitoryDof(self.CurSelectCharacter.Transform)
        cameraController.AllowZoom = false
    end

    self:ReqFondleData()
    XEventManager.DispatchEvent(XEventId.EVENT_CARESS_SHOW)
end

function XUiDormCaress:ReqFondleData()
    self:RemoveTimer()

    XDataCenter.DormManager.GetDormFondleData(self.CharacterId, function(fondleData)
        self.FondleConfig = XDormConfig.GetCharacterFondleByCharId(self.CharacterId)
        self.FondleData = fondleData

        self:SetRecoveryInfo(fondleData.LeftCount, fondleData.LastRecoveryTime)
        self.PanelParticularCaress.gameObject:SetActiveEx(true)
    end)
end

function XUiDormCaress:SetRecoveryInfo(leftCount, recoveryTime)
    self.PanelTimeOut.gameObject:SetActiveEx(leftCount < self.FondleConfig.MaxCount)
    self.TxtTouchCount.text = CS.XTextManager.GetText("DormFondleCount", leftCount, self.FondleConfig.MaxCount)

    if leftCount >= self.FondleConfig.MaxCount then
        return
    end

    local now = XTime.GetServerNowTimestamp()
    local leftTime = recoveryTime + self.FondleConfig.RecoveryTime - now
    local timeString = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.CHALLENGE)
    self.TxtTimeOut.text = CS.XTextManager.GetText("DormFondleRecovey", timeString)

    self.TimerId = CS.XScheduleManager.ScheduleForever(function()
        if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
            return
        end

        leftTime = leftTime - 1
        if leftTime <= 0 then
            self:ReqFondleData()
            return
        end

        timeString = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.CHALLENGE)
        self.TxtTimeOut.text = CS.XTextManager.GetText("DormFondleRecovey", timeString)
    end, 1000)
end

function XUiDormCaress:RemoveTimer()
    if self.TimerId then
        CS.XScheduleManager.UnSchedule(self.TimerId)
        self.TimerId = nil
    end
end

function XUiDormCaress:RemoveAnimaTimer()
    if self.AnimaTimer then
        CS.XScheduleManager.UnSchedule(self.AnimaTimer)
        self.AnimaTimer = nil
    end
end

function XUiDormCaress:OnClose(curDormId)
    self.FondleData = {}
    self:RemoveTimer()
    self:RemoveAnimaTimer()
    self:RefreshData()
    self.PanelParticularCaress.gameObject:SetActiveEx(false)

     -- 拉远摄像头
     local cameraController = XHomeSceneManager.GetSceneCameraController()
     if not XTool.UObjIsNil(cameraController) then
        cameraController:SetWorldOffset(CS.UnityEngine.Vector2(0, 0))
        cameraController:SetTartAngle(CS.UnityEngine.Vector2(self.TargetAngleX, self.TargetAngleY))
        local curDormTransform = XHomeDormManager.GetRoom(curDormId).Transform
        cameraController:SetMinDistance(self.MinDistance)
        XCameraHelper.SetCameraTarget(cameraController, curDormTransform, self.Distance)
        CS.XDofManager.Instance:SetDormitoryDof(nil)
        cameraController.AllowZoom = self.AllowZoom
     end
end

function XUiDormCaress:Update()
    if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
        return
    end

    local point = self:GetPisont()
    if not XTool.UObjIsNil(self.Camera) and point then
        local ray = self.Camera:ScreenPointToRay(point, 0)
        local layerMask = CS.UnityEngine.LayerMask.GetMask("HomeCharacter")
        if layerMask then
            local rect, hit = ray:RayCast(layerMask)
            if rect and hit and self.CurSelectCharacter.Transform == hit.transform then
                if not self:JudgeLeftCount() then
                    XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Hate, self.CharacterId, nil)
                end

                self:UpdateFondleInfo(point)
            end
        end
    end
end

function XUiDormCaress:GetPisont()
    local screenPoint

    if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer then
        if self.CurTouchState == TouchState.WaterGun then
            if CS.UnityEngine.Input.GetMouseButtonDown(0) then
                screenPoint = CS.UnityEngine.Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, 0)
            elseif CS.UnityEngine.Input.GetMouseButtonUp(0) then
                XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Hide, self.CharacterId, nil)
            end
        else
            if CS.UnityEngine.Input.GetMouseButtonDown(0) then
                self:RefreshData()
            elseif CS.UnityEngine.Input.GetMouseButtonUp(0) then
                XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Hide, self.CharacterId, nil)
            end

            if CS.UnityEngine.Input.GetMouseButton(0) then
                screenPoint = CS.UnityEngine.Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, 0)
            end
        end
    else
        if CS.UnityEngine.Input.touchCount > 0 then
            if self.CurTouchState == TouchState.WaterGun then
                if CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Began then
                    local p = CS.UnityEngine.Input.GetTouch(0).position
                    screenPoint = CS.UnityEngine.Vector3(p.x, p.y, 0)
                elseif CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Ended then
                    XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Hide, self.CharacterId, nil)
                end
            else
                if CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Began then
                    self:RefreshData()
                elseif CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Ended then
                    XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Hide, self.CharacterId, nil)
                end

                if CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Stationary or
                   CS.UnityEngine.Input.GetTouch(0).phase == CS.UnityEngine.TouchPhase.Moved then
                    local p = CS.UnityEngine.Input.GetTouch(0).position
                    screenPoint = CS.UnityEngine.Vector3(p.x, p.y, 0)
                end
            end
        end
    end

    return screenPoint
end

function XUiDormCaress:RefreshData()
    self.TouchLength = 0
    self.PlayTime = 0
    self.LastPoint = nil
    self.PlayTimer = 0
end

-- 每帧更新爱抚滑动详情
function XUiDormCaress:UpdateFondleInfo(point)
    if self.CurTouchState == TouchState.Touch then
        -- 判断是否还有次数
        if not self:JudgeLeftCount() then
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW_VIEW, TouchState.TouchHate, self.CharacterId, point)
            return
        end

        -- 判断是否在CD中
        if self.IsTouchCD then
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW_VIEW, TouchState.Touch, self.CharacterId, point)
            return
        end

        if self.LastPoint then
           local dis = (self.LastPoint - point).sqrMagnitude
           self.TouchLength = self.TouchLength + dis
        end
        self.LastPoint = point

        -- 判断前置长度
        local propLength = XDormConfig.TOUCH_LENGTH * XDormConfig.TOUCH_PROP
        local propNum = self.TouchLength / XDormConfig.TOUCH_LENGTH
        if propNum < 0 then
            propNum = 0
        elseif propNum > 1 then
            propNum = 1
        end

        if self.TouchLength < propLength then
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW_VIEW, TouchState.Touch, self.CharacterId, point, propNum)
            return
        end

        -- 达到长度请求抚摸
        if self.TouchLength >= XDormConfig.TOUCH_LENGTH then
            self:RefreshData()
            self:ReqFondle()
        end

        XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Touch, self.CharacterId, point, propNum)
    elseif self.CurTouchState == TouchState.WaterGun then
        self:ReqFondle()
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.WaterGun, self.CharacterId, point)
    elseif self.CurTouchState == TouchState.Play then
        self.PlayTimer = self.PlayTimer + CS.UnityEngine.Time.deltaTime
        if self.PlayTimer >= XDormConfig.PLAY_TIME then
            self:RefreshData()
            self:ReqFondle()
        end
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, TouchState.Play, self.CharacterId, point)
    end
end

-- 请求爱抚
function XUiDormCaress:ReqFondle()
    -- 次数不足
    if self.FondleData.LeftCount <= 0 then
        return
    end

    XDataCenter.DormManager.DoFondleReq(self.CharacterId, self.CurTouchState, function()
        local state = TouchState.Hide
        if self.CurTouchState == TouchState.Touch then
            state = TouchState.TouchSuccess
        elseif self.CurTouchState == TouchState.WaterGun then
            state = TouchState.WaterGunSuccess
        elseif self.CurTouchState == TouchState.Play then
            state = TouchState.PlaySuccess
        end

        if self.CurTouchState == TouchState.Touch then
            self.IsTouchCD = true
            local time = XDormConfig.TOUCH_CD

            self.AnimaTimer = XUiHelper.Tween(time, function(f)
                if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
                    return
                end

                local timeStr = string.format("%.1f", time - f * time)
                self.TxtTouchDesc.text = CS.XTextManager.GetText("DormTouchTimeOut", timeStr)
            end, function()
                self:RemoveAnimaTimer()
                self.IsTouchCD = false
                self.TxtTouchDesc.text = CS.XTextManager.GetText("DormTouchDesc")
            end)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_SHOW, state, self.CharacterId, nil)
        self:ReqFondleData()
    end)
end

-- 判断是否还有次数
function  XUiDormCaress:JudgeLeftCount()
    if self.FondleData and self.FondleData.LeftCount then 
        return self.FondleData.LeftCount > 0
    end

    return false
end

return XUiDormCaress
