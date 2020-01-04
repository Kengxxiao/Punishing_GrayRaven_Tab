-- 家具分数控件
XUiFurnitureScore = XClass()

function XUiFurnitureScore:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.GridAttributePool = {}
    self.GridAttribute.gameObject:SetActive(false)
end


--设置分数
function XUiFurnitureScore:SetScore(data)
    if not data then
        return
    end

    local attributes = {}
    for k, v in pairs(data) do
        attributes[k] = {
            Id = k,
            Val = v
        }
    end

    XUiHelper.CreateTemplates(self.RootUi, self.GridAttributePool, attributes, XUiGridAttribute.New, self.GridAttribute, self.Transform, XUiGridAttribute.Init)
    for i=1, #attributes do
        self.GridAttributePool[i].GameObject:SetActive(true)
    end
end

return XUiFurnitureScore