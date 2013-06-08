crypto    = require 'crypto'

global.sha256 = (pwd) -> crypto.createHash('sha256').update(pwd).digest('hex')

global.log = (msg) -> 
  console.log(msg)
  # may write to db

global.info = (msg) -> 
  console.log(msg)
  
global.warn  = (msg) -> 
  console.log(msg)
  
global.debug = (func_or_msg) -> 
  if (typeof func_or_msg) == 'function' 
    open  = '============================ debug ============================'
    close = '==============================================================='
    console.log(open)
    func_or_msg( () -> console.log(close) )
  else
    console.log(func_or_msg)