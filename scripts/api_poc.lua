---@class TestModel
---
---@operator call(...):TestModel
---@field private new fun(self: TestModel, arg: string | table): TestModel
---
---@field private name string | nil
---@field private actuator string | nil
---@field private channels string[]
---@field private preconditions string[]
---@field private test_vectors string[]
---@field private head fun(self: TestModel): table
---
---@field On fun(self: TestModel, trigger: string): TestModel
---@field At fun(self: TestModel, interface: string): TestModel
---@field Set fun(self: TestModel, ptr: string | nil): TestModel
---@field Check fun(self: TestModel, ptr: string | nil): TestModel
---@field As fun(self: TestModel, decor: string): TestModel
---@field OnCall fun(self: TestModel, n: string): TestModel
---@field WithPreconditions fun(self: TestModel, ...): TestModel
---
---@field Test fun(self: TestModel, ...): TestRunner
---
---@field Zip fun(self: TestModel, ...): TestModel



---@class TestRunner
---@operator call:TestRunner
---@field private new fun(self: TestRunner, model: TestModel): TestRunner
---@field private model TestModel
---
---@field Test fun(self: TestRunner, ...): TestRunner
---@field Report fun(self: TestRunner, verbose: boolean | nil): TestRunner
---@field ReportVerbose fun(self: TestRunner): TestRunner
---@field End fun(self: TestRunner, verbose: boolean | nil): TestModel


TestModel = {}
TestRunner = {}


-- -@type fun(self: TestModel, arg: table): TestModel
---@overload fun(...): TestModel
TestModel = setmetatable(TestModel, {
    __call = function(...)
        return TestModel.new(...)
    end
})






Parameter = {}

Defaults = {
    set_ptr = 'args/1',
    check_ptr = 'return/',
    call = nil,
    report_channel_fmt = ':At  %-15s :%-10s %-15s %s :As %-10s'
}

Channel = {
    set = 'Set',
    check = 'Check',
}


---@type fun(s: string): string
local function quote(s)
    return "'" .. s .. "'"
end

---@type fun(s: string): string
local function parenthize(s)
    return "(" .. s .. ")"
end


function TestModel:new(arg)
    if type(arg) == 'string' then
        arg = {name = arg}
    end
    assert(type(arg) == 'table')
    local obj = {
        name = arg.name,
        actuator = arg.actuator,
        channels = arg.channels or {},
        preconditions = arg.preconditions or {},
        test_vectors = arg.test_vectors or {},
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function TestRunner:new(model)
    local obj = {
        -- TODO: deep copy ?
        model = model,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function TestModel:head()
    return self.channels[#self.channels]
end

function TestModel:On(actuator)
    self.actuator = actuator
    return self
end

function TestModel:At(interface)
    table.insert(self.channels, {
        interface = interface,
        decor = 'table',
        dir = nil,
        ptr = '/',
        call = Defaults.call,
    })
    return self
end

function TestModel:Set(ptr)
    ptr = ptr or Defaults.set_ptr
    local head = self:head()
    head.dir = Channel.set
    head.ptr = ptr
    return self
end

function TestModel:Check(ptr)
    ptr = ptr or Defaults.check_ptr
    local head = self:head()
    head.dir = Channel.check
    head.ptr = ptr
    return self
end

function TestModel:As(decor)
    self:head().decor = decor
    return self
end

function TestModel:OnCall(n)
    self:head().call = n
    return self
end

function TestModel:WithPreconditions(...)
    local preconditions = {...}
    for _, precondition in ipairs(preconditions) do
        assert(type(precondition[1]) == 'string')
        assert(type(precondition[2]) == 'function')
    end
    self.preconditions = preconditions
    return self
end

function TestRunner:Test(...)
    table.insert(self.model.test_vectors, {...})
    return self
end

function TestModel:Test(...)
    return TestRunner:new(self):Test(...)
end

function TestModel:Zip(...)
    return TestRunner:new(self)(...)
end



function TestRunner:__call(...)
    return self:Test(...)
end


function TestRunner:Report(verbose)
    if verbose then
        return self:ReportVerbose()
    end

    print('TestModel: ' .. self.model.name)
    print(':On  ' .. self.model.actuator)
    for _, cnl in ipairs(self.model.channels) do
        local s = string.format(
            Defaults.report_channel_fmt,
            quote(cnl.interface),
            cnl.dir,
            quote(cnl.ptr),
            cnl.call and (':OnCall' .. cnl.call) or '',
            parenthize(cnl.decor)
        )
        print(s)
    end

    print(':WithPreconditions')
    for _, precondition in ipairs(self.model.preconditions) do
        print('  ' .. tostring(precondition[1]))
    end

    print(':Test')

    for i, test_vector in ipairs(self.model.test_vectors) do
        local s = '   ('
        for j, arg in ipairs(test_vector) do
            s = s .. tostring(arg)
            if j < #test_vector then
                s = s .. ', '
            end
        end
        s = s .. ')'
        print(s)
    end
    print(':End()')
    return self
end

function TestRunner:ReportVerbose()
    print('TestModel: ' .. self.model.name)
    print(':On  ' .. self.model.actuator)

    local fcnls = {}
    for _, cnl in ipairs(self.model.channels) do
        local s = string.format(
            Defaults.report_channel_fmt .. ' %%10s',
            quote(cnl.interface),
            cnl.dir,
            quote(cnl.ptr),
            cnl.call and (':OnCall ' .. cnl.call) or '',
            parenthize(cnl.decor)
        )
        table.insert(fcnls, s)
    end

    for testn, test_vector in ipairs(self.model.test_vectors) do
        print('\n:Begin Test # ' .. testn)
        print(':InitPreconditions')
        for _, precondition in ipairs(self.model.preconditions) do
            print('  - ' .. tostring(precondition[1]))
        end

        print(':Do')
        for i, cnl in ipairs(self.model.channels) do
            if cnl.dir == Channel.set then
                local s = '  ' .. fcnls[i]:format(test_vector[i])
                print(s)
            end
        end
        print('  :Actuate   ' .. quote(self.model.actuator))
        for i, cnl in ipairs(self.model.channels) do
            if cnl.dir == Channel.check then
                local s = '  ' .. fcnls[i]:format(test_vector[i])
                print(s)
            end
        end
        print(':End Test # ' .. testn)
    end
    return self
end

function TestRunner:End(verbose)
    self:Report(verbose)
    return self.model
end


TestModel "Dense demo"

:On "MySut"
:At "ifc1"  :Set()   :As "int"
:At "ifc2"  :Check() :As "double"

:WithPreconditions(
    {'Do something'     , function () end},
    {'Do something else', function () end}
)

:Test
    (1, 2.0)
    (2, 3.0)
    (3, 4.0)
    (4, 5.0)
    (5, 6.0)
    (6, 7.0)
    (7, 8.0)
    (8, 9.0)
    (9, 10.0)
    (10, 11.0)
:End(true)

