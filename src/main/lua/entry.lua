--
-- entry.lua
--


local EntryClass = {}

function EntryClass:setPublisher(addr)
	self.publisher = addr
end

function EntryClass:revoke()
	self.revoked = true
end

function EntryClass:isRevoked()
	return (self.revoked == true)
end

function EntryClass:encode()
	return json.encode(self)
end



local Entry = {}

function Entry.new(argv)
	assert(notEmpty(argv.addr), 'nil or empty address')
	return setmetatable(argv, { __index = EntryClass })
end

function Entry.decode(encoded)
	local argv = json.decode(encoded)
	return Entry.new(argv)
end
