###
conf.io
author: gordon hall

gravatar.coffee - gravatar helper
###

crypto = require "crypto"

module.exports = (email) -> 
	hash = crypto.createHash "md5"
	hash.update email, "utf8"
	hash = hash.digest "hex"
	"http://www.gravatar.com/avatar/#{hash}?s=38"
