local function hello(name)
  return print(("Hello, " .. (name or "world") .. "!"))
end
local function something_else()
  return print(("hello world")())
end
return {hello = hello}
