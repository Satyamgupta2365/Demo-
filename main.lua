-- Decentralized Supply Chain Verification System
-- A system to track products through their lifecycle with immutable records

-- Initialize state
Data = Data or {}
Data.products = Data.products or {}  -- Products by ID
Data.batches = Data.batches or {}    -- Manufacturing batches
Data.events = Data.events or {}      -- Events by product ID
Data.users = Data.users or {}        -- Authorized users
Data.lastProductId = Data.lastProductId or 0  -- Auto-increment product ID

-- Role management system
local ROLES = {
  ADMIN = "admin",          -- Can add/remove users and assign roles
  MANUFACTURER = "manufacturer", -- Can register products and batches
  SHIPPER = "shipper",      -- Can add shipping events
  DISTRIBUTOR = "distributor", -- Can add distribution events
  RETAILER = "retailer",    -- Can add retail events
  CONSUMER = "consumer"     -- Can view product history and verify authenticity
}

-- Events in a product lifecycle
local EVENT_TYPES = {
  MANUFACTURED = "manufactured",
  QUALITY_CHECK = "quality_check",
  PACKAGED = "packaged",
  SHIPPED = "shipped",
  RECEIVED_WAREHOUSE = "received_warehouse",
  DISTRIBUTED = "distributed",
  RECEIVED_RETAIL = "received_retail",
  SOLD = "sold"
}

-- Initial setup - create admin user (only runs if no admin exists)
Handlers.add("Initialize", function(msg)
  -- Check if we already have an admin
  local hasAdmin = false
  for _, user in pairs(Data.users) do
    if user.role == ROLES.ADMIN then
      hasAdmin = true
      break
    end
  end
  
  if not hasAdmin then
    -- Create the first admin user (sender becomes admin)
    local adminAddress = msg.From
    Data.users[adminAddress] = {
      address = adminAddress,
      role = ROLES.ADMIN,
      name = "System Admin",
      createdAt = os.time()
    }
    
    return json.encode({
      success = true,
      message = "System initialized with admin: " .. adminAddress
    })
  else
    return json.encode({
      success = false,
      message = "System already initialized"
    })
  end
end)

-- Helper function to check if user has required role
local function checkRole(address, requiredRole)
  if not Data.users[address] then
    return false, "User not registered"
  end
  
  if Data.users[address].role ~= requiredRole and Data.users[address].role ~= ROLES.ADMIN then
    return false, "Insufficient permissions"
  end
  
  return true, nil
end

-- User management
Handlers.add("RegisterUser", function(msg)
  local adminAddress = msg.From
  local userAddress = msg.UserAddress
  local userName = msg.UserName
  local role = msg.Role
  
  -- Verify the sender is an admin
  local hasPermission, errMsg = checkRole(adminAddress, ROLES.ADMIN)
  if not hasPermission then
    return json.encode({
      success = false,
      message = errMsg
    })
  end
  
  -- Validate role
  local validRole = false
  for _, v in pairs(ROLES) do
    if role == v then
      validRole = true
      break
    end
  end
  
  if not validRole then
    return json.encode({
      success = false,
      message = "Invalid role"
    })
  end
  
  -- Register the user
  Data.users[userAddress] = {
    address = userAddress,
    name = userName,
    role = role,
    createdAt = os.time(),
    createdBy = adminAddress
  }
  
  return json.encode({
    success = true,
    message = "User registered successfully",
    user = Data.users[userAddress]
  })
end)

-- Product registration
Handlers.add("RegisterProduct", function(msg)
  local manufacturerAddress = msg.From
  local productName = msg.ProductName
  local description = msg.Description
  local batchId = msg.BatchId
  local manufacturingDate = msg.ManufacturingDate or os.time()
  local metadata = msg.Metadata or {}
  
  -- Verify the sender is a manufacturer
  local hasPermission, errMsg = checkRole(manufacturerAddress, ROLES.MANUFACTURER)
  if not hasPermission then
    return json.encode({
      success = false,
      message = errMsg
    })
  end
  
  -- Auto-increment product ID
  Data.lastProductId = Data.lastProductId + 1
  local productId = tostring(Data.lastProductId)
  
  -- Create batch if it doesn't exist
  if not Data.batches[batchId] then
    Data.batches[batchId] = {
      id = batchId,
      manufacturer = manufacturerAddress,
      createdAt = os.time(),
      products = {}
    }
  end
  
  -- Register the product
  local product = {
    id = productId,
    name = productName,
    description = description,
    batchId = batchId,
    manufacturerAddress = manufacturerAddress,
    manufacturingDate = manufacturingDate,
    metadata = metadata,
    registeredAt = os.time()
  }
  
  Data.products[productId] = product
  
  -- Add to batch
  table.insert(Data.batches[batchId].products, productId)
  
  -- Create first product event (manufacturing)
  Data.events[productId] = Data.events[productId] or {}
  table.insert(Data.events[productId], {
    type = EVENT_TYPES.MANUFACTURED,
    timestamp = manufacturingDate,
    location = metadata.location or "Manufacturing facility",
    actor = manufacturerAddress,
    details = {
      batchId = batchId
    }
  })
  
  -- Announce the new product registration
  Handlers.announce({
    Action = "ProductRegistered",
    Product = product
  })
  
  return json.encode({
    success = true,
    message = "Product registered successfully",
    productId = productId,
    product = product
  })
end)

-- Record a product event
Handlers.add("RecordEvent", function(msg)
  local actorAddress = msg.From
  local productId = msg.ProductId
  local eventType = msg.EventType
  local location = msg.Location
  local timestamp = msg.Timestamp or os.time()
  local details = msg.Details or {}
  
  -- Check if product exists
  if not Data.products[productId] then
    return json.encode({
      success = false,
      message = "Product not found"
    })
  end
  
  -- Validate event type
  local validEvent = false
  for _, v in pairs(EVENT_TYPES) do
    if eventType == v then
      validEvent = true
      break
    end
  end
  
  if not validEvent then
    return json.encode({
      success = false,
      message = "Invalid event type"
    })
  end
  
  -- Check role permissions for different event types
  local requiredRole = nil
  
  if eventType == EVENT_TYPES.MANUFACTURED or 
     eventType == EVENT_TYPES.QUALITY_CHECK or 
     eventType == EVENT_TYPES.PACKAGED then
    requiredRole = ROLES.MANUFACTURER
  elseif eventType == EVENT_TYPES.SHIPPED or 
         eventType == EVENT_TYPES.RECEIVED_WAREHOUSE then
    requiredRole = ROLES.SHIPPER
  elseif eventType == EVENT_TYPES.DISTRIBUTED then
    requiredRole = ROLES.DISTRIBUTOR
  elseif eventType == EVENT_TYPES.RECEIVED_RETAIL or 
         eventType == EVENT_TYPES.SOLD then
    requiredRole = ROLES.RETAILER
  end
  
  if requiredRole then
    local hasPermission, errMsg = checkRole(actorAddress, requiredRole)
    if not hasPermission then
      return json.encode({
        success = false,
        message = errMsg
      })
    end
  end
  
  -- Initialize events array if needed
  Data.events[productId] = Data.events[productId] or {}
  
  -- Add the event
  local event = {
    type = eventType,
    timestamp = timestamp,
    location = location,
    actor = actorAddress,
    details = details
  }
  
  table.insert(Data.events[productId], event)
  
  -- Announce the event
  Handlers.announce({
    Action = "ProductEvent",
    ProductId = productId,
    Event = event
  })
  
  return json.encode({
    success = true,
    message = "Event recorded successfully",
    event = event
  })
end)

-- Get product details with its event history
Handlers.add("GetProductHistory", function(msg)
  local productId = msg.ProductId
  
  -- Check if product exists
  if not Data.products[productId] then
    return json.encode({
      success = false,
      message = "Product not found"
    })
  end
  
  local product = Data.products[productId]
  local events = Data.events[productId] or {}
  
  -- Sort events by timestamp
  table.sort(events, function(a, b)
    return a.timestamp < b.timestamp
  end)
  
  -- Get manufacturer info
  local manufacturer = Data.users[product.manufacturerAddress] or {
    name = "Unknown Manufacturer",
    address = product.manufacturerAddress
  }
  
  return json.encode({
    success = true,
    product = product,
    manufacturer = {
      name = manufacturer.name,
      address = manufacturer.address
    },
    events = events
  })
end)

-- Get products in a batch
Handlers.add("GetBatchProducts", function(msg)
  local batchId = msg.BatchId
  
  -- Check if batch exists
  if not Data.batches[batchId] then
    return json.encode({
      success = false,
      message = "Batch not found"
    })
  end
  
  local batch = Data.batches[batchId]
  local products = {}
  
  -- Gather product details
  for _, productId in ipairs(batch.products) do
    if Data.products[productId] then
      table.insert(products, Data.products[productId])
    end
  end
  
  return json.encode({
    success = true,
    batch = batch,
    products = products
  })
end)

-- Search products by criteria
Handlers.add("SearchProducts", function(msg)
  local criteria = msg.Criteria or {}
  local results = {}
  
  for id, product in pairs(Data.products) do
    local matches = true
    
    -- Match by name
    if criteria.name and not string.find(string.lower(product.name), string.lower(criteria.name)) then
      matches = false
    end
    
    -- Match by batch
    if criteria.batchId and product.batchId ~= criteria.batchId then
      matches = false
    end
    
    -- Match by manufacturer
    if criteria.manufacturerAddress and product.manufacturerAddress ~= criteria.manufacturerAddress then
      matches = false
    end
    
    -- Match by date range
    if criteria.dateFrom and product.manufacturingDate < criteria.dateFrom then
      matches = false
    end
    
    if criteria.dateTo and product.manufacturingDate > criteria.dateTo then
      matches = false
    end
    
    if matches then
      table.insert(results, product)
    end
  end
  
  -- Sort results by registration date (newest first)
  table.sort(results, function(a, b)
    return a.registeredAt > b.registeredAt
  end)
  
  -- Apply limit if specified
  local limit = criteria.limit or 100
  if #results > limit then
    local trimmedResults = {}
    for i = 1, limit do
      table.insert(trimmedResults, results[i])
    end
    results = trimmedResults
  end
  
  return json.encode({
    success = true,
    count = #results,
    products = results
  })
end)

-- Get user profile and role
Handlers.add("GetUserInfo", function(msg)
  local address = msg.Address or msg.From
  
  if not Data.users[address] then
    return json.encode({
      success = false,
      message = "User not found"
    })
  end
  
  return json.encode({
    success = true,
    user = Data.users[address]
  })
end)

-- Get system statistics
Handlers.add("GetStats", function()
  local productCount = 0
  local batchCount = 0
  local eventCount = 0
  local userCount = 0
  
  for _ in pairs(Data.products) do
    productCount = productCount + 1
  end
  
  for _ in pairs(Data.batches) do
    batchCount = batchCount + 1
  end
  
  for _, events in pairs(Data.events) do
    eventCount = eventCount + #events
  end
  
  for _ in pairs(Data.users) do
    userCount = userCount + 1
  end
  
  return json.encode({
    success = true,
    stats = {
      products = productCount,
      batches = batchCount,
      events = eventCount,
      users = userCount
    }
  })
end)

-- Handle unknown actions
Handlers.add("default", function(msg)
  return json.encode({
    success = false,
    message = "Unknown action: " .. (msg.Action or "no action specified"),
    availableActions = {
      "Initialize", "RegisterUser", "RegisterProduct", "RecordEvent", 
      "GetProductHistory", "GetBatchProducts", "SearchProducts", 
      "GetUserInfo", "GetStats"
    }
  })
end)