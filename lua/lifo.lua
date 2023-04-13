-- stack data structuresta
Lifo = Tool.class()
function Lifo:ctor(array)
        self.count = 0
        self.head = nil
        self.tail = nil
    if array then
        Tool.table_transform(array, function(item) self:push(item) end)
    end
end
function Lifo:toArray()
    local array = {}
    local index = self.head
    while index do
        table.insert(array, index.value)
        index = index.next
    end
    return array
end
function Lifo:push(value)
    local orig_head = self.head    
    self.head = {
        value = value,
        next = orig_head
    }

    if nil == orig_head then
        self.tail = self.head
        assert(0 == self.count)
    end

    self.count = self.count + 1
end
function Lifo:exist(value)
    local curnode = self.head
    local flag = false
    while curnode do
        if curnode.value == value then
            flag = true
            break
        end
        curnode = curnode.next 
    end
    return flag
end
function Lifo:pop()
    if nil == self.head then
        assert(0 == self.count)
        return nil
    end

    local orig_head = self.head 
    self.count = self.count - 1

    self.head = orig_head.next
    if nil == self.head then
        self.tail = nil
        assert(0 == self.count)
    end

    return orig_head.value
end
function Lifo:len()
    return self.count
end
function Lifo:dump()
    local curnode = self.head 
    local count = 0
    while curnode do
        count = count + 1
        Tool.debug(count, curnode.value)
        curnode = curnode.head
    end
end
function Lifo:join(lifo)
    local postfix = Tool.table_copy(self)
    if lifo.tail then
        lifo.tail.next = postfix.head
    end
    if nil == lifo.head then
        lifo.head = postfix.head
    end
    lifo.tail = self.tail
    self.count = self.count + postfix.count
    return lifo
end

-- local fifo = Fifo:new({1,2,3})
-- local fifo2 = Fifo:new({5,6,7})
-- print(fifo:enqueue(35))
-- print(fifo:join(fifo2))

-- local lifo = Lifo:new({1,2,3})
-- local lifo2 = Lifo:new({5,6,7})
-- print(lifo:exist(5))
-- local a = lifo2:toArray()
-- print(lifo)
