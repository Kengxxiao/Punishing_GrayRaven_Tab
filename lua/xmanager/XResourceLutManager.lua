XResourceLutManager = XResourceLutManager or {}

local VCAMERA_LUT = "Client/ResourceLut/Camera/VCamera"
local SCENE_CAMERA_LUT = "Client/ResourceLut/Camera/SceneCamera/SceneCamera.tab"
local CAMERA_TRACK_LUT = "Client/ResourceLut/Camera/Track/CameraTrackLut.tab"
local CAMERA_NOISE_LUT = "Client/ResourceLut/Camera/Noise/CameraNoiseLut.tab"
local EFFECT_LUT = "Client/ResourceLut/Effect/EffectLut.tab"

local VCameraLut
local SceneCameraLut
local CameraTrackLut
local CameraNoiseLut
local EffectLut

local Init = function()
    VCameraLut = XTableManager.ReadByStringKey(VCAMERA_LUT, XTable.XTableResourceLut, "Id")
    SceneCameraLut = XTableManager.ReadByStringKey(SCENE_CAMERA_LUT, XTable.XTableResourceLut, "Id")
    CameraTrackLut = XTableManager.ReadByStringKey(CAMERA_TRACK_LUT, XTable.XTableResourceLut, "Id")
    CameraNoiseLut = XTableManager.ReadByStringKey(CAMERA_NOISE_LUT, XTable.XTableResourceLut, "Id")
    EffectLut = XTableManager.ReadByStringKey(EFFECT_LUT, XTable.XTableResourceLut, "Id")
end

local GetVCameraUrl = function(vcamId)
    local tab = VCameraLut[vcamId]
    if not tab then
        XLog.Error("XResourceLutManager.GetVCameraUrl error. vcamId: " .. vcamId)
        return
    end
    return tab.Url
end

local GetSceneCameraUrl = function(cameraId)
    local tab = SceneCameraLut[cameraId]
    if not tab then
        XLog.Error("XResourceLutManager.GetSceneCameraUrl error. cameraId: " .. cameraId)
        return
    end
    return tab.Url
end

local GetCameraTrackUrl = function(trackId)
    local tab = CameraTrackLut[trackId]
    if not tab then
        XLog.Error("XResourceLutManager.GetCameraTrackUrl error. trackId: " .. trackId)
        return
    end
    return tab.Url
end

local GetCameraNoiseUrl = function(noiseId)
    local tab = CameraNoiseLut[noiseId]
    if not tab then
        XLog.Error("XResourceLutManager.GetCameraNoiseUrl error. noiseId: " .. noiseId)
        return
    end
    return tab.Url
end

local GetEffectUrl = function(effectId)
    local tab = EffectLut[effectId]
    if not tab then
        XLog.Error("XResourceLutManager.GetEffectUrl error. effectId: " .. effectId)
        return
    end
    return tab.Url
end

XResourceLutManager.Init = Init
XResourceLutManager.GetVCameraUrl = GetVCameraUrl
XResourceLutManager.GetSceneCameraUrl = GetSceneCameraUrl
XResourceLutManager.GetCameraTrackUrl = GetCameraTrackUrl
XResourceLutManager.GetCameraNoiseUrl = GetCameraNoiseUrl
XResourceLutManager.GetEffectUrl = GetEffectUrl