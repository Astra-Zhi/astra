local astra = {}
astra.VERSION = "1.0.0"

-- 辅助函数，用于处理数值和表的递归计算
local function apply_to_elements(func, value)
    if value == nil then
        return nil
    elseif type(value) == "number" then
        return func(value)
    elseif type(value) == "table" then
        local result = {}
        for k, v in pairs(value) do
            result[k] = apply_to_elements(func, v)
        end
        return result
    else
        return value  -- 对于非数字和非表的其他类型，直接返回原值
    end
end

-----------------------------------------------------------------------------------
-- 模块: 输出工具
--- 用于直接输出信息的函数
-- @param ... 变长参数，可以是任意类型的值
-- @return 无返回值，但在控制台打印出格式化的输出
function astra.show(...)
    local function print_table(tbl, indent)
        indent = indent or 0
        local indent_str = string.rep("  ", indent)

        for key, value in pairs(tbl) do
            if type(value) == "table" then
                print(indent_str .. tostring(key) .. ":")
                print_table(value, indent + 1)
            else
                print(indent_str .. tostring(key) .. " = " .. tostring(value))
            end
        end
    end

    for i, arg in ipairs({...}) do
        if type(arg) == "table" then
            print("[Table]")
            print_table(arg)
        elseif type(arg) == "userdata" then
            local mt = getmetatable(arg)
            if mt and mt.__tostring then
                print(tostring(arg))
            else
                print("[Userdata without __tostring]")
            end
        else
            print(tostring(arg))
        end
    end
end

-----------------------------------------------------------------------------------
-- 辅助函数：舍入函数
local function round_helper(x, n, base_func)
    if x == 0 or not n then return x end
    local factor = 10 ^ (n or 0)
    return base_func(x * factor + 0.5) / factor
end


-----------------------------------------------------------------------------------
-- 模块: Summary()函数模块
--- 计算一个数值数组的最小值（Min）、第一四分位数（1st Qu.）、中位数（Median）、平均值（Mean）、第三四分位数（3rd Qu.）和最大值（Max）
-- @param data 数值数组，包含要分析的数据点
-- @return 无返回值，但在控制台打印出统计摘要
function astra.Summary(data)
    if not data or #data == 0 then
        error("Input data is empty or nil")
    end

    -- 创建数据的排序副本
    local sorted_data = {}
    for _, v in ipairs(data) do
        table.insert(sorted_data, v)
    end
    table.sort(sorted_data)

    -- 计算统计数据
    local n = #sorted_data
    local min_val = sorted_data[1]
    local max_val = sorted_data[n]
    local sum = 0
    local count = 0
    for _, v in ipairs(data) do
        if type(v) == "number" then
            sum = sum + v
            count = count + 1
        end
    end
    local mean_val = count > 0 and sum / count or 0

    -- 定义计算四分位数的辅助函数
    local function quartile(q)
        if n == 1 then
            return sorted_data[1]  -- 特殊处理单元素数组
        end

        local pos = q * (n + 1)
        local lower = math.floor(pos)
        local upper = math.ceil(pos)
        if lower == upper then
            return sorted_data[lower]
        else
            local lower_value = sorted_data[lower] or 0
            local upper_value = sorted_data[upper] or lower_value
            return lower_value + (pos - lower) * (upper_value - lower_value)
        end
    end

    local median_val = quartile(0.5)
    local first_quartile = quartile(0.25)
    local third_quartile = quartile(0.75)

    -- 打印统计摘要，格式类似于 R 的 output
    print(string.format("%7s %7s %7s %7s %7s %7s", "Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max."))
    print(string.format("%7.1f %7.1f %7.1f %7.1f %7.1f %7.1f", 
                        min_val, first_quartile, median_val, mean_val, third_quartile, max_val))
end

-----------------------------------------------------------------------------------
-- 模块: Which()函数模块
-- @param condition 表达式或函数，用于判断每个元素是否满足条件
-- @param data 数值数组或逻辑数组
-- @return 索引列表，包含满足条件的元素的索引
function astra.Which(condition, data)
    if not data or #data == 0 then
        error("Input data is empty or nil")
    end

    local indices = {}
    if type(condition) == "function" then
        for i, v in ipairs(data) do
            if condition(v) then
                table.insert(indices, i)
            end
        end
    elseif type(condition) == "table" then
        for i, v in ipairs(data) do
            if condition[i] then
                table.insert(indices, i)
            end
        end
    else
        error("Condition must be a function or a logical table")
    end
    return indices
end

-----------------------------------------------------------------------------------
-- 模块: Is_na()函数模块
-- @param data 数值数组
-- @return 逻辑数组，指示每个元素是否为 nil
function astra.Is_na(data)
    local result = {}
    for i, v in ipairs(data) do
        result[i] = v == nil
    end
    return result
end

-----------------------------------------------------------------------------------
-- 模块: Na_omit()函数模块
-- @param data 数值数组
-- @return 新的数组，移除了所有 nil 元素
function astra.Na_omit(data)
    local result = {}
    for _, v in pairs(data) do
        if v ~= nil then
            table.insert(result, v)
        end
    end
    return result
end

-----------------------------------------------------------------------------------
-- 模块: Narm
-- @param t 数值数组，可能包含 nil 值
-- @return 平均值（如果数组中没有非 nil 元素，则返回 nil）
function astra.Narm(t)
    if not t or #t == 0 then
        return nil
    end

    local sum = 0
    local count = 0
    for _, value in pairs(t) do
        if type(value) == "number" then
            sum = sum + value
            count = count + 1
        end
    end

    return count > 0 and sum / count or nil
end

-----------------------------------------------
-- 模块：绝对值计算
-- @param value 数值或包含数值的表
-- @return 绝对值或包含绝对值的新表
function astra.Abs(value)
    return apply_to_elements(math.abs, value)
end

-----------------------------------------------------------------------------------
-- 模块：根号计算
-- @param value 数值或包含数值的表
-- @return 平方根或包含平方根的新表
function astra.Sqrt(value)
    local sqrt_func = math.sqrt
    return apply_to_elements(sqrt_func, value)
end

-----------------------------------------------------------------------------------
-- 模块：不小于X的最小整数
-- @param value 数值或包含数值的表
-- @return 不小于X的最小整数或包含不小于X的最小整数的新表
function astra.Ceil(value)
    local ceil_func = math.ceil
    return apply_to_elements(ceil_func, value)
end

-----------------------------------------------------------------------------------
-- 模块：不大于X的最大整数
-- @param value 数值或包含数值的表
-- @return 不大于X的最大整数或包含不大于X的最大整数的新表
function astra.Floor(value)
    local floor_func = math.floor
    return apply_to_elements(floor_func, value)
end

-----------------------------------------------------------------------------------
-- 模块：向0的方向为X取整
-- @param value 数值或包含数值的表
-- @return 向0的方向为X取整或包含向0的方向为X取整的新表
function astra.Trunc(value)
    local trunc_func = math.tointeger or function(x) return x >= 0 and math.floor(x) or math.ceil(x) end
    return apply_to_elements(trunc_func, value)
end

-----------------------------------------------------------------------------------
-- 模块：将X舍入为指定位的小数
-- @param value 数值或包含数值的表
-- @param n 小数位数
-- @return 将X舍入为指定的小数位数
function astra.Round(value, n)
    return apply_to_elements(function(x) return round_helper(x, n, math.floor) end, value)
end

-----------------------------------------------------------------------------------
-- 模块：将X舍入为指定的有效数字位数
-- @param value 数值或包含数值的表
-- @param n 有效数字位数
-- @return 将X舍入为指定的有效数字位数
function astra.Signif(value, n)
    return apply_to_elements(function(x)
        if x == 0 then return 0 end

        local abs_x = math.abs(x)
        local log10_abs_x = math.log(abs_x) / math.log(10)
        local exp = math.floor(log10_abs_x) + 1
        local factor = 10^(n - exp)

        return round_helper(x * factor, 0, math.floor) / factor
    end, value)
end

-----------------------------------------------------------------------------------
-- 模块: acosh 函数
-- 计算 x 的反双曲余弦值
-- @param value 数值或包含数值的表
-- @return 反双曲余弦值或包含反双曲余弦值的新表
function astra.Acosh(value)
    local function acosh_impl(x)
        if x < 1 then
            error("acosh is only defined for x >= 1")
        end
        return math.log(x + math.sqrt(x * x - 1))
    end
    return apply_to_elements(acosh_impl, value)
end

-----------------------------------------------------------------------------------
-- 模块: asinh 函数
-- 计算 x 的反双曲正弦值
-- @param value 数值或包含数值的表
-- @return 反双曲正弦值或包含反双曲正弦值的新表
function astra.Asinh(value)
    local function asinh_impl(x)
        return math.log(x + math.sqrt(x * x + 1))
    end
    return apply_to_elements(asinh_impl, value)
end

-----------------------------------------------------------------------------------
-- 模块: atanh 函数
-- 计算 x 的反双曲正切值
-- @param value 数值或包含数值的表
-- @return 反双曲正切值或包含反双曲正切值的新表
function astra.Atanh(value)
    local function atanh_impl(x)
        if x <= -1 or x >= 1 then
            error("atanh is only defined for -1 < x < 1")
        end
        return 0.5 * math.log((1 + x) / (1 - x))
    end
    return apply_to_elements(atanh_impl, value)
end

-----------------------------------------------------------------------------------
-- 模块: 统计函数模块
-- @module astra.stats

-----------------------------------------------------------------------------------
-- 辅助函数: 计算数组中数值的数量
local function count_numbers(data)
    local count = 0
    for _, v in pairs(data) do
        if type(v) == "number" then
            count = count + 1
        end
    end
    return count
end

-----------------------------------------------------------------------------------
-- 辅助函数: 过滤并返回仅包含数值的数组
local function filter_numbers(data)
    local filtered = {}
    for _, v in pairs(data) do
        if type(v) == "number" then
            table.insert(filtered, v)
        end
    end
    return filtered
end

-----------------------------------------------------------------------------------
-- 单次遍历优化版本的 Sd 和 Var 函数的辅助函数
-- 使用 Welford's 算法来在线计算方差和标准差
function astra.WelfordStats(value)
    local n = 0
    local mean = 0
    local M2 = 0

    for _, v in pairs(value) do
        if type(v) == "number" then
            n = n + 1
            local delta = v - mean
            mean = mean + delta / n
            M2 = M2 + delta * (v - mean)
        end
    end

    if n < 2 then
        return nil, nil
    end

    local variance = M2 / n
    local std_dev = math.sqrt(variance)

    return variance, std_dev
end

-----------------------------------------------------------------------------------
-- 模块: mean 函数
-- 计算数组的平均值
-- @param value 数值或包含数值的表
-- @return 数组的平均值
function astra.Mean(value)
    local sum = 0
    local count = count_numbers(value)
    for _, v in pairs(value) do
        if type(v) == "number" then
            sum = sum + v
        end
    end
    return count > 0 and sum / count or nil
end

-----------------------------------------------------------------------------------
-- 模块: median 函数
-- 计算数组的中位数
-- @param value 数值或包含数值的表
-- @return 数组的中位数
function astra.Median(value)
    local sorted = filter_numbers(value)
    if #sorted == 0 then return nil end
    table.sort(sorted)
    local mid = math.floor(#sorted / 2)
    if #sorted % 2 == 0 then
        return (sorted[mid] + sorted[mid + 1]) / 2
    else
        return sorted[mid + 1]
    end
end

-----------------------------------------------------------------------------------
-- 模块: sd 函数
-- 计算数组的标准差
-- @param value 数值或包含数值的表
-- @return 数组的标准差
function astra.Sd(value)
    local _, std_dev = astra.WelfordStats(value)
    return std_dev
end

-----------------------------------------------------------------------------------
-- 模块: var 函数
-- 计算数组的方差
-- @param value 数值或包含数值的表
-- @return 数组的方差
function astra.Var(value)
    local variance, _ = astra.WelfordStats(value)
    return variance
end
-----------------------------------------------------------------------------------
-- 模块: mad 函数
-- 计算数组的绝对中位差
-- @param value 数值或包含数值的表
-- @return 数组的绝对中位差
function astra.Mad(value)
    local median = astra.Median(value)
    if median == nil then return nil end

    local sum_of_abs_diffs = 0
    local count = count_numbers(value)
    for _, v in pairs(value) do
        if type(v) == "number" then
            sum_of_abs_diffs = sum_of_abs_diffs + math.abs(v - median)
        end
    end
    return count > 0 and sum_of_abs_diffs / count or nil
end

-- 辅助函数: 计算数组中数值的数量
local function count_numbers(data)
    local count = 0
    for _, v in pairs(data) do
        if type(v) == "number" then
            count = count + 1
        end
    end
    return count
end

-----------------------------------------------------------------------------------
-- 辅助函数: 过滤并返回仅包含数值的数组
local function filter_numbers(data)
    local filtered = {}
    for _, v in pairs(data) do
        if type(v) == "number" then
            table.insert(filtered, v)
        end
    end
    return filtered
end

-----------------------------------------------------------------------------------
-- 模块: quantile 函数
--- 求数组的分位数
-- @param value 数值或包含数值的表
-- @param ... 一个或多个分位数（0 到 1 之间的数值）
-- @return 分位数的结果
function astra.Quantile(value, ...)
    local sorted = filter_numbers(value)
    if #sorted == 0 then return nil end
    table.sort(sorted)

    local quantiles = {...}
    local results = {}

    for _, q in ipairs(quantiles) do
        if q < 0 or q > 1 then
            error("Quantile must be between 0 and 1")
        end

        local index = (q * (#sorted - 1)) + 1
        local lower = math.floor(index)
        local upper = math.ceil(index)

        if lower == upper then
            table.insert(results, sorted[lower])
        else
            local lower_value = sorted[lower] or 0
            local upper_value = sorted[upper] or lower_value
            table.insert(results, lower_value + (index - lower) * (upper_value - lower_value))
        end
    end

    return table.unpack(results)
end

-----------------------------------------------------------------------------------
-- 模块: range 函数
--- 求数组的值域
-- @param value 数值或包含数值的表
-- @return 数组的最小值和最大值
function astra.Range(value)
    local min, max = math.huge, -math.huge
    for _, v in pairs(value) do
        if type(v) == "number" then
            min = math.min(min, v)
            max = math.max(max, v)
        end
    end
    return min == math.huge and nil or min, max == -math.huge and nil or max
end

-----------------------------------------------------------------------------------
-- 模块: sum 函数
--- 求和
-- @param value 数值或包含数值的表
-- @return 数组求和
function astra.Sum(value)
    local sum = 0
    for _, v in pairs(value) do
        if type(v) == "number" then
            sum = sum + v
        end
    end
    return sum
end

-----------------------------------------------------------------------------------
-- 模块: diff 函数
--- 滞后差分，默认滞后1，lag用以指定滞后数
-- @param value 数值或包含数值的表
-- @param lag 滞后数，默认为1
-- @return 数组差分
function astra.Diff(value, lag)
    lag = lag or 1
    local diff = {}
    for i = 1, #value - lag do
        if type(value[i]) == "number" and type(value[i + lag]) == "number" then
            diff[#diff + 1] = value[i + lag] - value[i]
        end
    end
    return diff
end

-----------------------------------------------------------------------------------
-- 模块: min 函数
--- 求最小值
-- @param value 数值或包含数值的表
-- @return 数组最小值
function astra.Min(value)
    local min = math.huge
    for _, v in pairs(value) do
        if type(v) == "number" then
            min = math.min(min, v)
        end
    end
    return min == math.huge and nil or min
end

-----------------------------------------------------------------------------------
-- 模块: max 函数
--- 求最大值
-- @param value 数值或包含数值的表
-- @return 数组最大值
function astra.Max(value)
    local max = -math.huge
    for _, v in pairs(value) do
        if type(v) == "number" then
            max = math.max(max, v)
        end
    end
    return max == -math.huge and nil or max
end

-----------------------------------------------------------------------------------
-- 模块: scale 函数
--- 维数据对象X按列进行中心化或标准化
-- @param value 数值或包含数值的表
-- @return 数组中心化或标准化
function astra.Scale(value)
    local mean = astra.Mean(value)
    local sd = astra.Sd(value)
    if sd == 0 then return value end  -- 避免除以零

    local scaled = {}
    for _, v in pairs(value) do
        if type(v) == "number" then
            table.insert(scaled, (v - mean) / sd)
        end
    end
    return scaled
end

return astra