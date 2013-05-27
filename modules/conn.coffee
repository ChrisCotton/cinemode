mysql = require 'mysql'

conn = mysql.createConnection(
  { host: 'localhost'
  , user: 'admin'
  , database: 'cinemode'
  , password: '123123123'})
conn.connect()

# callback :: Err -> Unknown -> IO ()
conn.insert = (db, map, callback) ->
  keys = Object.keys map
  vals = keys.map (x) -> conn.escape map[x]
  q = "insert into #{db}(#{keys.join(',')}) values (#{vals.join(',')});"
  # debug q
  conn.query q, callback
    
conn.cond = (db, map, callback) ->
  keys = Object.keys map
  if keys.length == 0
    q = "select * from #{db};"
  else
    cond = keys.map( (x) -> "#{x} = #{conn.escape map[x]}" ).join(' and ')
    q = "select * from #{db} where #{cond};"
  # debug q
  conn.query q, callback
  
conn.cond1 = (db, map, callback) ->
  keys = Object.keys map
  if keys.length == 0
    q = "select * from #{db} limit 1;"
  else
    cond = keys.map( (x) -> "#{x} = #{conn.escape map[x]}" ).join(' and ')
    q = "select * from #{db} where #{cond} limit 1;"
  # debug q
  conn.query q, (err, rows, fields) ->
    callback(err, undefined, fields) if err
    if rows == 0 then callback(null, null, fields) else callback(null, rows[0], fields)
  
# callback :: Err -> Bool -> IO () 
conn.exist = (db, map, callback) ->
  return if callback == undefined
  conn.cond1 db, map, (err,res) -> 
    return callback err, undefined if err
    if res then callback(null, true) else callback(null, false)
    
conn.update = (db, val, sel, callback) ->
  stat = Object.keys(val).map( (k) -> "#{k}=#{conn.escape val[k]}").join(',')
  cond = Object.keys(sel).map( (k) -> "#{k}=#{conn.escape sel[k]}").join(' and ')
  q = "update #{db} set #{stat} where #{cond};"
  conn.query q, callback
  
  
conn.delete = (db, sel, callback) ->
  keys = Object.keys sel
  if keys.length == 0
    q = "delete from #{db};"
  else
    cond = keys.map((k) -> "#{k}=#{conn.escape sel[k]}").join(' and ')
    q = "delete from #{db} where #{cond};"
  conn.query q, callback
  
# debug (end) -> 
#   conn.insert 'users', { email: 'hero@example.com', is_admin: true }, () -> 
#     conn.insert 'users', { email: 'jack@example.com', is_admin: false }, () -> 
#       conn.exist 'users', { email: 'hero@example.com', is_admin: true }, () -> 
#         conn.exist 'users', { email: 'hero@example.com', is_admin: false }, () -> 
#           conn.cond 'users', { id: 1 }, (err, rows) -> 
#             info rows
#             conn.cond 'users', { email: 'jack@example.com' }, (err, rows) -> 
#               info rows
#               end()

global.conn = conn