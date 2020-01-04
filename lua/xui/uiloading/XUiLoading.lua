local XUiLoading = XLuaUiManager.Register(XLuaUi, "UiLoading")

function XUiLoading:OnAwake()
    XTool.InitUiObject(self)
end

function XUiLoading:OnStart(...)
    
    local args = { ... }
    self.LoadingTab = XDataCenter.LoadingManager.GetLoadingTab(args[1])

    if not self.LoadingTab then
        return
    end

    --设置背景
    if self.LoadingTab.ImageUrl then
        self.Bg = self.Bg:SetRawImage(self.LoadingTab.ImageUrl)
    else
		self.Bg.texture = nil
    end

    --设置标题
    if self.LoadingTab.Title then

        self.TitleText.gameObject:SetActive(true)
        self.TitleText.text = self.LoadingTab.Title

        --设置内容
        if self.LoadingTab.Desc then
            self.Desc.gameObject:SetActive(true)
            self.Desc.text = string.gsub(self.LoadingTab.Desc, "\\n", "\n")
        else
            self.Desc.gameObject:SetActive(false)
        end

    else
        self.TitleText.gameObject:SetActive(false)
    end
    
end