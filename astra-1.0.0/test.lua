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

-- 测试 Factor 函数
function Test_factor()
    print("Testing Factor function...")

    -- 正常情况
    local data = {"apple", "banana", "apple", "orange", "banana"}
    local factor = astra.Factor(data)
    assert(#factor.levels == 3, "Expected 3 levels")
    assert(factor.level_map["apple"] == 1, "apple should be level 1")
    assert(factor.level_map["banana"] == 2, "banana should be level 2")
    assert(factor.level_map["orange"] == 3, "orange should be level 3")
    assert(table.concat(factor.encoded_data, ",") == "1,2,1,3,2", "Encoded data should match")

    -- 空表
    local empty_data = {}
    local empty_factor = astra.Factor(empty_data)
    assert(#empty_factor.levels == 0, "Empty data should have 0 levels")
    assert(#empty_factor.encoded_data == 0, "Empty data should have 0 encoded elements")

    -- 错误输入
    local invalid_data = nil
    local status, err = pcall(astra.Factor, invalid_data)
    assert(not status and string.find(err, "Data must be a table"), "Invalid input should raise an error")

    print("Factor function tests passed.")
end

-- 测试 Array 函数
function Test_array()
    print("Testing Array function...")

    -- 2D 数组，不循环
    local dims_2d = {3, 4}
    local array_2d = astra.Array(dims_2d, 1, 12, false)
    assert(#array_2d == 3, "2D array should have 3 rows")
    for i = 1, 3 do
        assert(#array_2d[i] == 4, "Each row should have 4 elements")
    end
    local expected_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
    local actual_values = {}
    for i = 1, 3 do
        for j = 1, 4 do
            table.insert(actual_values, array_2d[i][j])
        end
    end
    assert(table.concat(actual_values, ",") == table.concat(expected_values, ","), "2D array values should match")

    -- 3D 数组，循环
    local dims_3d = {2, 2, 2}
    local array_3d = astra.Array(dims_3d, 1, 3, true)
    assert(#array_3d == 2, "3D array should have 2 layers")
    for i = 1, 2 do
        assert(#array_3d[i] == 2, "Each layer should have 2 rows")
        for j = 1, 2 do
            assert(#array_3d[i][j] == 2, "Each row should have 2 elements")
        end
    end
    local expected_values_3d = {1, 2, 3, 1, 2, 3, 1, 2}
    local actual_values_3d = {}
    for i = 1, 2 do
        for j = 1, 2 do
            for k = 1, 2 do
                table.insert(actual_values_3d, array_3d[i][j][k])
            end
        end
    end
    assert(table.concat(actual_values_3d, ",") == table.concat(expected_values_3d, ","), "3D array values should match")

    -- 错误输入
    local invalid_dims = {0, 2}
    local status, err = pcall(astra.Array, invalid_dims, 1, 4, false)
    assert(not status and string.find(err, "All dimensions must be positive integers"), "Invalid dimensions should raise an error")

    local invalid_range = {2, 2}
    local status, err = pcall(astra.Array, invalid_range, 1, 3, false)
    assert(not status and string.find(err, "The range of values is smaller than the number of elements to fill"), "Invalid value range should raise an error")

    print("Array function tests passed.")
end

-- 测试 Matrix 函数
function Test_matrix()
    print("Testing Matrix function...")

    -- 正常情况
    local matrix = astra.Matrix(3, 4, 0)
    assert(#matrix == 3, "Matrix should have 3 rows")
    for i = 1, 3 do
        assert(#matrix[i] == 4, "Each row should have 4 elements")
        for j = 1, 4 do
            assert(matrix[i][j] == 0, "Each element should be initialized to 0")
        end
    end

    -- 错误输入
    local status, err = pcall(astra.Matrix, -1, 4, 0)
    assert(not status and string.find(err, "Rows and columns must be positive integers"), "Invalid rows should raise an error")

    local status, err = pcall(astra.Matrix, 3, -1, 0)
    assert(not status and string.find(err, "Rows and columns must be positive integers"), "Invalid columns should raise an error")

    print("Matrix function tests passed.")
end

-- 测试 DataFrame 函数
function Test_dataframe()
    print("Testing DataFrame function...")

    -- 正常情况
    local columns = {
        A = {1, 2, 3},
        B = {"a", "b", "c"},
        C = {true, false, true}
    }
    local df = astra.DataFrame(columns)
    assert(df.numRows == 3, "DataFrame should have 3 rows")
    assert(#df.A == 3, "Column A should have 3 elements")
    assert(#df.B == 3, "Column B should have 3 elements")
    assert(#df.C == 3, "Column C should have 3 elements")
    assert(tostring(df) == "A\tB\tC\n1\ta\ttrue\n2\tb\tfalse\n3\tc\ttrue", "DataFrame string representation should match")

    -- 不同长度的列
    local invalid_columns = {
        A = {1, 2, 3},
        B = {"a", "b"}
    }
    local status, err = pcall(astra.DataFrame, invalid_columns)
    assert(not status and string.find(err, "All columns must have the same length"), "Columns with different lengths should raise an error")

    -- 错误输入
    local invalid_columns_type = {
        A = {1, 2, 3},
        B = "invalid"
    }
    local status, err = pcall(astra.DataFrame, invalid_columns_type)
    assert(not status and string.find(err, "Column data must be a table"), "Invalid column type should raise an error")

    print("DataFrame function tests passed.")
end

-- 测试 List 函数
function Test_list()
    print("Testing List function...")

    -- 正常情况
    local list = astra.List(1, 2, 3)
    assert(#list == 3, "List should have 3 elements")
    assert(table.concat(list, ",") == "1,2,3", "List elements should match")

    -- 传入表
    local list_from_table = astra.List({1, 2, 3})
    assert(#list_from_table == 3, "List from table should have 3 elements")
    assert(table.concat(list_from_table, ",") == "1,2,3", "List from table elements should match")

    -- 混合输入
    local mixed_list = astra.List(1, {2, 3}, 4)
    assert(#mixed_list == 4, "Mixed input list should have 4 elements")
    assert(table.concat(mixed_list, ",") == "1,2,3,4", "Mixed input list elements should match")

    print("List function tests passed.")
end

-- 测试 Pipe 函数
function Test_pipe()
    print("Testing Pipe function...")

    -- 正常情况
    local result = astra.Pipe(5,
        function(x) return x + 3 end,
        function(x) return x * 2 end,
        function(x) return x - 1 end
    )
    assert(result == 15, "Pipe result should be 15")  -- 更新预期结果为 15

    -- 创建管道对象并逐步调用
    local p = astra.Pipe(5)
    p(function(x) return x + 3 end)
    p(function(x) return x * 2 end)
    p(function(x) return x - 1 end)
    assert(p:get() == 15, "Pipe object result should be 15")  -- 更新预期结果为 15

    -- 错误输入
    local status, err = pcall(astra.Pipe, 5, "not a function")
    assert(not status and string.find(err, "Expected a function"), "Invalid function should raise an error")

    print("Pipe function tests passed.")
end




-- 测试 Summary 函数
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

    local result = astra.Summary(data, false)  -- 不打印输出

    -- 打印实际输出以供调试
    print("Actual output from Summary:")
    for key, value in pairs(result) do
        print(string.format("%s: %f", key, value))
    end

    -- 检查每个预期的统计值
    local success = true
    for key, expected in pairs(expected_output) do
        if not nearly_equal(result[key], expected) then
            print(string.format("Mismatch for %s: expected %f, got %f", key, expected, result[key]))
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
    Test_factor()
    Test_array()
    Test_matrix()
    Test_dataframe()
    Test_list()
    Test_pipe()
end

-- 执行所有测试
run_all_tests()

print("All tests completed.")