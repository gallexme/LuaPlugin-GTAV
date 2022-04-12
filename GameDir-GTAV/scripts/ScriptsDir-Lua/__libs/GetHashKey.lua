local _GetHashKey = require('CreateCacheSimpleForFunction')(GetHashKey)
GetHashKey = _GetHashKey
return _GetHashKey