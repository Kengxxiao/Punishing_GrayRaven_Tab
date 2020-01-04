local Object = CS.UnityEngine.Object
local V3Zero = CS.UnityEngine.Vector3.zero
local V3One = CS.UnityEngine.Vector3.one
local Rotation = CS.UnityEngine.Quaternion.identity
local cam
local objects = {}
local Types = {
    BG = 1,
    SHOWBG = 2,
    BOX = 3,
    EFFECT = 4,
    WEAPON = 5
}

local SetCamera = function(camera)
    cam = camera
end

local AddObject = function(transform, type)
    transform:SetParent(cam)
    transform.localPosition = V3Zero
    transform.localRotation = Rotation
    transform.localScale = V3One
    objects[type] = transform.gameObject
end

local SetActive = function(type, bool)
    local obj = objects[type]
    if obj and obj:Exist() then
        obj:SetActive(bool)
    end
end

local SetAllActive = function(bool)
    for k, v in pairs(objects) do
        if v:Exist() then
            v:SetActive(bool)
        end
    end
end

local DestroyObject = function(type)
    local obj = objects[type]
    if obj then
        Object.Destroy(obj)
        objects[type] = nil
    end
end

local Dispose = function()
    for k, v in pairs(objects) do
        if v:Exist() then
            Object.Destroy(v)
        end
        v = nil
    end
    objects = {}
end

local DrawScene = {}

DrawScene.Types = Types
DrawScene.SetCamera = SetCamera
DrawScene.AddObject = AddObject
DrawScene.SetActive = SetActive
DrawScene.SetAllActive = SetAllActive
DrawScene.DestroyObject = DestroyObject
DrawScene.Dispose = Dispose

return DrawScene