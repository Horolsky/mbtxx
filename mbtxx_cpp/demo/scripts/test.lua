local mymodule = require("mymodule")
mymodule.hello_lua()


local args = {...}
print("Script args: " .. table.concat(args, ", "))


local mbtxx = require("mbtxx")
mbtxx.hello()
