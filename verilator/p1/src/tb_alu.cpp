#include <iostream>
#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Valu.h"
#include "Valu___024unit.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env)
{
    Valu* dut = new Valu;

    Verilated::traceEverOn(true); // 启用了波形跟踪模块
    VerilatedVcdC* m_trace = new VerilatedVcdC; // 创建拿了一个 verilated_vcd_c 的模块。用于处理 vcd 文件，这个文件记录了 模拟过程的信号变化
    dut->trace(m_trace, 5); // 调用了 dut 对象的 trace 方法，
    m_trace->open("waveform.vcd"); // m_trace 用于处理 vcd 文件，这里创建了 vcd 文件

    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1; // 时钟翻转
        dut->eval(); // 更新 module 的状态
        m_trace->dump(sim_time); // 将当前的状态写入到 vcd 文件
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
