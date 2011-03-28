local PANEL = {}

--[[
	This uses a cache of the materials used instead of recreating them each time a new image control is created.
]]

function PANEL:Init ()
	self:SetTall (4)
	
	self.SortKey = ""
	self.Image = nil
end

function PANEL:GetImage ()
	return self.Image
end

function PANEL:Paint ()
	if self.Image then
		local Image = QuickTool.ImageCache:GetImage (self.Image)
		Image:Draw ((self:GetWide () - Image:GetWidth ()) * 0.5, (self:GetTall () - Image:GetHeight ()) * 0.5)
	end
end

function PANEL:SetImage (image)
	self.Image = image
end

vgui.Register ("QuickToolImage", PANEL, "Panel")