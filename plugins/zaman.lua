local address = 'http://powerful.friends-memorial.ir/api/'
local function run(msg)
local resolve = http.request(address..'index.php')
return resolve
end
return {
   patterns = {"^ساعت$"},
   run = run
} 
