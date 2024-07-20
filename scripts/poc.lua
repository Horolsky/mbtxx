---@class AnnotatedAction
---
---@field description string
---@field action fun():nil


---@alias Precondition AnnotatedAction


----------------
-- Parameters --
----------------


---@enum ParametrizationType
local ParametrizationType = {
	Zip = 'Zip',
	Prod = 'Prod'
}

---@class ParameterPlaceholder
---
---@field package description string
---@field package class       string
---@field package new fun(self: ParameterPlaceholder, description: string): ParameterPlaceholder

---@alias StringParameterToken string | ParameterPlaceholder

---@class SignalParameter
---
---@field package tokens StringParameterToken[]
---@field package class string
---@field package arity integer
---@field package new fun(self: SignalParameter, tokens: StringParameterToken[]): SignalParameter
---@field package clone fun(self: SignalParameter): SignalParameter
---@field package to_string fun(self: SignalParameter): string

---@alias TypeDecorator        string
---@alias InterfaceParameter   string  | ParameterPlaceholder
---@alias CallParameter        integer | ParameterPlaceholder

---@alias ParameterVector      any[]


---@alias ParameterMap table<string, { pointer: string, parameters: any[]}>


---@enum ChannelRole
local ChannelRole = {
	Set = 'Set',
	Check = 'Check'
}

---@class Channel
---
---@field package role      ChannelRole
---@field package decor     TypeDecorator
---@field package ifc       InterfaceParameter
---@field package ptr       SignalParameter
---@field package call      CallParameter
---@field package class       string
---@field package new fun(self: Channel, t: table): Channel



----------------
-- Model Data --
----------------

---@class ModelPrototype
---
---@field package new fun(self: ModelPrototype, arg: string | table): ModelPrototype
---
---@field package name            string
---@field package actuator        InterfaceParameter
---@field package channels        Channel[]
---@field package preconditions   Precondition[]
---@field package parameter_map   ParameterMap
---@field package parametrization ParametrizationType
---
---@field package head  fun(self: ModelPrototype): Channel
---@field package clone fun(self: ModelPrototype): ModelPrototype


---------------------
-- Model Operators --
---------------------

---@class ModelOperator
---
---@field package prototype ModelPrototype
---@field package new fun(self: ModelOperator, prototype: ModelPrototype): ModelOperator
---
---@field Test fun(self: ModelOperator, ...): ModelRunner
---@field Zip  fun(self: ModelOperator     ): ModelParametrizer
---@field Prod fun(self: ModelOperator     ): ModelParametrizer


---@class ModelDefinition : ModelOperator
---
---@field On                fun(self: ModelDefinition, actuator: string  ): ModelPrototype
---@field At                fun(self: ModelDefinition, interface: string ): ModelPrototype
---@field Set               fun(self: ModelDefinition, ptr: string | nil ): ModelPrototype
---@field Check             fun(self: ModelDefinition, ptr: string | nil ): ModelPrototype
---@field As                fun(self: ModelDefinition, decor: string     ): ModelPrototype
---@field OnCall            fun(self: ModelDefinition, n: string         ): ModelPrototype
---@field WithPreconditions fun(self: ModelDefinition, ...               ): ModelPrototype


---@class ModelRunner : ModelOperator
---
---@field package test_vectors  any[]
---@field package report_verbose fun(self: ModelRunner): nil
---@field package report_dense   fun(self: ModelRunner): nil
---
---@operator call(...):ModelRunner
---@field    Test fun(self: ModelRunner, ...): ModelRunner
---@field    End  fun(self: ModelRunner, verbose: boolean | nil): ModelDefinition


---@class ModelParametrizer : ModelOperator
---
---@operator call(...):ModelParametrizer



---------------
-- Utilities --
---------------

---@type fun(s: string): string
local function quote(s)
    return "'" .. s .. "'"
end

---@type fun(s: string): string
local function quote_if_string(s)
    return type(s) == 'string' and quote(s) or s
end


---@type fun(s: string): string
local function parenthize(s)
    return "(" .. s .. ")"
end

---@type fun(seq: any[] | nil): any[]
local function clone_sequence(seq)
    seq = seq or {}
    local newseq = {}
    for i, v in ipairs(seq) do
        newseq[i] = v.clone and v:clone() or v
    end
    return newseq
end

local function split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end



local function ptr_set(obj, ptr, val)

    local ptr_tokens = split(ptr, '/')
    N = #ptr_tokens
    local ref = obj
    local terminal_token = ptr_tokens[N]
    local numtoken = tonumber(terminal_token)
        if numtoken then
            terminal_token = numtoken
        end
    local idx = 1
    while idx < N do
        local token = ptr_tokens[idx]
        local numtoken = tonumber(token)
        if numtoken then
            token = numtoken
        end
        if type(ref[token]) ~= 'table' then
            ref[token] = {}
        end
        ref = ref[token]
        idx = idx + 1
    end
    ref[terminal_token] = val
    return ref
end

local function ptr_get(obj, ptr)

    local ptr_tokens = split(ptr, '/')
    N = #ptr_tokens
    local ref = obj
    local terminal_token = ptr_tokens[N]
    local numtoken = tonumber(terminal_token)
        if numtoken then
            terminal_token = numtoken
        end
    local idx = 1
    while idx < N do
        local token = ptr_tokens[idx]

        local numtoken = tonumber(token)
        if numtoken then
            token = numtoken
        end
        if nil == ref[token] then
            return nil
        end
        ref = ref[token]
        idx = idx + 1
    end
    return ref[terminal_token]
end

ParameterPlaceholder = {
    class = 'ParameterPlaceholder'
}

Channel = {
    class = 'Channel'
}

SignalParameter = {
    class = 'SignalParameter'
}

function SignalParameter:new(...)
    local tokens = {...}
    assert(#tokens > 0)
    local arity = 0
    local placeholders = {}
    for i, token in ipairs(tokens) do
        if token.class == ParameterPlaceholder.class then
            arity = arity + 1
            placeholders[token] = i
        end
    end
    local o = { tokens = tokens, placeholders = placeholders, arity = arity}
    setmetatable(o, self)
    self.__index = self
    return o
end

function SignalParameter:clone()
    return SignalParameter.new(self.tokens)
end

function SignalParameter:to_string()
    local s = ''
    for _, token in ipairs(self.tokens) do
        s = s .. tostring(token)
    end
    return s
end


function ParameterPlaceholder:new(description)
    assert(type(description) == 'string')
    local o = { description = description }
    setmetatable(o, self)
    self.__index = self
    return o
end


function Channel:new(t)
    t = t or {}
    local o = {
        role = t.role,
        decor = t.decor,
        ifc = t.ifc,
        ptr = t.ptr,
        call = t.call
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-------------------
-- Operator Impl --
-------------------


ModelOperator = {
    Zip = function(t, ...)
        return ModelParametrizer:new(t.prototype, ParametrizationType.Zip)(...)
    end,
    Prod = function(t, ...)
        return ModelParametrizer:new(t.prototype, ParametrizationType.Prod)(...)
    end,
    Test = function(t, ...)
        return ModelRunner:new(t.prototype, t.parametrization)(...)
    end
}

DEFAULT = {
    ptr = {
        [ChannelRole.Set] = SignalParameter:new('args/1'),
        [ChannelRole.Check] = SignalParameter:new('return/'),
    },
    call               = nil,
    report_channel_fmt = ':At  %-15s :%-10s %-20s %s :As %-10s'
}

ModelPrototype = {class='ModelPrototype'}
ModelDefinition = setmetatable({class='ModelDefinition'}, ModelOperator)
ModelRunner = setmetatable({class='ModelRunner'}, ModelOperator)
ModelParametrizer = setmetatable({class='ModelParametrizer'}, ModelOperator)
ModelOperator.__index = ModelOperator

--#region ModelPrototype


function ModelPrototype:new(arg)
    if type(arg) == 'string' then
        arg = {name = arg}
    end

    assert(type(arg) == 'table', 'ModelPrototype:new: arg must be a table, got '.. type(arg))

    local obj = {
        name            = arg.name,
        actuator        = arg.actuator,
        channels        = clone_sequence(arg.channels),
        preconditions   = clone_sequence(arg.preconditions),
        parameter_map   = arg.parameter_map or {},
        parametrization = arg.parametrization
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ModelPrototype:head()
    return self.channels[#self.channels]
end

function ModelPrototype:clone()
    return ModelPrototype:new(self)
end

--#endregion


--#region ModelParametrizer

function ModelParametrizer:new(prototype, parametrization)
    local obj = {
        prototype = prototype:clone(),
        parametrization = parametrization
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function ModelParametrizer:__call(placeholder, ...)
    --TODO: check arity
    assert(type(placeholder) == "table")
    assert(placeholder.class == ParameterPlaceholder.class)
    local record = self.prototype.parameter_map[placeholder.description]
    assert(record, 'unknown model parameter: ' .. placeholder.description)
    record.parameters = {...}
    return self
end
--#endregion


--#region ModelDefinition

function ModelDefinition:new(arg)
    if type(arg) == 'string' then
        arg = {name = arg}
    end
    assert(type(arg) == 'table')
    local obj = {
        prototype = ModelPrototype:new(arg)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function ModelDefinition:On(actuator)
    if actuator.class == ParameterPlaceholder.class then
        local pointer = '/actuator'
        self.prototype.parameter_map[actuator.description] = {pointer = pointer, parameters = {}}
    end
    self.prototype.actuator = actuator
    return self
end


function ModelDefinition:At(interface)
    if interface.class == ParameterPlaceholder.class then
        N = #self.prototype.channels + 1
        local pointer = '/channels/' .. N .. '/ifc'
        self.prototype.parameter_map[interface.description] = {pointer = pointer, parameters = {}}
    end
    table.insert(self.prototype.channels, {ifc = interface, call = -1, ptr = SignalParameter:new '/' })
    return self
end


function ModelDefinition:set_ptr(role, ...)
    local head = self.prototype:head()
    head.role = role

    local tokens = {...}
    N = #tokens
    local first = tokens[1]

    if first then
        head.ptr = SignalParameter:new(table.unpack(tokens))
    else
        head.ptr = DEFAULT.ptr[role]
    end

    local ptr_base = '/channels/' .. #self.prototype.channels .. '/ptr'

    for i, token in ipairs(tokens) do
        if token.class == ParameterPlaceholder.class then
            local pointer = ptr_base .. '/tokens/' .. i
            self.prototype.parameter_map[token.description] = {pointer = pointer, parameters = {}}
        end
    end
    return self
end

function ModelDefinition:Set(...)
    return self:set_ptr(ChannelRole.Set, ...)
end

function ModelDefinition:Check(...)
    return self:set_ptr(ChannelRole.Check, ...)
end


function ModelDefinition:As(decor)
    self.prototype:head().decor = decor
    return self
end

function ModelDefinition:OnCall(n)
    if n.class == ParameterPlaceholder.class then
        local pointer = '/channels/' .. #self.prototype.channels .. '/call'
        self.prototype.parameter_map[n.description] = {pointer = pointer, parameters = {}}
    end
    self.prototype:head().call = n
    return self
end

function ModelDefinition:WithPreconditions(...)
    local preconditions = {...}
    for _, precondition in ipairs(preconditions) do
        assert(type(precondition[1]) == 'string')
        assert(type(precondition[2]) == 'function')
    end
    self.prototype.preconditions = preconditions
    return self
end

--#endregion



--#region ModelRunner

function ModelRunner:new(prototype, parametrization)
    local obj = {
        prototype = prototype:clone(),
        test_vectors = {},
        parametrization = parametrization
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function ModelRunner:__call(...)
    return self:Test(...)
end

function ModelRunner:Test(...)
    table.insert(self.test_vectors, {...})
    return self
end

function ModelRunner:End(params)
    params = params or {}
    if params.verbose then
        self:report_verbose()
    else
        self:report_dense()
    end
    return ModelDefinition.new(self, self.prototype)
end


---Generator provifing models with resolved parameters
---@type fun(self: ModelRunner): ModelGenerator
function ModelRunner:model_generator()
    return self:zip_model_generator()
end

---@alias ModelGenerator fun(): ModelPrototype

---Generator provifing models with resolved parameters
---@type fun(self: ModelRunner): ModelGenerator
function ModelRunner:zip_model_generator()

    local factory = function ()
        local n = 1
        return function ()
            local model = self.prototype:clone()
            local continue, halt, err = 'continue', 'halt', 'error'
            local state = continue
            local param_cnt = 0
            for descr, record in pairs(model.parameter_map) do
                param_cnt = param_cnt + 1

                local pointer = record.pointer
                local parameters = record.parameters

                if (n > #parameters) and (param_cnt == 1) then
                    state = halt
                elseif (n > #parameters) and (state ~= halt) then
                    state = err
                    error('Model Zip arity mismatch, underflow at ' .. quote(descr))
                elseif (state == halt) and (n <= #parameters) then
                    state = err
                    error('Model Zip arity mismatch, overflow at ' .. quote(descr))
                end

                if state == continue then
                    local placeholder = ptr_get(model, pointer)
                    assert(placeholder, 'nil pointer at ' .. pointer .. ': ' .. tostring(model))
                    local value = parameters[n]
                    ptr_set(model, pointer, value)
                end
            end

            if state ~= continue then
                return nil, nil
            end
            n = n + 1
            return n-1, model
        end
    end
    return factory()
end


function ModelRunner:report_verbose()
    local report = {}
    report.Test = self.prototype.name

    for model_n, model in self:zip_model_generator() do

        local parametrization = self.parametrization and (self.parametrization .. ' ') or ''
        print('  :Begin '.. parametrization ..'Parameter Set #' .. model_n)
        print('  :On  ' .. model.actuator)

        local fcnls = {}
        for _, cnl in ipairs(model.channels) do
            local s = string.format(
                '    ' .. DEFAULT.report_channel_fmt .. ' %%10s',
                quote(cnl.ifc),
                cnl.role,
                cnl.ptr:to_string(),
                cnl.call ~= -1 and (':OnCall ' .. cnl.call) or '',
                parenthize(cnl.decor or 'default')
            )
            table.insert(fcnls, s)
        end

        for testn, test_vector in ipairs(self.test_vectors) do
            print('    :Begin Test Case #' .. testn)

            if #model.preconditions > 0 then
                print('    :InitPreconditions')
                for _, precondition in ipairs(model.preconditions) do
                    print('  - ' .. tostring(precondition[1]))
                end
            end

            print('    :Do')
            for i, cnl in ipairs(model.channels) do
                if cnl.role == ChannelRole.Set then
                    local s = '  ' .. fcnls[i]:format(quote_if_string(test_vector[i]))
                    print(s)
                end
            end

            print('      :Actuate   ' .. quote(model.actuator))

            for i, cnl in ipairs(model.channels) do
                if cnl.role == ChannelRole.Check then
                    local s = '  ' .. fcnls[i]:format(quote_if_string(test_vector[i]))
                    print(s)
                end
            end
            print('    :End Test #' .. testn .. '\n')
        end
        print('  :End '.. parametrization ..'Parameter Set #' .. model_n .. '\n')
    end
    return self
end


function ModelRunner:report_dense()
    print('ModelRunner:report_dense')
    --TODO
end

--#endregion


function Parameter(description)
    return ParameterPlaceholder:new(tostring(description))
end


local function TestModel(s)
    return ModelDefinition:new(s)
end



----------------------------
-- MBTXX API DEMO EXAMPLE --
----------------------------

ActuatorParam = Parameter(1)
IndexParam = Parameter(2)

TestModel 'My Demo'
:On (ActuatorParam)
:At 'Channel 1'   :Set    '/value'                             :As 'int'
:At 'Channel 2'   :Check  '/status'                            :As 'double'
:At 'Channel 3'   :Check  ('/array/', IndexParam, '/pointer')

:Zip
    (ActuatorParam, 'SUT 1', 'SUT 2', 'SUT 3')
    (IndexParam   , 1      , 2      , 3      )

:Test
    (5, 6, 'some string'    )
    (1, 2, 'another string' )
    (3, 4, nil              )

:End { verbose = true }
