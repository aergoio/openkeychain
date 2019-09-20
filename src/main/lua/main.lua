import "./storage.lua"
import "./entry.lua"
import "./util.lua"


--
-- main.lua
--


-- Define variables
state.var {
  RootAddr = state.value(),
  publishers = state.map(),
  users = state.map()
}


-- Initialize
function constructor(rootAddr)
  if (rootAddr == nil or rootAddr == '') then
    rootAddr = system.getSender()
  end
  RootAddr:set(rootAddr)
  getPublisherStorageInstance():add(Entry.new({
    addr = rootAddr,
    publisher = rootAddr
  }))
end


-- get addr of root
-- @query
function getRootAddr()
  return RootAddr:get()
end


-- get storage instance of publishers
function getPublisherStorageInstance()
  return Storage.new({
    stateMap = publishers,
    name = 'publishers',
    keepTrack = true
  })
end


-- get storage instance of users
function getUserStorageInstance()
  return Storage.new({
    stateMap = users,
    name = 'users'
  })
end


function validateSign(data, signature, address)
  msg = crypto.sha256(data)
  return crypto.ecverify(msg, signature, address)
end


-- add entry to publishers
-- @call
-- @param pubsEntryJson          string: new publisher entry to enroll
-- @param signature              string: hex encoded signature
function addPublisher(pubsEntryJson, signature)
  local sender = system.getSender()
  assert(sender == RootAddr:get(), "Invalid Sender")
  local pubsEntry = Entry.decode(pubsEntryJson)
  pubsEntry:setPublisher(sender)
  --assert(pubsEntry.publisher == RootAddr:get(), "Invalid Publisher")
  --assert(validateSign(pubsEntryJson, signature, pubsEntry.publisher), "Invalid Signature")
  assert(isPublisher(pubsEntry.addr) ~= true, "Invalid Entry: Already Added")
  getPublisherStorageInstance():add(pubsEntry)
end

-- remove entry from publishers
-- @call
-- @param pubsEntryAddr          string: publisher address to exclude
function removePublisher(pubsEntryAddr)
  assert(notEmpty(pubsEntryAddr), "Invalid argument: nil or empty")
  local sender = system.getSender()
  assert(sender == RootAddr:get(), "Invalid Sender")
  getPublisherStorageInstance():remove(pubsEntryAddr)
end

-- authenticate entry address as publisher
-- @query
-- @param pubsEntryAddr          string: publisher address to check
function isPublisher(pubsEntryAddr)
  assert(notEmpty(pubsEntryAddr), "Invalid argument: nil or empty")
  return getPublisherStorageInstance():has(pubsEntryAddr)
end

-- fetch publisher
-- @query
-- @param pubsEntryAddr          string: publisher address to get
function getPublisher(pubsEntryAddr)
  assert(notEmpty(pubsEntryAddr), "Invalid argument: nil or empty")
  return getPublisherStorageInstance():fetch(pubsEntryAddr)
end

-- fetch address list of publishers
-- @query
function getPublishers()
  return getPublisherStorageInstance():keys()
end



-- add entry to users
-- @call
-- @param userEntryJson          string: new user entry to enroll
-- @param signature              string: hex encoded signature
function recordRegistration(userEntryJson, signature)
  local sender = system.getSender()
  assert(isPublisher(sender), "Invalid Sender")
  local userEntry = Entry.decode(userEntryJson)
  userEntry:setPublisher(sender)
  --assert(isPublisher(userEntry.publisher), "Invalid Publisher")
  --assert(validateSign(userEntryJson, signature, userEntry.publisher), "Invalid Signature")
  return getUserStorageInstance():add(userEntry)
end

-- revoke entry from users
-- @call
-- @param userEntryAddr          string: user address to exclude
function revokeRegistration(userEntryAddr)
  assert(notEmpty(userEntryAddr), "Invalid argument: nil or empty")
  local sender = system.getSender()
  assert(isPublisher(sender), "Invalid Sender")
  return getUserStorageInstance():revoke(userEntryAddr)
end

-- authenticate user by entry address
-- @query
-- @param userEntryAddr          string: user address to check
function checkRegistration(userEntryAddr)
  assert(notEmpty(userEntryAddr), "Invalid argument: nil or empty")
  return getUserStorageInstance():has(userEntryAddr)
end

-- fetch user of entry address
-- @query
-- @param userEntryAddr          string: user address to get
function fetchRegistration(userEntryAddr)
  assert(notEmpty(userEntryAddr), "Invalid argument: nil or empty")
  return getUserStorageInstance():fetch(userEntryAddr)
end


-- register functions to expose
abi.register(getRootAddr)
abi.register(addPublisher, removePublisher, isPublisher, getPublisher, getPublishers)
abi.register(recordRegistration, revokeRegistration, checkRegistration, fetchRegistration)
