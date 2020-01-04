XNpcAttrs = XClass()

function XNpcAttrs:Ctor(templateId, level)
    self.TemplateId = templateId
    self.Level = level
    self.Attrtibs = CS.XNpcManager.GetNpcAttrib(templateId, level)
end

function XNpcAttrs:GetCharAttrValue(id)
    return self.Attrtibs[id].Value
end

function XNpcAttrs:ChangeLevel(level)
    if not level or self.Level == level then
        return
    end
    
    self.Level = level
    self.Attrtibs = CS.XNpcManager.GetNpcAttrib(self.TemplateId, level)
end
