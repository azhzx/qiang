
-- A tour of the qpcc-built Lua:  build/lua/lua examples/lua/demo.lua
local function section(name) print("\n== " .. name .. " ==") end

section("numbers")
print(2^53, 10/4, 7//2, 7%3, 0x10, 1e3, string.format("%.4f", math.pi))
print("signed compare:", -1 >= 1, -1 < 1, -1 >= 1.0)

section("sibling scopes with the same local name")
local function pick(c)
  if c then local v = 5 return v else local v = 2.5 return v end
end
print(pick(true), pick(false))

section("loops")
local s = 0
for i = 1, 100 do s = s + i end
print("sum 1..100 =", s)
local f = {}
for i = 1.0, 3.0 do f[#f + 1] = i end
print("float for:", table.concat(f, ", "))
local n = 0
while n < 3 do n = n + 1 end
print("while ended at", n)

section("closures and recursion")
local function fib(k) if k < 2 then return k end return fib(k - 1) + fib(k - 2) end
print("fib(20) =", fib(20))
local function counter() local c = 0 return function() c = c + 1 return c end end
local c = counter()
print("closure:", c(), c(), c())

section("metatables")
local V = {} V.__index = V
V.__add = function(a, b) return setmetatable({ x = a.x + b.x }, V) end
V.__tostring = function(a) return "V(" .. a.x .. ")" end
print(tostring(setmetatable({ x = 3 }, V) + setmetatable({ x = 4 }, V)))

section("coroutines")
local co = coroutine.create(function(a)
  for _ = 1, 3 do a = a + coroutine.yield(a) end
  return a
end)
print(coroutine.resume(co, 1))
print(coroutine.resume(co, 10))
print(coroutine.resume(co, 100))

section("tables and strings")
local t = { 5, 3, 1, 4, 2 } table.sort(t)
print(table.concat(t, " "), ("hello"):upper(), #"abc", string.gsub("a-b-c", "-", "+"))

section("file io")
-- A relative name, not os.tmpname(): the sandbox may deny /var/tmp.
local fn = "qpcc_demo_tmp.txt"
local h = assert(io.open(fn, "w")) h:write("written by the qpcc-built Lua\n") h:close()
local r = assert(io.open(fn, "r")) print(r:read("l")) r:close() os.remove(fn)
