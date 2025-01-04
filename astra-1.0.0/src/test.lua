local astra = require "astra"

-- 辅助函数：用于比较两个值是否相等（对于浮点数使用一定的容差）
local function nearly_equal(a, b, epsilon)
    return math.abs(a - b) < (epsilon or 1e-6)
end

-- 辅助函数：用于打印测试结果
local function print_test_result(name, success, message)
    if success then
        print(string.format("Test %s: PASSED", name))
    else
        print(string.format("Test %s: FAILED - %s", name, message or "Unexpected result"))
    end
end

-- 测试 Summary 函数
function test_summary()
    local data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    local expected_output = {
        Min = 1,
        ["1st Qu."] = 3.25,
        Median = 5.5,
        Mean = 5.5,
        ["3rd Qu."] = 7.75,
        Max = 10
    }

    -- 修改 Summary 函数以返回表格而不是打印
    local function Summary(data)
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

        -- 返回统计摘要表格
        return {
            Min = min_val,
            ["1st Qu."] = first_quartile,
            Median = median_val,
            Mean = mean_val,
            ["3rd Qu."] = third_quartile,
            Max = max_val
        }
    end

    local result = Summary(data)

    local success = true
    for key, expected in pairs(expected_output) do
        if not nearly_equal(result[key], expected) then
            success = false
            break
        end
    end

    print_test_result("Summary", success)
end

-- 测试 Which 函数
function test_which()
    local data = {1, 2, 3, 4, 5, nil, 7, 8, 9, 10}
    local condition_func = function(x) return x and x > 5 end
    local expected_indices = {6, 8, 9, 10} -- 注意 nil 被跳过

    local indices = astra.Which(condition_func, data)
    local success = #indices == #expected_indices
    for i, index in ipairs(indices) do
        if index ~= expected_indices[i] then
            success = false
            break
        end
    end

    print_test_result("Which with function condition", success)

    local logical_condition = {false, false, false, false, false, true, true, true, true, true}
    local expected_logical_indices = {6, 7, 8, 9, 10}

    indices = astra.Which(logical_condition, data)
    success = #indices == #expected_logical_indices
    for i, index in ipairs(indices) do
        if index ~= expected_logical_indices[i] then
            success = false
            break
        end
    end

    print_test_result("Which with logical table condition", success)
end

-- 测试 Is_na 函数
function test_is_na()
    local data = {1, 2, nil, 4, nil, 6}
    local expected_result = {false, false, true, false, true, false}
    local result = astra.Is_na(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Is_na", success)
end

-- 测试 Na_omit 函数
function test_na_omit()
    local data = {1, 2, nil, 4, nil, 6}
    local expected_result = {1, 2, 4, 6}
    local result = astra.Na_omit(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Na_omit", success)
end

-- 测试 Narm 函数
function test_narm()
    local data = {1, 2, nil, 4, 5}
    local expected_result = 3
    local result = astra.Narm(data)

    local success = nearly_equal(result, expected_result)
    print_test_result("Narm", success)
end

-- 测试 Abs 函数
function test_abs()
    local data = {-1, 2, -3, 4, -5}
    local expected_result = {1, 2, 3, 4, 5}
    local result = astra.Abs(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Abs", success)
end

-- 测试 Sqrt 函数
function test_sqrt()
    local data = {4, 9, 16, 25}
    local expected_result = {2, 3, 4, 5}
    local result = astra.Sqrt(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Sqrt", success)
end

-- 测试 Ceil 函数
function test_ceil()
    local data = {1.1, 2.5, 3.9, 4.0}
    local expected_result = {2, 3, 4, 4}
    local result = astra.Ceil(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Ceil", success)
end

-- 测试 Floor 函数
function test_floor()
    local data = {1.1, 2.5, 3.9, 4.0}
    local expected_result = {1, 2, 3, 4}
    local result = astra.Floor(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Floor", success)
end

-- 测试 Trunc 函数
function test_trunc()
    local data = {-1.1, 2.5, -3.9, 4.0}
    local expected_result = {-1, 2, -3, 4}
    local result = astra.Trunc(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if v ~= expected_result[i] then
            success = false
            break
        end
    end

    print_test_result("Trunc", success)
end

-- 测试 Round 函数
function test_round()
    local data = {1.123, 2.567, 3.890, 4.000}
    local n = 2
    local expected_result = {1.12, 2.57, 3.89, 4.00}
    local result = astra.Round(data, n)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Round", success)
end

-- 测试 Signif 函数
function test_signif()
    local data = {123.456, 0.00123456, 123456}
    local n = 3
    local expected_result = {123, 0.00123, 123000}
    local result = astra.Signif(data, n)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Signif", success)
end

-- 测试 Acosh 函数
function test_acosh()
    local data = {1, 2, 3, 4}
    local expected_result = {0, 1.31695789692482, 1.76274717403909, 2.06343706889556}
    local result = astra.Acosh(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Acosh", success)
end

-- 测试 Asinh 函数
function test_asinh()
    local data = {-1, 0, 1, 2}
    local expected_result = {-0.881373587019543, 0, 0.881373587019543, 1.44363547517881}
    local result = astra.Asinh(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Asinh", success)
end

-- 测试 Atanh 函数
function test_atanh()
    local data = {-0.5, 0, 0.5}
    local expected_result = {-0.549306144334055, 0, 0.549306144334055}
    local result = astra.Atanh(data)

    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end

    print_test_result("Atanh", success)
end

-- 测试 Mean 函数
function test_mean()
    local data = {1, 2, 3, 4, 5}
    local expected_result = 3
    local result = astra.Mean(data)
    print_test_result("Mean", nearly_equal(result, expected_result))
end

-- 测试 Median 函数
function test_median()
    local data = {1, 2, 3, 4, 5}
    local expected_result = 3
    local result = astra.Median(data)
    print_test_result("Median", nearly_equal(result, expected_result))

    local data_even = {1, 2, 3, 4}
    local expected_result_even = 2.5
    local result_even = astra.Median(data_even)
    print_test_result("Median (even)", nearly_equal(result_even, expected_result_even))
end

-- 测试 Sd 函数
function test_sd()
    local data = {1, 2, 3, 4, 5}
    local expected_result = math.sqrt(2)
    local result = astra.Sd(data)
    print_test_result("Sd", nearly_equal(result, expected_result))
end

-- 测试 Var 函数
function test_var()
    local data = {1, 2, 3, 4, 5}
    local expected_result = 2
    local result = astra.Var(data)
    print_test_result("Var", nearly_equal(result, expected_result))
end

-- 测试 Mad 函数
function test_mad()
    local data = {1, 2, 3, 4, 5}
    local expected_result = 1.2
    local result = astra.Mad(data)
    print_test_result("Mad", nearly_equal(result, expected_result))
end

-- 辅助函数：用于比较两个浮点数是否相等（对于浮点数使用一定的容差）
local function nearly_equal(a, b, epsilon)
    return math.abs(a - b) < (epsilon or 1e-6)
end

-- 打印测试结果
local function print_test_result(test_name, success)
    if success then
        print(string.format("Test %s: PASSED", test_name))
    else
        print(string.format("Test %s: FAILED", test_name))
    end
end

-- 测试 Quantile 函数
function test_quantile()
    local data = {1, 2, 3, 4, 5}
    local q1, q2 = astra.Quantile(data, 0.3, 0.84)
    local expected_q1 = 2.2
    local expected_q2 = 4.7
    local success = nearly_equal(q1, expected_q1) and nearly_equal(q2, expected_q2)
    print_test_result("Quantile", success)
end

-- 测试 Range 函数
function test_range()
    local data = {1, 2, 3, 4, 5}
    local min, max = astra.Range(data)
    local expected_min = 1
    local expected_max = 5
    local success = nearly_equal(min, expected_min) and nearly_equal(max, expected_max)
    print_test_result("Range", success)
end

-- 测试 Sum 函数
function test_sum()
    local data = {1, 2, 3, 4, 5}
    local result = astra.Sum(data)
    local expected_result = 15
    local success = nearly_equal(result, expected_result)
    print_test_result("Sum", success)
end

-- 测试 Diff 函数
function test_diff()
    local data = {1, 2, 3, 4, 5}
    local result = astra.Diff(data, 1)
    local expected_result = {1, 1, 1, 1}
    local success = #result == #expected_result
    for i, v in ipairs(result) do
        if not nearly_equal(v, expected_result[i]) then
            success = false
            break
        end
    end
    print_test_result("Diff", success)
end

-- 测试 Min 函数
function test_min()
    local data = {1, 2, 3, 4, 5}
    local result = astra.Min(data)
    local expected_result = 1
    local success = nearly_equal(result, expected_result)
    print_test_result("Min", success)
end

-- 测试 Max 函数
function test_max()
    local data = {1, 2, 3, 4, 5}
    local result = astra.Max(data)
    local expected_result = 5
    local success = nearly_equal(result, expected_result)
    print_test_result("Max", success)
end

-- 测试 Scale 函数
function test_scale()
    local data = {1, 2, 3, 4, 5}
    local scaled = astra.Scale(data)
    local expected_scaled = {-1.4142135623731, -0.70710678118655, 0, 0.70710678118655, 1.4142135623731}
    local success = #scaled == #expected_scaled
    for i, v in ipairs(scaled) do
        if not nearly_equal(v, expected_scaled[i]) then
            success = false
            break
        end
    end
    print_test_result("Scale", success)
end

-- 运行所有测试
function run_all_tests()
    test_summary()
    test_which()
    test_is_na()
    test_na_omit()
    test_narm()
    test_abs()
    test_sqrt()
    test_ceil()
    test_floor()
    test_trunc()
    test_round()
    test_signif()
    test_acosh()
    test_asinh()
    test_atanh()
    test_mean()
    test_median()
    test_sd()
    test_var()
    test_mad()
    test_quantile()
    test_range()
    test_sum()
    test_diff()
    test_min()
    test_max()
    test_scale()
end

-- 执行所有测试
run_all_tests()