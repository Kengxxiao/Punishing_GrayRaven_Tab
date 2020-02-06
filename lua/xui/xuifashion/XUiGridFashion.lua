XUiGridFashion = XClass()

function XUiGridFashion:Ctor(rootUi, ui, id, index, clickCallback)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Index = index
    self.ClickCallback = clickCallback

    self:InitAutoScript()
    self:SetSelect(false)
    self:UpdateGrid(id)
    XTool.InitUiObject(self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFashion:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFashion:PlayAnimation()
    self.GridFashionTimeline:PlayTimelineAnimation()
end

function XUiGridFashion:AutoInitUi()
    self.ImgSelected = XUiHelper.TryGetComponent(self.Transform, "ImgSelected", "Image")
    self.ImgQuality = XUiHelper.TryGetComponent(self.Transform, "ImgQuality", "Image")
    self.RImgIcon = XUiHelper.TryGetComponent(self.Transform, "ImgQuality/RImgIcon", "RawImage")
    self.BtnFashion = XUiHelper.TryGetComponent(self.Transform, "BtnFashion", "Button")
    self.ImgLock = XUiHelper.TryGetComponent(self.Transform, "ImgLock", "Image")
    self.ImgUse = XUiHelper.TryGetComponent(self.Transform, "ImgUse", "Image")
    self.ImgRedPoint = XUiHelper.TryGetComponent(self.Transform, "ImgRedPoint", "Image")
end

function XUiGridFashion:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFashion:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFashion:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFashion:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnFashion, self.OnBtnFashionClick)
end
-- auto

function XUiGridFashion:OnBtnFashionClick()
    if self.ClickCallback then
        self.ClickCallback(self.FashionId, self.Index)
    end    
end

function XUiGridFashion:SetSelect(isSelect)
    if self.ImgSelected then
        self.ImgSelected.gameObject:SetActive(isSelect)
    end
end

function XUiGridFashion:UpdateStatus()
    local status = XDataCenter.FashionManager.GetFashionStatus(self.FashionId)

    if status == XDataCenter.FashionManager.FashionStatus.UnOwned then -- 未获得
        self.ImgLock.gameObject:SetActive(true)
        self.ImgUse.gameObject:SetActive(false)
        self.ImgRedPoint.gameObject:SetActive(false)
        self.ImgQuality:GetComponent("CanvasGroup").alpha = 0.6
    elseif status == XDataCenter.FashionManager.FashionStatus.Dressed then --已穿戴
        self.ImgLock.gameObject:SetActive(false)
        self.ImgUse.gameObject:SetActive(true)
        self.ImgRedPoint.gameObject:SetActive(false)
        self.ImgQuality:GetComponent("CanvasGroup").alpha = 1.0
    elseif status == XDataCenter.FashionManager.FashionStatus.Lock then --已获得，未解锁
        self.ImgLock.gameObject:SetActive(false)
        self.ImgUse.gameObject:SetActive(false)
        self.ImgRedPoint.gameObject:SetActive(true)
        self.ImgQuality:GetComponent("CanvasGroup").alpha = 0.6
    elseif status == XDataCenter.FashionManager.FashionStatus.UnLock then --已解锁
        self.ImgLock.gameObject:SetActive(false)
        self.ImgUse.gameObject:SetActive(false)
        self.ImgRedPoint.gameObject:SetActive(false)
        self.ImgQuality:GetComponent("CanvasGroup").alpha = 1.0
    end
end

function XUiGridFashion:UpdateGrid(id)
    if not id then
        return
    end

    if self.FashionId ~= id then
        self.FashionId = id
        local template = XDataCenter.FashionManager.GetFashionTemplate(id)
        self.RImgIcon:SetRawImage(template.Icon)
        XUiHelper.SetQualityIcon(self.RootUi, self.ImgQuality, template.Quality)
    end

    self:UpdateStatus()
end
