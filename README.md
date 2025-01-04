# Astra - 统计计算库
## 简介

Astra 是一个用于 Lua 的统计计算库，提供了多种常见的统计函数，如均值、中位数、标准差、方差、分位数等。该库旨在为开发者提供简单易用的接口，方便在 Lua 项目中进行数据分析和统计计算。

## 特性

- **丰富的统计函数**：支持均值、中位数、标准差、方差、分位数、绝对中位差等常用统计指标。
- **数据过滤**：自动过滤非数值数据，确保计算结果的准确性。
- **易于扩展**：模块化设计，便于添加新的统计函数或自定义计算逻辑。
- **轻量级**：不依赖外部库，适合嵌入式系统和资源受限的环境。
- **兼容性强**：支持 Lua 5.3 及以上版本。

## 安装

### 使用 LuaRocks 安装

Astra 已发布到 [LuaRocks](https://luarocks.org/)，你可以通过以下命令轻松安装：

```bash
luarocks install astra
```

从源码安装
如果你希望通过源码安装 Astra，可以按照以下步骤操作：
 Astra 仅依赖于 Lua 标准库，因此不需要额外的依赖项。
```bash
git clone https://github.com/Astra-Zhi/astra.git
cd astra
```

构建并安装： 使用 luarocks 构建并安装模块：
```bash
luarocks make astra-1.0.0-dev-1.rockspec
```

**使用方法**

在 Lua 脚本中，可以通过 require 函数加载 Astra 模块：


## 示例代码
```Lua
local astra = require("astra")

-- 计算均值
local data = {1, 2, 3, 4, 5}
local mean = astra.Mean(data)
print("Mean:", mean)  -- 输出: Mean: 3
-- 计算中位数
local median = astra.Median(data)
print("Median:", median)  -- 输出: Median: 3
-- 计算标准差
local sd = astra.Sd(data)
print("Standard Deviation:", sd)  -- 输出: Standard Deviation: 1.4142135623731
-- 计算方差
local var = astra.Var(data)
print("Variance:", var)  -- 输出: Variance: 2
-- 计算分位数
local quantiles = astra.Quantile(data, 0.3, 0.84)
print("Quantile (0.3, 0.84):", table.unpack(quantiles))  -- 输出: Quantile (0.3, 0.84): 2.2 4.7
-- 计算绝对中位差
local mad = astra.Mad(data)
print("MAD:", mad)  -- 输出: MAD: 1.2
-- 计算值域
local min, max = astra.Range(data)
print("Range:", min, max)  -- 输出: Range: 1 5
-- 求和
local sum = astra.Sum(data)
print("Sum:", sum)  -- 输出: Sum: 15
-- 滞后差分
local diff = astra.Diff(data, 1)
print("Diff (lag=1):", table.concat(diff, ", "))  -- 输出: Diff (lag=1): 1, 1, 1, 1
-- 求最小值
local min = astra.Min(data)
print("Min:", min)  -- 输出: Min: 1
-- 求最大值
local max = astra.Max(data)
print("Max:", max)  -- 输出: Max: 5
-- 数据标准化
local scaled = astra.Scale(data)
print("Scaled:", table.concat(scaled, ", "))  -- 输出: Scaled: -1.4142135623731, -0.70710678118655, 0, 0.70710678118655, 1.4142135623731
```



```Lua
local astra = require("astra")

local data = {1, 2, 3, 4, 5}

print("Mean:", astra.Mean(data))
print("Median:", astra.Median(data))
print("Standard Deviation:", astra.Sd(data))
print("Variance:", astra.Var(data))
print("MAD:", astra.Mad(data))
print("Quantile (0.3, 0.84):", table.unpack(astra.Quantile(data, 0.3, 0.84)))
print("Range:", astra.Range(data))
print("Sum:", astra.Sum(data))
print("Diff (lag=1):", table.concat(astra.Diff(data, 1), ", "))
print("Min:", astra.Min(data))
print("Max:", astra.Max(data))
print("Scaled:", table.concat(astra.Scale(data), ", "))
```

## 贡献
我们欢迎任何形式的贡献！如果你发现了 bug 或有改进建议，请提交 Issue 或 Pull Request。在提交 PR 之前，请确保你已经阅读并遵守 贡献指南。

## 许可证
Astra 采用 MIT 许可证 发布。详情请参阅 LICENSE 文件。

----
感谢你使用 Astra！如果你有任何问题或建议，请随时联系我们。