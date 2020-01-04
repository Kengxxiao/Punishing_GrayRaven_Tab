--local XUiFashion = XUiManager.Register("UiFashion")
local XUiFashion = XLuaUiManager.Register(XLuaUi, "UiFashion")

local CameraIndex = {
    Normal = 1,
    Near = 2,
}

local LONG_CLICK_TIME = 20000
local UNLOCK_TIMER_INTERVAL = 100
local UNLOCK_TIMER_LOOP = 21
local GridTimeAnimation = 40

function XUiFashion:OnAwake()
    self:InitAutoScript()
end

function XUiFashion:OnStart(charId, callBack)
    self:InitSceneRoot() --设置摄像机
    self.CallBack = callBack
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.FashionGrids = {}
    self.BtnLensOut.gameObject:SetActiveEx(true)
    self.BtnLensIn.gameObject:SetActiveEx(false)

    self.BtnLensOut.CallBack = function() self:OnBtnLensOut() end
    self.BtnLensIn.CallBack = function() self:OnBtnLensIn() end

    local root = self:GetSceneRoot().transform
    self.RoleModelPanel = XUiPanelRoleModel.New(root:FindTransform("UiModelParent"), self.Name, nil, true, nil, true)
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")
    XUiHelper.RegisterSliderChangeEvent(self, self.SliderCharacterHight, self.OnSliderCharacterHightChanged)

    if charId == nil then
        return
        XLog.Error("XUiFashion:OnOpen error: charId is nil")
    end

    self.CharID = charId

    --XCameraHelper.SetUiCameraParam(self.Name)
    --XCameraHelper.SetCameraTarget(CS.XUiManager.CameraController, self.PanelRoleModel)
end

function XUiFashion:OnSliderCharacterHightChanged()
    local pos = self.CameraNear[CameraIndex.Near].position
    self.CameraNear[CameraIndex.Near].position = CS.UnityEngine.Vector3(pos.x, 1.7 - self.SliderCharacterHight.value, pos.z)
end

--初始化摄像机
function XUiFashion:InitSceneRoot()
    local root = self:GetSceneRoot().transform

    self.CameraNear = {
        [CameraIndex.Normal] = root:FindTransform("FashionCamNearMain"),
        [CameraIndex.Near] = root:FindTransform("FashionCamNearest"),
    }
end

function XUiFashion:UpdateCamera(camera)
    for _, cameraIndex in pairs(CameraIndex) do
        self.CameraNear[cameraIndex].gameObject:SetActive(cameraIndex == camera)
    end
end

function XUiFashion:OnBtnLensOut(charId)
    self.BtnLensOut.gameObject:SetActiveEx(false)
    self.BtnLensIn.gameObject:SetActiveEx(true)
    self:UpdateCamera(CameraIndex.Near)
end

function XUiFashion:OnBtnLensIn(charId)
    self.BtnLensOut.gameObject:SetActiveEx(true)
    self.BtnLensIn.gameObject:SetActiveEx(false)
    self:UpdateCamera(CameraIndex.Normal)
end

function XUiFashion:OnOpenDefault(charId)
    self.CharacterList = XDataCenter.CharacterManager.GetCharacterList()
    if not self.CharacterList then return end

    self.CurFashionId = nil

    for i = 1, #self.CharacterList do
        if charId == self.CharacterList[i].Id then
            self.CharIndex = i
            break
        end
    end

    if not self.CharIndex then
        XLog.Error("XUiFashion:OnOpen error: charId is nil, charId is " .. charId)
        return
    end

    self:SelectCharacter()
end

function XUiFashion:OnEnable()
    CS.XGraphicManager.UseUiLightDir = true
    self:OnOpenDefault(self.CharID)
    self:UpdateUnLockPanleInfo(false)
end

function XUiFashion:OnDisable()
    CS.XGraphicManager.UseUiLightDir = false
    if self.CurAnimationTimerId then
        CS.XScheduleManager.UnSchedule(self.CurAnimationTimerId)
        self.CurAnimationTimerId = nil
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFashion:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFashion:AutoInitUi()
    self.TxtFashionName = self.Transform:Find("FullScreenBackground/BgInfo/TxtFashionName"):GetComponent("Text")
    self.PanelAssistDistanceTip = self.Transform:Find("SafeAreaContentPane/PanelAssistDistanceTip")
    self.TxtDistanceDesc = self.Transform:Find("SafeAreaContentPane/PanelAssistDistanceTip/BgText/TxtDistanceDesc"):GetComponent("Text")
    self.PanelFashion = self.Transform:Find("SafeAreaContentPane/PanelFashion")
    self.PanelDrag = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/CharInfo/PanelDrag")
    self.PanelLock = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/CharInfo/PanelLock")
    self.TxtCharacterName = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/CharInfo/Botton/TxtCharacterName"):GetComponent("Text")
    self.BtnNext = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/CharInfo/Botton/BtnNext"):GetComponent("Button")
    self.BtnLast = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/CharInfo/Botton/BtnLast"):GetComponent("Button")
    self.TxtUseNumber = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/Desc/TxtUseNumber"):GetComponent("Text")
    self.TxtAllNumber = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/Desc/TxtUseNumber/TxtAllNumber"):GetComponent("Text")
    self.GridFashion = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/FashionListView/Viewport/GridFashion")
    self.ImgQuality = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/FashionListView/Viewport/GridFashion/ImgQuality"):GetComponent("Image")
    self.RImgIcon = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/FashionListView/Viewport/GridFashion/ImgQuality/RImgIcon"):GetComponent("RawImage")
    self.PanelFashionContent = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/FashionListView/Viewport/PanelFashionContent")
    self.BtnUse = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/BtnUse"):GetComponent("Button")
    self.BtnFashionUnLock = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/BtnFashionUnLock"):GetComponent("Button")
    self.Uizhezhao = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/BtnFashionUnLock/FxUiButton/Zheng/Uizhezhao")
    self.BtnUsed = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/BtnUsed"):GetComponent("Button")
    self.PanelUnOwed = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/PanelUnOwed")
    self.BtnGet = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/FashionList/PanelUnOwed/BtnGet"):GetComponent("Button")
    self.PanelRoleModel = self.Transform:Find("SafeAreaContentPane/PanelFashion/CharacterInfo/PanelRoleModel")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelFashion/PanelAsset")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelFashion/TopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelFashion/TopButton/BtnMainUi"):GetComponent("Button")
    self.PanelUnlockShow = self.Transform:Find("SafeAreaContentPane/PanelUnlockShow")
    self.PanelUnlock = self.Transform:Find("SafeAreaContentPane/PanelUnlockShow/PanelUnlock")
    self.ImgUnlockShowIcon = self.Transform:Find("SafeAreaContentPane/PanelUnlockShow/PanelUnlock/GameObject/ImgUnlockShowIcon"):GetComponent("Image")
    self.TxtUnlockFashionName = self.Transform:Find("SafeAreaContentPane/PanelUnlockShow/PanelUnlock/TxtUnlockFashionName"):GetComponent("Text")
    self.RImgFashionIcon = self.Transform:Find("SafeAreaContentPane/PanelUnlockShow/PanelUnlock/RImgFashionIcon"):GetComponent("RawImage")
end

function XUiFashion:AutoAddListener()
    self:RegisterClickEvent(self.BtnNext, self.OnBtnNextClick)
    self:RegisterClickEvent(self.BtnLast, self.OnBtnLastClick)
    self:RegisterClickEvent(self.BtnUse, self.OnBtnUseClick)
    self:RegisterClickEvent(self.BtnFashionUnLock, self.OnBtnFashionUnLockClick)
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
function XUiFashion:OnBtnFashionUnLockClick(...)
    local status = XDataCenter.FashionManager.GetFashionStatus(self.CurFashionId)
    if status ~= XDataCenter.FashionManager.FashionStatus.Lock then
        return
    end
    self:UpdateUnLockPanleInfo(true)
end

function XUiFashion:SelectCharacter()
    local charId = self.CharacterList[self.CharIndex].Id
    local fashionList = XDataCenter.FashionManager.GetFashionByCharId(charId)
    if not fashionList then return end

    self.FashionList = fashionList
    self.CharID = charId

    local hasLast = self.CharIndex > 1
    local hasNext = self.CharacterList[self.CharIndex + 1] and XDataCenter.FashionManager.IsCharacterHasFashions(self.CharacterList[self.CharIndex + 1].Id)

    self.TxtCharacterName.text = XCharacterConfigs.GetCharacterName(self.CharID)
    self.BtnNext.interactable = hasNext
    self.BtnLast.interactable = hasLast
    self:RefreshGrid(self.FashionList)
end

function XUiFashion:RefreshGrid(fashionList)
    if not fashionList or #fashionList <= 0 then
        XLog.Error("XUiFashion:RefreshGrid error: fashionList list is nil")
        return
    end

    local baseItem = self.GridFashion
    baseItem.gameObject:SetActive(false)
    local count = #fashionList
    local useCount = 0

    local defualtSelectId = 1
    local fashionStatus = XDataCenter.FashionManager.FashionStatus
    for i = 1, count do
        local fashionId = fashionList[i]
        local status = XDataCenter.FashionManager.GetFashionStatus(fashionId)

        if status == fashionStatus.Dressed then
            defualtSelectId = i
        end

        if status ~= fashionStatus.UnOwned then
            useCount = useCount + 1
        end

        local grid = self.FashionGrids[i]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(baseItem)
            grid = XUiGridFashion.New(self, item, fashionId, i, function(fashionId, index)
                self:UpdateInfo(fashionId, index)
            end)
            grid.Transform:SetParent(self.PanelFashionContent, false)
            self.FashionGrids[i] = grid
        else
            grid:UpdateGrid(fashionId)
        end

        grid.GameObject:SetActive(true)
        grid.Transform:SetAsLastSibling()
    end

    -- 关闭多余cell
    for i = count + 1, #self.FashionGrids do
        self.FashionGrids[i].GameObject:SetActive(false)
    end
    self:UpdateFashionCount(useCount, count)
    -- 设置默认选择
    self.FashionGrids[defualtSelectId]:OnBtnFashionClick()

    local grids = self.FashionGrids
    self.GridIndex = 1
    self.CurAnimationTimerId = CS.XScheduleManager.Schedule(function()
        local item = grids[self.GridIndex]
        if item then
            item:PlayAnimation()
        end
        self.GridIndex = self.GridIndex + 1
    end, GridTimeAnimation, count, 0)
end

function XUiFashion:UpdateFashionCount(useCount, allCount)
    self.TxtUseNumber.text = useCount
    self.TxtAllNumber.text = "/" .. allCount
end

function XUiFashion:UpdateInfo(fashionId, index)
    if fashionId then
        if self.CurFashionId == fashionId then
            return
        end

        self.CurFashionId = fashionId
    end

    if index then
        self.CurIndex = index
    end

    if self.CurCharacterGrid then
        self.CurCharacterGrid:SetSelect(false)
    end

    self.CurCharacterGrid = self.FashionGrids[self.CurIndex]
    self.CurCharacterGrid:SetSelect(true)

    self:UpdateCharacterInfo()
end

function XUiFashion:UpdateUnLockPanleInfo(state)
    if state == true then
        local template = XDataCenter.FashionManager.GetFashionTemplate(self.CurFashionId)

        if not template then
            return
        end

        self.TxtUnlockFashionName.text = string.format("涂装： %s", template.Name)
        self.RImgFashionIcon:SetRawImage(template.Icon)
        self.PanelUnlockShow.gameObject:SetActive(true)
        self.ImgUnlockShowIcon.fillAmount = 0

        XUiHelper.PlayAnimation
        (self, "AniPanelUnlockShowBegin", nil,
        function()
            if not self.PanelUnlockShow.gameObject:Exist() then
                return
            end

            self.PanelUnlockShow.gameObject:SetActive(false)

            local lockId = self.CurFashionId
            XDataCenter.FashionManager.UnlockFashion
            (lockId,
            function()
                if not self.GameObject:Exist() then
                    return
                end

                self:UpdateButtonState()
                if self.FashionGrids and self.CurIndex and self.FashionGrids[self.CurIndex] then
                    self.FashionGrids[self.CurIndex]:UpdateStatus()
                end
                self:PlayUnLockAnimation()
            end
            )
        end
        )
        return
    end

    self.PanelUnlockShow.gameObject:SetActive(false)
end

function XUiFashion:UpdateCharacterInfo()
    local func = function(model)
        if not model then return end

        self.PanelDrag:GetComponent("XDrag").Target = model.transform
        self.ImgEffectHuanren.gameObject:SetActive(false)
        self.ImgEffectHuanren.gameObject:SetActive(true)
    end

    local template = XDataCenter.FashionManager.GetFashionTemplate(self.CurFashionId)

    if not template then
        return
    end

    self.RoleModelPanel:UpdateCharacterResModel(template.ResourcesId, template.CharacterId, self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiFashion, func)
    self:SetUiSprite(self.ImgCurQuality, XDataCenter.FashionManager.GetDescIcon(template.Quality))
    self.TxtFashionName.text = template.Name
    -- 设置button
    self:UpdateButtonState()
end

function XUiFashion:UpdateButtonState()
    local status = XDataCenter.FashionManager.GetFashionStatus(self.FashionList[self.CurIndex])
    self.ImgQuality.fillAmount = 0

    if status == XDataCenter.FashionManager.FashionStatus.Dressed then
        self.PanelUnOwed.gameObject:SetActive(false)
        self.BtnUse.gameObject:SetActive(false)
        self.BtnUsed.gameObject:SetActive(true)
        self.BtnFashionUnLock.gameObject:SetActive(false)
    elseif status == XDataCenter.FashionManager.FashionStatus.UnLock then
        self.PanelUnOwed.gameObject:SetActive(false)
        self.BtnUse.gameObject:SetActive(true)
        self.BtnUsed.gameObject:SetActive(false)
        self.BtnFashionUnLock.gameObject:SetActive(false)
    elseif status == XDataCenter.FashionManager.FashionStatus.Lock then
        self.PanelUnOwed.gameObject:SetActive(false)
        self.BtnUse.gameObject:SetActive(false)
        self.BtnUsed.gameObject:SetActive(false)
        self.BtnFashionUnLock.gameObject:SetActive(true)
    elseif status == XDataCenter.FashionManager.FashionStatus.UnOwned then
        self.PanelUnOwed.gameObject:SetActive(true)
        self.BtnUse.gameObject:SetActive(false)
        self.BtnUsed.gameObject:SetActive(false)
        self.BtnFashionUnLock.gameObject:SetActive(false)
    end
end

function XUiFashion:PlayUnLockAnimation()
    local template = XDataCenter.FashionManager.GetFashionTemplate(self.CurFashionId)
    if not template then
        return
    end
    self.PanelAssistDistanceTip.gameObject:SetActive(true)
    self.TxtDistanceDesc.text = template.Name

    self.ImgEffectHuanren.gameObject:SetActive(false)
    self.ImgEffectHuanren.gameObject:SetActive(true)
    XUiHelper.PlayAnimation(self, "AniPanelAssistDistanceTip", nil, function()
        if self.GameObject:Exist() then
            self.PanelAssistDistanceTip.gameObject:SetActive(falses)

        end
    end)
end

function XUiFashion:OnBtnBackClick(...)
    if self.CallBack then
        self.CallBack()
    end
    self:Close()
end

function XUiFashion:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFashion:OnBtnUseClick(...)
    local count = #self.FashionList

    XDataCenter.FashionManager.UseFashion(self.CurFashionId, function()
        for i = 1, count do
            self.FashionGrids[i]:UpdateStatus()
        end
        XUiManager.TipText("UseSuccess")
        self:UpdateButtonState()
    end)
end

function XUiFashion:OnBtnLastClick(...)
    if self.CharIndex > 1 then
        self.CharIndex = self.CharIndex - 1
        self:SelectCharacter()
        self:PlayAnimation("Qiehuan")
    end
end

function XUiFashion:OnBtnNextClick(...)
    if self.CharIndex < #self.CharacterList then
        self.CharIndex = self.CharIndex + 1
        self:SelectCharacter()
        self:PlayAnimation("Qiehuan")
    end
end

function XUiFashion:OnBtnGetClick(...)
    XLuaUiManager.Open("UiTip", self.CurFashionId)
end