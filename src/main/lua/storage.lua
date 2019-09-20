--
-- storage.lua
--


local StorageClass = {}

function StorageClass:add(entry)
	self.stateMap[self.name..'_'..entry.addr] = entry:encode()
	if self.keepTrack then
		self:keyAdd(entry.addr)
	end
end

function StorageClass:revoke(address)
	local entry = self:fetch(address)
	if (entry ~= nil and entry:isRevoked() == false) then
		entry:revoke()
		self.stateMap[self.name..'_'..entry.addr] = entry:encode()
		if self.keepTrack then
			self:keyRemove(address)
		end
	end
end

function StorageClass:remove(address)
	local entry = self:fetch(address)
	if (entry ~= nil) then
		self.stateMap:delete(self.name..'_'..address)
		if self.keepTrack then
			self:keyRemove(address)
		end
	end
end

function StorageClass:fetch(address)
	local encoded = self.stateMap[self.name..'_'..address]
	if (encoded ~= nil and encoded ~= '') then
		return Entry.decode(encoded)
	end
	return nil
end

function StorageClass:fetchRaw(address)
	local encoded = self.stateMap[self.name..'_'..address]
	if (encoded ~= nil and encoded ~= '') then
		return encoded
	end
	return nil
end

function StorageClass:has(address)
	local entry = self:fetch(address)
	if (entry == nil or entry:isRevoked()) then
		return false
	end
	return true
end

function StorageClass:keysRaw()
	return self.stateMap[self.name..'.keys']
end

function StorageClass:keys()
	local encoded = self.stateMap[self.name..'.keys']
	if encoded ~= nil and encoded ~= '' then
		return json.decode(encoded)
	end
	return nil
end

function StorageClass:keyAdd(address)
	local keys = self:keys()
	if keys == nil then
		keys = {}
	end
	table.insert(keys, address)
	self.stateMap[self.name..'.keys'] = json.encode(keys)
end

function StorageClass:keyRemove(address)
	local keys = self:keys()
	for i=#keys,1,-1 do
		if keys[i] == address then
			table.remove(keys, i)
			break
		end
	end
	self.stateMap[self.name..'.keys'] = json.encode(keys)
end


local Storage = {}

function Storage.new(argv)
	assert(argv.stateMap ~= nil, 'invalid storage state map')
	assert(argv.name ~= nil and argv.name ~= '', 'invalid storage name')
	return setmetatable({
		stateMap = argv.stateMap,
		name = argv.name,
		keepTrack = argv.keepTrack
	}, {__index = StorageClass})
end
