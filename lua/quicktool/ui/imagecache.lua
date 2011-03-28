QuickTool.ImageCache = QuickTool.ImageCache or {}
local ImageCache = QuickTool.ImageCache
ImageCache.__index = ImageCache

function ImageCache:ctor ()
	self.Images = {}
	
	self.LoadInterval = 0.1
	self.LastLoadTime = 0
	self:GetImage ("gui/silkicons/arrow_refresh")
end

function ImageCache:GetImage (image)
	image = image:lower ()
	if self.Images [image] then
		return self.Images [image]
	end	
	if SysTime () - self.LastLoadTime < self.LoadInterval then
		return self:GetImage ("gui/silkicons/arrow_refresh")
	end
	self.LastLoadTime = SysTime ()
	
	local ImageCacheEntry = QuickTool.ImageCacheEntry (image)
	self.Images [image] = ImageCacheEntry
	return ImageCacheEntry
end

ImageCache:ctor ()