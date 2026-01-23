-- Utility functions/classes

function randomf(lower,upper)
  return lower + math.random() * (upper - lower)
end

function startup_print(...)
    print(...)
end

function directionVector(pitch,yaw)
  local cosPitch = math.cos(pitch)
  local sinPitch = math.sin(pitch)
  local cosYaw = math.cos(yaw)
  local sinYaw = math.sin(yaw)

  local x = cosYaw * cosPitch
  local z = sinYaw * cosPitch
  local y = sinPitch

  return x,y,z
end

-- округляет число «num» до количества знаков после запятой в «idp»
--
-- print(round(107.75, -1))     : 110.0
-- print(round(107.75, 0))      : 108.0
-- print(round(107.75, 1))      : 107.8
function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function roundBase(num,idp,base)
  num = num / base
  return round(num, idp) * base
end

function clamp(value, minimum, maximum)
	return math.max(math.min(value,maximum),minimum)
end

-- вычисляет координаты x, y, z в русских координатах точки, находящейся на расстоянии 'radius'
-- из px, py, pz, используя угол x, z из 'hdg' и угол вертикального наклона
-- из 'slantangle'
function pointFromVector( px, py, pz, hdg, slantangle, radius )
    local x = px + (radius * math.cos(hdg) * math.cos(slantangle))
    local z = pz + (radius * math.sin(-hdg) * math.cos(slantangle))  -- pi/2 radians is west
    local y = py + (radius * math.sin(slantangle))

    return x,y,z
end
 
-- return GCD of m,n
function gcd(m, n)
    while m ~= 0 do
        m, n = math.fmod(n, m), m;
    end
    return n;
end


function LinearTodB(value)
    return math.pow(value, 3)
end


-- jumpwheel()
--
-- вспомогательная функция для генерации аргумента анимации для числовых колёс, которые анимируются от 0.x11 до 0.x19
-- полезно для циферблатов с выводом целых чисел или в любых случаях, когда десятичная составляющая определяет, когда
-- выполнять переворот. Все цифры будут переворачиваться одновременно с единицами, если они должны переворачиваться.
--
-- ввод 'number' — исходное необработанное число (например, 397.3275) и позиция цифры, которую вы хотите отобразить.
-- ввод 'position' — позиция цифры, которую вы хотите сгенерировать для аргумента анимации.
--
-- метод: для aBcc.dd, где B — нужная нам позиция, мы разбиваем число на
-- составляющие части:
--
--         a — отбрасываемая.
--         B станет первой цифрой вывода.
--         cc сообщает нам, переворачивается ли число или нет. Все цифры в cc должны быть равны «9».
--         dd используется для 0.Bdd в качестве возврата, если мы собираемся выбросить B.
--
function jumpwheel(number, position)
    local rolling = false
    local a,dd = math.modf( number )                -- дает нам aBcc в a и .dd в dd

    a = math.fmod( a, 10^position )                 -- снимает a, чтобы получить Bcc в a
    local B = math.floor( a / (10^(position-1)) )   -- дает нам B отдельно
    local cc = math.fmod( a, 10^(position-1) )      -- дает нам cc отдельно

    if cc == (10^(position-1)-1) then
        rolling = true                              -- если все цифры справа равны 9, то мы делаем окончательный расчет на основе десятичной составляющей
    end

    if rolling then
        return( (B+dd)/10 )
    else
        return B/10
    end
end

---------------------------------------------
--[[
Функция рекурсивного вывода таблицы в тексте также может использоваться для анализа _G.
Использование:
str=dump("_G",_G)
print(str) — либо запись в файл журнала DCS (log.alert), либо print_message_to_user и т.д. д.
--]]
function basic_dump (o)
  if type(o) == "number" then
    return tostring(o)
  elseif type(o) == "string" then
    return string.format("%q", o)
  else -- Nil, Boolean, Function, UserData, Thread; Предположим, что его можно преобразовать в строку
    return tostring(o)
  end
end


function dump (name, value, saved, result)
  seen = seen or {}       -- начальное значение
  result = result or ""
  result=result..name.." = "
  if type(value) ~= "table" then
    result=result..basic_dump(value).."\n"
  elseif type(value) == "table" then
    if seen[value] then    -- Значение уже сохранилось?
      result=result.."->"..seen[value].."\n"  -- Используйте его предыдущее имя
    else
      seen[value] = name   -- Сохраните имя на следующий раз
      result=result.."{}\n"     -- Создать новую таблицу
      for k,v in pairs(value) do      -- Сохраните свои поля
        local fieldname = string.format("%s[%s]", name,
                                        basic_dump(k))
        if fieldname~="_G[\"seen\"]" then
          result=dump(fieldname, v, seen, result)
        end
      end
    end
  end
  return result
end

function strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1) then
    return {}
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- найденный?
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end

---------------------------------------------
---------------------------------------------
--[[
Класс ПИД-регулятора (пропорционально-интегрально-дифференциальный регулятор)
(обратная дискретная форма Эйлера)
--]]

PID = {} -- таблица, представляющая класс, которая будет также служить метатаблицей для экземпляров
PID.__index = PID -- При неудачном поиске по таблице экземпляров следует вернуться к таблице класса, чтобы получить методы
setmetatable(PID, {
  __call = function( cls, ... )
    return cls.new(...) -- автоматически вызывать конструктор, когда класс вызывается как функция, например, a=PID() эквивалентно a=PID.new()
  end,
})

function PID.new( Kp, Ki, Kd, umin, umax, uscale )
    local self = setmetatable({}, PID)

    self.Kp = Kp or 1   -- по умолчанию контроллер "P" с весом = 1
    self.Ki = Ki or 0
    self.Kd = Kd or 0

    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
    self.k3 = self.Kd

    self.e2 = 0     -- история ошибок для функций I/D
    self.e1 = 0
    self.e = 0

    self.du = 0     -- delta U()
    self.u = 0      -- U() термин для вывода

    self.umax = umax or 999999  -- разрешить ограничение e для пределов выходного сигнала ПИД
    self.umin = umin or -999999
    self.uscale = uscale or 1   -- разрешить встроенное масштабирование выходных данных и ограничение диапазона

    return self
end

-- используется для настройки КП на лету
function PID:set_Kp( val )
    self.Kp = val
    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
end

-- используется для настройки КП на лету
function PID:get_Kp()
    return self.Kp
end

-- используется для настройки Ки на лету
function PID:set_Ki( val )
    self.Ki = val
    self.k1 = self.Kp + self.Ki + self.Kd
end

-- используется для настройки Ки на лету
function PID:get_Ki()
    return self.Ki
end

-- используется для настройки Kd на лету
function PID:set_Kd( val )
    self.Kd = val
    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
    self.k3 = self.Kd
end

-- используется для настройки Kd на лету
function PID:get_Kd()
    return self.Kd
end

function PID:run( setpoint, mv )
    self.e2 = self.e1
    self.e1 = self.e
    self.e = setpoint - mv

    -- обратная дискретная ПИД-функция Эйлера
    self.du = self.k1*self.e + self.k2*self.e1 + self.k3*self.e2
    self.u = self.u + self.du

    if self.u < self.umin then
        self.u = self.umin
    elseif self.u > self.umax then
        self.u = self.umax
    end

    return self.u*self.uscale
end

-- сброс динамического состояния
function PID:reset(u)
    self.e2 = 0
    self.e1 = 0
    self.e = 0

    self.du = 0
    if u then
        self.u = u/self.uscale
    else
        self.u = 0
    end
end


PID_alt = {}
PID_alt.__index = PID_alt
setmetatable(PID_alt, {
  __call = function( cls, ... )
    return cls.new(...) -- автоматически вызывать конструктор, когда класс вызывается как функция, например, a=PID() эквивалентно a=PID.new()
  end,
})

function PID_alt.new(kp, ki, kd, centre, errIMin, errIMax)
  local self = setmetatable({}, PID_alt)
  self.kp = kp
  self.ki = ki
  self.kd = kd

  self.errIMin = errIMin or -100000000.0
  self.errIMax = errIMax or  100000000.0

  self.errorD = 0.0
  self.errorI = 0.0
  self.centre = centre or 0.0

  return self
end

function PID_alt:run(setpoint, process_variable)
  local error = setpoint - process_variable

  self.errorI = clamp(self.errorI + error, self.errIMin, self.errIMax)

  local p = self.kp * error
  local i = self.ki * self.errorI
  local d = self.kd * (error - self.errorD)

  self.errorD = error

  return self.centre + p + i + d
end

function PID_alt:reset(centre)
  self.errorD = 0.0
  self.errorI = 0.0
  self.centre = centre
end

---------------------------------------------
---------------------------------------------
--[[
Класс взвешенного скользящего среднего (WMA), полезный для передачи значений датчикам в форме экспоненциального спада/роста (избегайте мгновенных ступенчатых значений).
Сохраняет только одно предыдущее значение, псевдокод:
prev_value = (weight*new_value + (1-weight)*prev_value)
Пример использования:
myvar=WMA(0.15;0) — создание объекта (однократное), первый параметр — вес для новых значений, второй параметр — начальное значение, оба параметра необязательны.
— повторное использование объекта, переданное значение хранится внутри объекта, а возвращаемое значение — взвешенное скользящее среднее.
gauge_param:set(myvar:get_WMA(new_val))

0.15 — хорошее значение для датчиков, для достижения 95% от нового заданного значения требуется около 20 шагов.
--]]

WMA = {} -- таблица, представляющая класс, которая будет также служить метатаблицей для экземпляров
WMA.__index = WMA -- Неудачные поиски в таблице экземпляров должны возвращаться к таблице класса, чтобы получить методы
setmetatable(WMA, {
  __call = function (cls, ...)
    return cls.new(...) -- автоматически вызывать конструктор, когда класс вызывается как функция, например, a=WMA() эквивалентно a=WMA.new()
  end,
})

-- Создать новый экземпляр объекта.
-- latest_weight должен быть в диапазоне от 0,01 до 1, по умолчанию 0,5, если не указано.
-- init_val задаёт начальное значение; если не указано, оно будет инициализировано при первом вызове get_WMA().
function WMA.new (latest_weight, init_val)
  local self = setmetatable({}, WMA)

  self.cur_weight=latest_weight or 0.5 -- по умолчанию 0,5, если не передано как параметр
  if self.cur_weight>1.0 then
  	self.cur_weight=1.0
  end
  if self.cur_weight<0.01 then
  	self.cur_weight=0.01
  end
  self.cur_val = init_val  -- может быть равен нулю, если не передано, будет инициализировано при первом вызове get_WMA()
  self.target_val = self.cur_val
  return self
end

-- обновляет текущее значение на основе взвешенного скользящего среднего с новым значением v и возвращает взвешенное скользящее среднее.
-- целевое значение v хранится внутри и может быть получено с помощью функции get_target_val().
function WMA:get_WMA (v)
  self.target_val = v
  if not self.cur_val then
  	self.cur_val=v
  	return self.cur_val
  end
  self.cur_val = self.cur_val+(v-self.cur_val)*self.cur_weight
  return self.cur_val
end

-- при необходимости мгновенно обновить текущее значение (обойти взвешенное скользящее среднее)
function WMA:set_current_val (v)
    self.cur_val = v
    self.target_val = v
end

-- при необходимости прочитать текущее средневзвешенное значение (без обновления взвешенного скользящего среднего новым значением)
function WMA:get_current_val ()
    return self.cur_val
end

-- прочитать целевое значение (последнее значение, переданное функции get_WMA())
function WMA:get_target_val ()
    return self.target_val
end

--[[
-- test code
target_cur={}
table.insert(target_cur, {600,0})
table.insert(target_cur, {0,600})

for k,v in ipairs(target_cur) do
	target=v[1]
	cur=v[2]

	print("--- "..cur,target)
	myvar=WMA(0.15,cur)
	for j=1,20 do
		print(myvar:get_WMA(target))
	end
end
--]]

---------------------------------------------


---------------------------------------------
--[[
Класс взвешенного скользящего среднего, который обрабатывает [range_min,range_max] как циклическое изменение, полезно для передачи значений на круговые датчики в форме экспоненциального спада/роста (избегайте мгновенных значений скачка).
Сохраняет только одно предыдущее значение, псевдокод:
prev_value = ((prev_value+weight*(wrapped(new_value-old_value)))
Пример использования:
myvar=WMA_wrap(0.15,0) -- создаёт объект (однократно), первый параметр — вес для новых значений, второй параметр — начальное значение, оба параметра необязательны.
- использует объект многократно, переданное значение хранится внутри объекта, а возвращаемое значение — взвешенное скользящее среднее, циклически изменяющееся между range_min и range_max.
gauge_param:set(myvar:get_WMA_wrap(new_val))

0.15 — хорошее значение для датчиков, для достижения 95% от нового заданного значения требуется около 20 шагов.
--]]

WMA_wrap = {} -- таблица, представляющая класс, которая будет также служить метатаблицей для экземпляров
WMA_wrap.__index = WMA_wrap -- Неудачные поиски в таблице экземпляров должны возвращаться к таблице класса, чтобы получить методы
setmetatable(WMA_wrap, {
  __call = function (cls, ...)
    return cls.new(...) -- автоматически вызывать конструктор, когда класс вызывается как функция, например, a=WMA_wrap() эквивалентно a=WMA_wrap.new()
  end,
})

-- Создать новый экземпляр объекта.
-- latest_weight должен быть в диапазоне от 0,01 до 1, по умолчанию 0,5, если не указано.
-- init_val задаёт начальное значение; если не указано, оно будет инициализировано при первом вызове get_WMA_wrap().
-- range_min по умолчанию равен 0, range_max по умолчанию равен 1.
function WMA_wrap.new (latest_weight, init_val, range_min, range_max)
  local self = setmetatable({}, WMA_wrap)

  self.cur_weight=latest_weight or 0.5 -- по умолчанию 0,5, если не передано как параметр
  if self.cur_weight>1.0 then
  	self.cur_weight=1.0
  end
  if self.cur_weight<0.01 then
  	self.cur_weight=0.01
  end
  self.cur_val = init_val  -- может быть равен нулю, если не передано, будет инициализировано при первом вызове get_WMA_wrap()
  self.target_val = self.cur_val
  self.range_min=math.min(range_min or 0.0, range_max or 1.0)
  self.range_max=math.max(range_min or 0.0, range_max or 1.0)
  self.range_delta=range_max-range_min;
  self.range_thresh=self.range_delta/8192
  return self
end

-- Это почти наверняка можно упростить, но я поленился и сделал по-простому.
local function get_shortest_delta(target,cur,min,max)
	local d1,d2,delta
	if target>=cur then
		d1=target-cur
		d2=cur-min+(max-target)
		if d2<d1 then
			delta=-d2
		else
			delta=d1
		end
	else
		d1=cur-target
		d2=target-min+(max-cur)
		if d1<d2 then
			delta=-d1
		else
			delta=d2
		end
	end
	return delta
end

-- обновляет текущее значение на основе взвешенного скользящего среднего с новым значением v и возвращает взвешенное скользящее среднее.
-- целевое значение v хранится внутри и может быть получено с помощью функции get_target_val().
-- функция охватывает диапазон [range_min,range_max] и также перемещается в кратчайшем направлении (по часовой стрелке или против часовой стрелки) между двумя точками.
function WMA_wrap:get_WMA_wrap (v)
  self.target_val = v
  if not self.cur_val then
  	self.cur_val=v
  	return self.cur_val
  end
  delta=get_shortest_delta(v, self.cur_val, self.range_min, self.range_max)
  self.cur_val=self.cur_val+(delta*self.cur_weight)
  if math.abs(delta)<self.range_thresh then
    self.cur_val=self.target_val
  end
  if self.cur_val>self.range_max then
  	self.cur_val=self.cur_val-self.range_delta
  elseif self.cur_val<self.range_min then
  	self.cur_val=self.cur_val+self.range_delta
  end
  return self.cur_val
end

-- при необходимости мгновенно обновить текущее значение (обойти взвешенное скользящее среднее)
function WMA_wrap:set_current_val (v)
    self.cur_val = v
    self.target_val = v
end

-- при необходимости прочитать текущее средневзвешенное значение (без обновления взвешенного скользящего среднего новым значением)
function WMA_wrap:get_current_val ()
    return self.cur_val
end

-- прочитать целевое значение (последнее значение, переданное функции get_WMA_wrap())
function WMA_wrap:get_target_val ()
    return self.target_val
end

Random_Walker = {}
Random_Walker.__index = Random_Walker
setmetatable(Random_Walker,
  {
    __call = function(cls, ...) return cls.new(...) end
  }
)

function Random_Walker.new(speed, min, max, start)
  local self = setmetatable({}, Random_Walker)
  self.speed = speed
  self.min = min
  self.max = max
  self.pos = start
  self.vel = 0.0
  return self
end

function Random_Walker:update(timestep)
  local step = randomf(-self.speed, self.speed)
  self.vel = clamp(self.vel + step * timestep, self.min,self.max)
  self.pos = clamp(self.pos + self.vel * timestep, self.min,self.max)
end

--------------------------------------------------------------------

Constant_Speed_Controller = {}
Constant_Speed_Controller.__index = Constant_Speed_Controller
setmetatable(Constant_Speed_Controller,
  {
    __call = function(cls, ...)
        return cls.new(...) --вызов конструктора, если кто-то вызывает эту таблицу
    end
  }
)

function Constant_Speed_Controller.new(speed, min, max, pos)
  local self = setmetatable({}, Constant_Speed_Controller)
  self.speed = speed
  self.min = min
  self.max = max
  self.pos = pos

  return self
end

function Constant_Speed_Controller:update(target)

  local p = self.pos
  local direction = target - self.pos

  if math.abs(direction) <= self.speed then
    self.pos = target
  elseif direction < 0.0 then
    self.pos = self.pos - self.speed
  elseif direction > 0.0 then
    self.pos = self.pos + self.speed
  end

end

function Constant_Speed_Controller:get_position()
  return self.pos
end

function Constant_Speed_Controller:set_position(x)
  self.pos = x
end










--------------------------------------------------------------------

--[[
Описание
Рекурсивно спускается по мета- и обычным таблицам и выводит их пары ключ:значение до тех пор,
пока не будут достигнуты пределы или таблица не будет исчерпана. Возвращает результирующую строку.

@param[in] table_to_print 		корень таблиц для рекурсивного исследования
@param[in] max_depth				сколько уровней рекурсии (не рекурсии функций) разрешено.
@param[in] max_number_tables		сколько всего различных таблиц разрешено обрабатывать

@return STRING
]]--
function recursively_traverse(table_to_print, max_depth, max_number_tables)
	
  max_depth = max_depth or 100
  max_number_tables = max_number_tables or 100

	stack = {}
	
	table.insert(stack, {key = "start", value = table_to_print, level = 0})
	
	total = 0
	
	hash_table = {}

	hash_table[tostring(hash_table)] = 2
	hash_table[tostring(stack)] = 2
	
  str = ""

	item = true
	while (item) do
		item = table.remove(stack)
		
		if (item == nil) then
			break
		end
		key = item.key
		value = item.value
		level = item.level
		
		str = str..(string.rep("        ", level)..tostring(key).." = "..tostring(value).."\n")
		
		hash = hash_table[tostring(value)]
		valid_table = (hash == nil or hash < 2)
		
		if (type(value) == "table" and valid_table) then
			for k,v in pairs(value) do
				if (v ~= nil and level <= max_depth and total < max_number_tables) then
					table.insert(stack, {key = k, value = v, level = level+1})
					if (type(v) == "table") then
						if (hash_table[tostring(v)] == nil) then
							hash_table[tostring(v)] = 1
						elseif (hash_table[tostring(v)] < 2) then
							hash_table[tostring(v)] = 2
						end
						total = total + 1
					end
				end
			end
		end
		
		if (getmetatable(value) and valid_table) then
			for k,v in pairs(getmetatable(value)) do
				if (v ~= nil and level <= max_depth and total < max_number_tables) then
					table.insert(stack, {key = k, value = v, level = level+1})
					if (type(v) == "table") then
						if (hash_table[tostring(v)] == nil) then
							hash_table[tostring(v)] = 1
						elseif (hash_table[tostring(v)] < 2) then
							hash_table[tostring(v)] = 2
						end
						total = total + 1
					end
				end
			end
		end
	end

  return str
end

--[[
Описание
Рекурсивно спускается по мета- и обычным таблицам и выводит их пары ключ:значение до тех пор,
пока не будут достигнуты пределы или таблица не будет исчерпана.

@param[in] table_to_print 		корень таблиц для рекурсивного исследования
@param[in] max_depth				сколько уровней рекурсии (не рекурсии функций) разрешено.
@param[in] max_number_tables		сколько всего различных таблиц разрешено обрабатывать
@param[in] filepath				путь для размещения этих данных

@return VOID
]]--
function recursively_print(table_to_print, filepath, max_depth, max_number_tables)
  file = io.open(filepath, "w")
	file:write("Key,Value\n")
  str = recursively_traverse(table_to_print,max_depth,max_number_tables)
  file:write(str)
  file:close()
end

--[[
-- test code
target_cur={}
table.insert(target_cur, {350,10})
table.insert(target_cur, {10,350})
table.insert(target_cur, {280,90})
table.insert(target_cur, {90,280})

for k,v in ipairs(target_cur) do
	target=v[1]
	cur=v[2]

	print("--- "..cur,target)
	myvar=WMA_wrap(0.15,cur,0,360)
	for j=1,20 do
		print(myvar:get_WMA_wrap(target))
	end
end
--]]
---------------------------------------------

--[[
Описание
Получить указатель на таблицу vfptr для lua-устройства устройства. Это
используется в «хаках» для работы радио (и, возможно, ILS).

@param[in] avDevice   Устройство, для которого необходимо получить ptr.
@return STRING        Строка, содержащая адрес таблицы vfptr устройства lua.
]]--
function find_lua_device_ptr(device)
  str_ptr = string.sub(tostring(device.link),10)
  return str_ptr
end

function bearing_to_vec2d(brg)
	brg = math.rad(brg)
	vec = {
		x = math.cos(brg),
		z = math.sin(brg)
	}
	
	return vec
end

function vec2d_to_bearing(vec)
	angle = math.deg(math.atan2(vec.z,vec.x))
	
	if angle < 0 then
		angle = 360 + angle
	end
	
	return angle
end

function normalize_vec2d(vec)
	mag = math.sqrt(vec.x^2 + vec.z^2)
	new_vec = {
		x = vec.x / mag,
		z = vec.z / mag
	}
	return new_vec
end

local function stub(self, ...) 
  return nil
end

local function new(cls, ...)
  tbl = getmetatable(cls)
  tbl.__index = tbl

  return setmetatable({}, tbl)
end

function require_avionics()
  package.cpath = package.cpath..";"..LockOn_Options.script_path.."..\\..\\bin\\?.dll"
  success,result = pcall(require,'ScooterAvionics')

  if success and result ~= false then
    return result
  else
    -- Они заглушают функции, необходимые ScooterAvionics.dll
    -- Это сделано для того, чтобы при перекомпиляции открытой части кода
    -- они по-прежнему могут использовать самолет без ошибок.
    local stubs = {
      ExtendedRadio = setmetatable({}, {
        __call = new,
        init = stub,
        setPower = stub,
        pushToTalk = stub,
      }),

      AdvancedWeaponSystem = setmetatable({}, {
        __call = new,
        launch = stub,
        updateSteering = stub,
      }),

      MissionObjects = {
        getObjectBearing = stub,
        getObjectPosition = stub,
      },
    }
    return stubs
  end
end

function CreateAlternateChannels()
  channels = {
    254,
    265,
    256,
    254,
    250,
    270,
    257,
    258,
    262,
    259,
    268,
    269,
    260,
    263,
    261,
    267,
    253,
    266,
    251,
    251
  }
  return channels
end


function GetRadioChannels()
  if get_aircraft_mission_data == nil then
    return CreateAlternateChannels()
  end

  local radio = get_aircraft_mission_data("Radio")

  if radio == nil then
    return CreateAlternateChannels()
  end

  local radio_one = radio[1]
  if radio_one == nil then
    return CreateAlternateChannels()
  end

  local channels = radio_one.channels
  if channels then
    return channels
  end

  return CreateAlternateChannels()
end