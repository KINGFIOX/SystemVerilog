# README

这个仓库主要就是用来学习： SystemVerilog 的

## verilator 对 SystemVerilog 的支持

Verilator 是一个高性能的 Verilog 和部分 SystemVerilog 仿真器，它将 Verilog/SystemVerilog 代码转换成优化的 C++/SystemC 代码。
由于 Verilator 的核心目标是提供快速的仿真速度，它并不全面支持 SystemVerilog 的全部特性。
截至我最后更新的信息（2023 年 4 月），以下是一些 Verilator 不支持或部分支持的 SystemVerilog 特性：

### 1. **完全不支持的特性**

- **类和对象**：Verilator 不支持 SystemVerilog 的类（`class`）和面向对象编程特性。这意味着 UVM 等基于类的验证方法无法直接在 Verilator 中使用。
- **约束随机化**：SystemVerilog 的约束随机化（constraint-based randomization）是用于生成随机测试场景的重要特性，但 Verilator 不支持这一特性。
- **断言**：虽然断言（`assert`）在硬件验证中非常有用，但 Verilator 对 SystemVerilog 的断言支持有限。
- **接口类**：Verilator 不支持 SystemVerilog 的接口类（`interface class`）。
- **程序块**：SystemVerilog 的程序块（`program` block）也不被 Verilator 支持。

### 2. **部分支持的特性**

- **接口（`interface`）**：Verilator 支持基础的接口定义，但对于一些高级功能，如模态接口和接口继承，支持可能有限。
- **生成构造**（`generate` constructs）：Verilator 支持基本的生成构造，但在使用时可能会遇到一些限制。
- **唯一和优先逻辑**（`unique` and `priority`）：这些关键字用于控制条件语句的执行路径，Verilator 对它们的支持可能有所限制。
- **时钟域交叉（CDC）分析特性**：虽然 Verilator 可以用于某些 CDC 分析，但它主要是一个逻辑级仿真器，可能不支持所有 CDC 分析相关特性。

### 使用注意事项

当使用 Verilator 进行 SystemVerilog 代码的仿真时，建议查阅 Verilator 的官方文档和发布说明，了解最新的特性支持情况。
针对不支持的特性，可能需要考虑替代的实现方法或选择其他工具进行验证。

虽然 Verilator 的 SystemVerilog 支持并不全面，但其快速的仿真性能和开源的优势使其在许多场合仍然是一个非常有用的工具。
对于不需要复杂验证方法学（如 UVM）或高级 SystemVerilog 特性的项目，Verilator 可以提供有效的仿真解决方案。
