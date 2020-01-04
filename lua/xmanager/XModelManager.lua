XModelManager = XModelManager or {}

local Ui_MODEL_TRANSFORM_PATH = "Client/Ui/UiModelTransform.tab"
local Ui_SCENE_TRANSFORM_PATH = "Client/Ui/UiSceneTransform.tab"
local MODEL_TABLE_PATH = "Client/ResourceLut/Model/Model.tab"

XModelManager.MODEL_ROTATION_VALUE = 10

XModelManager.MODEL_UINAME = {
    XUiMain = "UiMain",
    XUiCharacter = "UiCharacter",
    XUiPanelCharLevel = "UiPanelCharLevel",
    XUiPanelCharQuality = "UiPanelCharQuality",
    XUiPanelCharSkill = "UiPanelCharSkill",
    XUiPanelCharGrade = "UiPanelCharGrade",
    XUiPanelSelectLevelItems = "UiPanelSelectLevelItems",
    XUiPreFight = "UiPreFight",
    XUiDisplay = "UiDisplay",
    XUiFashion = "UiFashion",
    XUiNewPlayerTask = "UiNewPlayerTask",
    XUiBossSingle = "UiPanelBossDetail",
    XUiOnlineBoss = "UiOnlineBoss",
    XUiDormCharacterDetail = "UiDormCharacterDetail",
    XUiFurnitureDetail = "UiDormFurnitureDetail",
    XUiFavorabilityLineRoomCharacter = "UiFavorabilityLineRoomCharacter",
    XUiDrawShow = "UiDrawShow",
}

local RoleModelPool = {} --保存模型
local UiModelTransformTemplates = {} -- Ui模型位置配置表
local UiSceneTransformTemplates = {} -- Ui模型位置配置表
local ModelTemplates = {} -- 模型相关配置

function XModelManager.Init()
    XModelManager.InitRoleModeConfig()
end

--角色Model配置表
function XModelManager.InitRoleModeConfig()
    ModelTemplates = XTableManager.ReadByStringKey(MODEL_TABLE_PATH, XTable.XTableModel, "Id")
    local tab = XTableManager.ReadByIntKey(Ui_MODEL_TRANSFORM_PATH, XTable.XTableUiModelTransform, "Id")
    for _, config in pairs(tab) do
        if not UiModelTransformTemplates[config.UiName] then
            UiModelTransformTemplates[config.UiName] = {}
        end
        UiModelTransformTemplates[config.UiName][config.ModelName] = config
    end

    local sceneTab = XTableManager.ReadByIntKey(Ui_SCENE_TRANSFORM_PATH, XTable.XTableUiSceneTransform, "Id")
    for _, config in pairs(sceneTab) do
        if not UiSceneTransformTemplates[config.UiName] then
            UiSceneTransformTemplates[config.UiName] = {}
        end
        UiSceneTransformTemplates[config.UiName][config.SceneUrl] = config
    end
end

function XModelManager.GetModelPath(modelId)
    if not ModelTemplates[modelId] then
        XLog.Error("XModelManager.GetModelPath error, modelId not found, path:" .. MODEL_TABLE_PATH .. " Id:" .. tostring(modelId))
        return
    end
    return ModelTemplates[modelId].ModelPath
end

function XModelManager.GetLowModelPath(modelId)
    if not ModelTemplates[modelId] then
        XLog.Error("XModelManager.GetLowModelPath error, modelId not found, path:" .. MODEL_TABLE_PATH .. " Id:" .. tostring(modelId))
        return
    end
    return ModelTemplates[modelId].LowModelPath
end

function XModelManager.GetControllerPath(modelId)
    if not ModelTemplates[modelId] then
        XLog.Error("XModelManager.GetControllerPath error, modelId not found, path:" .. MODEL_TABLE_PATH .. " Id:" .. tostring(modelId))
        return
    end
    return ModelTemplates[modelId].ControllerPath
end

function XModelManager.GetRoleModelConfig(uiName, modelName)
    if not uiName or not modelName then
        XLog.Error("XModelManager.GetRoleMoadelConfig: uiName or modelName nil")
        return
    end

    if UiModelTransformTemplates[uiName] then
        return UiModelTransformTemplates[uiName][modelName]
    end
end

function XModelManager.GetSceneModelConfig(uiName, sceneUrl)
    if not uiName or not sceneUrl then
        XLog.Error("XModelManager.GetRoleMoadelConfig: uiName or modelName nil")
        return
    end

    if UiSceneTransformTemplates[uiName] then
        return UiSceneTransformTemplates[uiName][sceneUrl]
    end
end

function XModelManager.GetModelTemplates(modelId)
    local model = ModelTemplates[modelId]
    if not model then
        XLog.Error("XModelManager.GetModelTemplates error, modelId not found, path:" .. MODEL_TABLE_PATH .. " Id:" .. tostring(modelId))
    end
    return model

end

function XModelManager.LoadSceneModel(sceneUrl, parent, uiName)
    local scene = CS.LoadHelper.InstantiateScene(sceneUrl)
    scene.transform:SetParent(parent, false)
    if uiName then
        XModelManager.SetSceneTransform(sceneUrl, scene, uiName)
    end
    return scene
end

--新UI框架
function XModelManager.LoadRoleModel(name, target, refName, cb)
    if not name or not target then
        return
    end

    local modelPath = XModelManager.GetModelPath(name)
    local model = CS.LoadHelper.InstantiateNpc(modelPath, refName)
    model.transform:SetParent(target, false)
    model.gameObject:SetLayerRecursively(target.gameObject.layer)
    model.transform.localScale = CS.UnityEngine.Vector3.one
    model.transform.localPosition = CS.UnityEngine.Vector3.zero
    model.transform.localRotation = CS.UnityEngine.Quaternion.identity

    if cb then
        cb(model)
    end
end

local setModeTransform = function(target, config)
    if not target or not config then
        return
    end

    target.transform.localPosition = CS.UnityEngine.Vector3(config.PositionX, config.PositionY, config.PositionZ)
    --检查数据 模型旋转
    target.transform.localEulerAngles = CS.UnityEngine.Vector3(config.RotationX, config.RotationY, config.RotationZ)
    --检查数据 模型大小
    target.transform.localScale = CS.UnityEngine.Vector3(
    config.ScaleX == 0 and 1 or config.ScaleX,
    config.ScaleY == 0 and 1 or config.ScaleY,
    config.ScaleZ == 0 and 1 or config.ScaleZ
    )
end

function XModelManager.SetSceneTransform(sceneUrl, target, uiName)
    target.transform.localPosition = CS.UnityEngine.Vector3.zero
    target.transform.localEulerAngles = CS.UnityEngine.Vector3.zero
    target.transform.localScale = CS.UnityEngine.Vector3.one

    if not uiName then
        return
    end

    local config = XModelManager.GetSceneModelConfig(uiName, sceneUrl)
    if not config then
        return
    end

    setModeTransform(target, config)

end

function XModelManager.SetRoleTransform(name, target, uiName)
    target.transform.localPosition = CS.UnityEngine.Vector3.zero
    target.transform.localEulerAngles = CS.UnityEngine.Vector3.zero
    target.transform.localScale = CS.UnityEngine.Vector3.one

    if not uiName then
        return
    end

    local config = XModelManager.GetRoleModelConfig(uiName, name)
    if not config then
        return
    end

    setModeTransform(target, config)
end

function XModelManager.LoadWeaponModel(name, target, config, cb)
    if not name or XTool.UObjIsNil(target) then
        return
    end

    if type(config) == "function" then
        cb = config
        config = nil
    end

    local model = target:LoadPrefab(name, false)
    if config then
        setModeTransform(model, config)
    end


    if cb then
        cb(model)
    end

end

--==============================--
--desc: 加载角色武器
--@roleModel: 角色模型
--@weaponNameList: 武器模型名字列表
--==============================--
function XModelManager.LoadRoleWeaponModel(roleModel, weaponNameList, refName, cb)
    if not roleModel then
        return
    end

    for i = 1, #weaponNameList do
        local name = weaponNameList[i]
        if name then
            local weaponCase = roleModel.transform.FindTransform(roleModel.transform, "WeaponCase" .. i)
            if not weaponCase then
                XLog.Warning("XModelManager.LoadRoleWeaponModel warning, " .. "WeaponCase" .. i .. " not found")
            else
                XModelManager.LoadWeaponModel(name, weaponCase, nil, cb)
            end
        end
    end

    -- 如果不加载武器，则直接执行CallBack
    if #weaponNameList <= 0 and cb then
        cb()
    end
end