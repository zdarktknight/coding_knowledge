
-- ========================================================
-- https://blog.csdn.net/cooclc/article/details/112548031
local parent = {}
parent["a"] = 1
-- -- 如果parent的__index元方法没有赋值为本身，那么child在找metatable时候也不会找到
-- parent.__index = parent

-- -- 元表的__index字段不一定为自身的表，也可以指向其他表效果一样。
-- local parent2 = {}
-- parent2["a"] = 2
-- parent.__index = parent2


-- __index 可以是一个函数 在表中找不到值的时候调用元表中的__index函数
parent.__index = function() print("metatable __index function value") return "hello" end

local child = {}
setmetatable(child, parent)
print(child.a)

-- ========================================================
-- https://blog.csdn.net/cooclc/article/details/112566933

-- __index 访问表中不存在的值（get）时执行的操作
-- __nexindex 对表中不存在的值进行赋值（set）时候执行的操作
-- 如果没有元表，或者元表中没有__newindex字段，那给表新建一个字段则不会执行其他多余的操作
-- 如果__newindex字段指向一个函数，则给表创建一个新字段的时候，则会执行该函数，且对本表创建不成功

-- ========================================================

-- https://zhuanlan.zhihu.com/p/38127723
local smartMan = { 
	name = "none", 
        money = 9000000, 
	sayHello = function() print("大家"); end } 

-- local t1 = {
-- 	sayHello = function() print("大家two"); end}; 
local t1 = {}

local mt = { 
	__index = smartMan,
        -- 如果__newindex是一个函数,则在给table不存在的字段赋值时,会调用这个函数。
	__newindex = function(table, key, value) print(key .. "字段是不存在的不要试图给它赋值"); end } 
setmetatable(t1, mt); 

t1.sayHello = function() print("en"); end; -- 赋值 + 调用函数
t1.sayHello(); 
---------------------------------------------------
local smartMan={name="none"}
local other = {name = "大家好,我是很无辜的table"} 
local t1={}
local mt = { 
		__index = smartMan, 
                -- 如果__newindex是一个table,则在给table不存在的字段赋值时,会直接给__newindex的table赋值。
		__newindex = other
} 
setmetatable(t1, mt); 
print("other的名字,赋值前:" .. other.name); 
t1.name = "小偷"; 
print("other的名字,赋值后:" .. other.name); 
print("t1的名字:" .. t1.name);

--[[
--https://blog.csdn.net/xocoder/article/details/9028347
--__index 定义了在索引表的时候，如果失败应该如何操作(__index定义了一个查找错误时的解决方案--操作指南)
-->> A 的metatable是 B，即使A查找了一个不存在的元素c，c在B中存在，那么也不会返回c -- 因为B的__index方法没有进行定义
--实例的继承
--setmetatable(table1, {__index=function(table1_,key) return xxxx end})
--1. 给table1设置一个metatable
--2. 在表中查找元素，如果存在，则返回
--3. 判断是否有metatable，如果没有，返回nil
--4. metatable存在，判断metatable的__index方法，如果__index是table -- 重复1，2，3进行查找；如果__index是function -- 返回函数的返回值
-->> 从上述的表述中可以看到,function 传入的参数有2个，第一个是table1，第二个是key, 这个key是调用的时候，传入的key（A.xxx, A:yyy, key=xxx, key=yyy）
-->> 这部分的内容可以在项目中看到
--]]

