XUiPanelRestModel = XClass()

function XUiPanelRestModel:Ctor(ui,rawImgRest, rawImgDrag, tScreenPos, refName)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Transform3d = ui.transform
    self.RawImgRest = rawImgRest
    self.RawImgDrag = rawImgDrag
    self.RefName = refName
    self:InitAutoScript()
    self:InitRes(tScreenPos)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelRestModel:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelRestModel:AutoInitUi()
    self.UiCharRestDrag = self.Transform:Find("UiCharRestDrag")
    self.UiCameraRestDrag = self.Transform:Find("UiCharRestDrag/UiCameraRestDrag")
    self.PanelModelRestDrag = self.Transform:Find("UiCharRestDrag/PanelModelRestDrag")
    self.UiCharRestModel = self.Transform:Find("UiCharRestModel")
    self.PanelModelRest1 = self.Transform:Find("UiCharRestModel/PanelModelRest1")
    self.PanelModelRest2 = self.Transform:Find("UiCharRestModel/PanelModelRest2")
    self.PanelModelRest3 = self.Transform:Find("UiCharRestModel/PanelModelRest3")
    self.PanelModelRest4 = self.Transform:Find("UiCharRestModel/PanelModelRest4")
    self.PanelModelRest5 = self.Transform:Find("UiCharRestModel/PanelModelRest5")
    self.PanelModelRest6 = self.Transform:Find("UiCharRestModel/PanelModelRest6")
    self.PanelModelReste = self.Transform:Find("UiCharRestModel/PanelModelReste")
end

function XUiPanelRestModel:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelRestModel:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelRestModel:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelRestModel:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelRestModel:InitRes(tScreenPos)
    XRTextureManager.SetTextureCahe(self.RawImgRest)
    local cameraRest = CS.XUiManager.UiModelCamera
    cameraRest.gameObject:SetActive(true)
    for i,v in ipairs(tScreenPos) do
        self["PanelModelRest"..i].transform.position = cameraRest:ViewportToWorldPoint(v)
    end

    local renderTextureDrag = CS.UnityEngine.RenderTexture(512,512,0)
    self.RawImgDrag.texture = renderTextureDrag
    local cameraDrag = self.UiCameraRestDrag:GetComponent("Camera")
    cameraDrag.targetTexture = renderTextureDrag
    local rtf = self.RawImgDrag:GetComponent("RectTransform")
    rtf.sizeDelta = CS.UnityEngine.Vector2(512,512)


    for i=1,6 do
        self["RoleModel"..i] = XUiPanelRoleModel.New(self["PanelModelRest"..i], self.RefName)
    end
    self.RoleDrag = XUiPanelRoleModel.New(self.PanelModelRestDrag, self.RefName)
    
end


function XUiPanelRestModel:UpdateShowCharRest(charList)
    for i=1,6 do
        self["RoleModel"..i]:HideRoleModel()
    end
    local func = function(model)
        if not model then return end
        local oldpos = model.transform.position
        model.transform.position = CS.UnityEngine.Vector3(oldpos.x,oldpos.y - 1,oldpos.z)
        model.transform.localScale = CS.UnityEngine.Vector3(1.3,1.3,1.3)
        model.transform.localEulerAngles = CS.UnityEngine.Vector3(0,180,0)
    end

    for i,v in ipairs(charList) do
        if v ~= 0 then
            self["RoleModel"..i]:UpdateCharacterModel(v,nil,nil,func)
            self["RoleModel"..i]:ShowRoleModel()
        end
    end
end

function XUiPanelRestModel:UpdateDragModel(charid)
    local func = function(model)
        if not model then return end
        local oldpos = model.transform.position
        model.transform.localEulerAngles = CS.UnityEngine.Vector3(0,180,0)
    end
    self.RoleDrag:UpdateCharacterModel(charid,nil,nil,func)
    self.RawImgDrag.gameObject:SetActive(true)
end

function XUiPanelRestModel:HideDragModel()
    self.RawImgDrag.gameObject:SetActive(false)
end