XUiPanelRoleModel = Class("XUiPanelRoleModel")

local UI_MODEL_ANIMATOR_PLAY_NAME = "StandAct0101"
--==============================--
-- RoleModelPool = {["model"] = model, ["weaponList"] = list, ["characterId"] = characterId}
--==============================--
function XUiPanelRoleModel:Ctor(ui, refName, hideWeapon, showShadow, loadClip, setFocus, fixLight)
    self.RefName = refName
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RoleModelPool = {}
    self.HideWeapon = hideWeapon and true or false
    self.ShowShadow = showShadow
    self.SetFocus = setFocus
    self.FixLight = fixLight
    if loadClip == nil then
        self.LoadClip = true
    else
        self.LoadClip = loadClip and true
    end

end

--设置默认动画
function XUiPanelRoleModel:SetDefaultAnimation(animationName)
    self.DefaultAnimation = animationName
end

function XUiPanelRoleModel:UpdateRoleModel(roleName, targetPanelRole, targetUiName, cb)
    if not roleName then
        XLog.Error("XUiPanelCharRole:UpdateRoleModel error: roleName is nil")
        return
    end

    local modelConfig = XModelManager.GetModelTemplates(roleName)

    local defaultAnimation = self.DefaultAnimation or modelConfig.UiDefaultAnimationPath
    self.DefaultAnimation = nil

    local modelPool = self.RoleModelPool
    local curRoleName = self.CurRoleName
    local curModelInfo = modelPool[curRoleName]
    if curModelInfo then
        curModelInfo.Model.gameObject:SetActive(false)
		curModelInfo.time = os.clock()
    end
    if curRoleName ~= roleName then
        self.CurRoleName = roleName
    end
	
	local needRemove = nil

    for k,v in pairs(modelPool) do
        --不等于当前要显示的模型且时间超出5秒的都要删掉
        if k ~= roleName and v and v.time then
            local diff = os.clock() - v.time
            if diff >= 5 then
                if needRemove == nil then
                    needRemove = {}
                end
                table.insert(needRemove,k)
            end
        end
    end

    --删除超时的模型
    if needRemove then
        for i = 1, #needRemove do
            local tempRoleName = needRemove[i]
            local modelInfo = modelPool[tempRoleName]
            if modelInfo.Model and modelInfo.Model:Exist() then
                CS.UnityEngine.Object.Destroy(modelInfo.Model.gameObject)
            end
            modelPool[tempRoleName] = nil
        end
    end

    local modelInfo = modelPool[roleName]
    if modelInfo then
        modelInfo.Model.gameObject:SetActive(true)
        self:RoleModelLoaded(roleName, targetUiName, cb)
    else
        XModelManager.LoadRoleModel(self.CurRoleName, self.Transform, self.RefName, function(model)
            local modelInfo = {}
            modelInfo.Model = model
            self.RoleModelPool[roleName] = modelInfo

            if self.LoadClip then
                self:LoadAnimationClips(model.gameObject, defaultAnimation, function()
                    self:RoleModelLoaded(roleName, targetUiName, cb)
                end)
            else
                self:RoleModelLoaded(roleName, targetUiName, cb)
            end
        end)
    end
end

function XUiPanelRoleModel:LoadAnimationClips(model, defaultAnimation, cb)
    if model == nil or not model:Exist() then
        XLog.Error("XUiPanelRoleModel.LoadAnimation model = nil ")
        return
    end

    local loadAnimationClip = model.gameObject:GetComponent(typeof(CS.XLoadAnimationClip))
    if loadAnimationClip == nil or not loadAnimationClip:Exist() then
        loadAnimationClip = model.gameObject:AddComponent(typeof(CS.XLoadAnimationClip))
        local clips = {}
        table.insert(clips, defaultAnimation)

        if not next(clips) or not loadAnimationClip:Exist() then
            XLog.Error("XUiPanelRoleModel.LoadAnimation playRoleAnimation = nil ")
            return
        end

        local activeState = model.gameObject.activeSelf
        model.gameObject:SetActive(false)
        loadAnimationClip:LoadAnimationClips(clips, function()
            model.gameObject:SetActive(activeState)
            if cb then cb() end
        end)
    else
        if cb then cb() end
    end
end

function XUiPanelRoleModel:RoleModelLoaded(name, uiName, cb)
    if not self.CurRoleName then return end
    local modelInfo = self.RoleModelPool[self.CurRoleName]
    if not modelInfo then return end
    local model = modelInfo.Model

    XModelManager.SetRoleTransform(name, model, uiName)

    if cb then
        cb(model)
    end

    -- 阴影要放在武器模型加载完之后
    if self.ShowShadow then
        CS.XShadowHelper.AddShadow(self.GameObject)
    end

    if self.SetFocus then
        CS.XGraphicManager.Focus = model.transform
    end
end

function XUiPanelRoleModel:GetModelName(characterId)
    local quality
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    if character then
        quality = character.Quality
    end

    return XDataCenter.CharacterManager.GetCharModel(characterId, quality)
end

--==============================--
--desc: 更新角色模型
--@characterId: 角色id
--@targetPanelRole: 目标面板
--@targetUiName: 目标ui名
--==============================--
function XUiPanelRoleModel:UpdateCharacterModel(characterId, targetPanelRole, targetUiName, cb, weapoonCb, fashionId, growUpLevel, hideEffect)
    local resourcesId
    if fashionId then
        resourcesId = XDataCenter.FashionManager.GetResourcesId(fashionId)
    else
        resourcesId = XDataCenter.FashionManager.GetFashionResouceIdByCharId(characterId)
    end

    local modelName
    if resourcesId then
        modelName = XDataCenter.CharacterManager.GetCharResModel(resourcesId)
    else
        modelName = self:GetModelName(characterId)
    end
    if not modelName then
        return
    end

    self:UpdateRoleModel(modelName, targetPanelRole, targetUiName, function(model)
        if not self.HideWeapon then
            self:UpdateCharacterWeaponModels(characterId, modelName, weapoonCb, hideEffect)
        end

        if not hideEffect then
            self:UpdateCharacterLiberationLevelEffect(modelName, characterId, growUpLevel)
        end

        if cb then
            cb(model)
        end

        if self.FixLight then
            CS.XGraphicManager.FixUICharacterLightDir(model.gameObject)
        end
    end)
end

--==============================--
--desc: 更新机器人角色模型
--==============================--
function XUiPanelRoleModel:UpdateRobotModel(characterId, weapoonCb, fashionId, equipTemplateId)
    local resourcesId
    if fashionId then
        resourcesId = XDataCenter.FashionManager.GetResourcesId(fashionId)
    else
        resourcesId = XDataCenter.FashionManager.GetFashionResouceIdByCharId(characterId)
    end

    local modelName
    if resourcesId then
        modelName = XDataCenter.CharacterManager.GetCharResModel(resourcesId)
    else
        modelName = self:GetModelName(characterId)
    end
    if not modelName then
        return
    end

    self:UpdateRoleModel(modelName, nil, nil, function(model)
            if not self.HideWeapon then
                self:UpdateCharacterWeaponModels(characterId, modelName, weapoonCb, true, equipTemplateId)
            end

            if self.FixLight then
                CS.XGraphicManager.FixUICharacterLightDir(model.gameObject)
            end
        end)
end

function XUiPanelRoleModel:UpdateCharacterResModel(resId, characterId, targetPanelRole, targetUiName, cb, growUpLevel)
    local modelName = XDataCenter.CharacterManager.GetCharResModel(resId)
    if modelName then
        self:UpdateRoleModel(modelName, targetPanelRole, targetUiName, function(model)
            if not self.HideWeapon then
                self:UpdateCharacterWeaponModels(characterId, modelName)
            end

            self:UpdateCharacterLiberationLevelEffect(modelName, characterId, growUpLevel)

            if cb then
                cb(model)
            end
        end)
    end
end

function XUiPanelRoleModel:UpdateCharacterModelByModelId(modelId, characterId, targetPanelRole, targetUiName, cb, growUpLevel)
    if not modelId then return end

    self:UpdateRoleModel(modelId, targetPanelRole, targetUiName, function(model)
        if not self.HideWeapon then
            self:UpdateCharacterWeaponModels(characterId, modelId)
        end

        self:UpdateCharacterLiberationLevelEffect(modelId, characterId, growUpLevel)

        if cb then
            cb(model)
        end
    end)
end

function XUiPanelRoleModel:UpdateBossModel(modelName, targetUiName, targetPanelRole, cb)
    if modelName then
        self:UpdateRoleModel(modelName, targetPanelRole, targetUiName, function(model)
            if cb then
                cb(model)
            end
        end)
    end
end

function XUiPanelRoleModel:UpdateCharacterModelByFightNpcData(fightNpcData, cb)
    local char = fightNpcData.Character
    local equips = fightNpcData.Equips

    if char then
        local modelName = nil
        local fashionId = char.FashionId

        if fashionId then
            local fashion = XDataCenter.FashionManager.GetFashionTemplate(fashionId)
            modelName = XDataCenter.CharacterManager.GetCharResModel(fashion.ResourcesId)
        else
            -- modelName = XDataCenter.CharacterManager.GetCharModel(char.Id, char.Quality)
            modelName = self:GetModelName(char.Id)
        end

        if modelName then
            self:UpdateRoleModel(modelName, nil, nil, function(model)
                self:UpdateEquipsModels(model, equips)
                self:UpdateCharacterLiberationLevelEffect(modelName, char.Id, char.LiberateLv)
                if cb then
                    cb(model)
                end
            end)
        end
    end
end

function XUiPanelRoleModel:UpdateEquipsModels(charModel, equips)
    local weaponModelNameList = XDataCenter.EquipManager.GetWeaponModelNameListByEquips(equips)
    if not weaponModelNameList or not next(weaponModelNameList) then
        return
    end
    XModelManager.LoadRoleWeaponModel(charModel, weaponModelNameList, self.RefName)
end

--==============================--
--desc: 更新角色武器模型
--@characterId: 角色id
--==============================--
function XUiPanelRoleModel:UpdateCharacterWeaponModels(characterId, modelName, weapoonCb, hideEffect, equipTemplateId)
    local weaponModelNameList = nil
    if equipTemplateId then
        weaponModelNameList = XDataCenter.EquipManager.GetWeaponModelNameList(equipTemplateId)
    else
        weaponModelNameList = XDataCenter.EquipManager.GetWeaponModelNameListByCharacterId(characterId, hideEffect)
    end

    if not weaponModelNameList or not next(weaponModelNameList) then
        return
    end
    if not modelName then
        modelName = self:GetModelName(characterId)
    end

    local roleModel = self.RoleModelPool[modelName]
    if not roleModel then
        return
    end

    XModelManager.LoadRoleWeaponModel(roleModel.Model, weaponModelNameList, self.RefName, weapoonCb, characterId, hideEffect)
end

local JudgeAnimator = function(animator, name)
    if not animator or not animator:Exist() then
        return false
    end

    local animationClips = animator.runtimeAnimatorController.animationClips
    for i = 0, animationClips.Length - 1 do
        local tempClip = animationClips[i]
        if tempClip ~= null and tempClip.name == name then
            return true
        end

    end
    XLog.Warning(animator.runtimeAnimatorController.name .. "  不存在動作ID：" .. name)
    return false
end

function XUiPanelRoleModel:PlayAnima(AnimaName)
    if self.CurRoleName and self.RoleModelPool[self.CurRoleName] and self.RoleModelPool[self.CurRoleName].Model then
        local animator = self.RoleModelPool[self.CurRoleName].Model:GetComponent("Animator")
        if animator:Exist() and animator.gameObject.activeInHierarchy and animator.runtimeAnimatorController and JudgeAnimator(animator, AnimaName) then
            animator:Play(AnimaName)
        end
    end
end

function XUiPanelRoleModel:ShowRoleModel()
    self.GameObject:SetActive(true)
end

function XUiPanelRoleModel:HideRoleModel()
    self.GameObject:SetActive(false)
end

--==============================--
--desc: 更新角色解放特效
--@characterId: 角色id
--==============================--
function XUiPanelRoleModel:UpdateCharacterLiberationLevelEffect(modelName, characterId, growUpLevel)
    local modelInfo = self.RoleModelPool[modelName]
    local model = modelInfo and modelInfo.Model
    if not model then return end

    local liberationFx = modelInfo.LiberationFx
    local rootName, fxPath = XDataCenter.CharacterManager.GetCharLiberationLevelEffectRootAndPath(characterId, growUpLevel)
    if not rootName or not fxPath then
        if liberationFx then
            liberationFx:SetActiveEx(false)
        end
        return
    end

    if not liberationFx then
        local rootTransform = model.transform:FindTransform(rootName)
        if XTool.UObjIsNil(rootTransform) then
            XLog.Error("XUiPanelRoleModel:UpdateCharacterLiberationLevelEffect Error:can Not find rootTransform in this model, rootName is:" .. rootName)
            return
        end
        modelInfo.LiberationFx = rootTransform.gameObject:LoadPrefab(fxPath, false)
    else
        liberationFx:SetActiveEx(true)
    end
end