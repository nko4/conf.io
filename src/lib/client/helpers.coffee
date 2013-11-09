###
conf.io
author: gordon hall

helpers.coffee - helpers classes
###

class UUID
  spec: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  pattern: /[xy]/g
  constructor: ->
    @value = @spec.replace @pattern, (c) ->
      r = (do Math.random) * (16 | 0)
      v = if c is 'x' then r else (r & 0x3 | 0x8)
      v.toString 16
  toString: -> @value

module.exports =
  UUID: UUID
