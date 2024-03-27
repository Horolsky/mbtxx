local mymodule = require("mymodule")

local exe, script = ...

mymodule.hello_lua()

print("Script args: " .. exe .. ", " .. script)
