#include <cstdio>
#include <iostream>
#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Valu.h"
#include "Valu___024unit.h"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

/**
 * @brief 用于验证
 *
 * @param dut
 * @param sim_time
 */
void check_out_valid(Valu* dut, vluint64_t& sim_time)
{
    static unsigned char in_valid = 0; // in valid from current cycle
    static unsigned char out_valid_exp = 0; // expected out_valid value

    static unsigned char in_valid_d = 0; // 用来记录上一个值，实际上，我们验证的都是上一次循环计算的值

    if (sim_time >= VERIF_START_TIME) {
        // note the order!
        out_valid_exp = in_valid_d;
        in_valid_d = in_valid;
        in_valid = dut->in_valid;
        if (out_valid_exp != dut->out_valid) {
            std::cout << "ERROR: out_valid mismatch, "
                      << "exp: " << (int)(out_valid_exp)
                      << " recv: " << (int)(dut->out_valid)
                      << " simtime: " << sim_time << std::endl;
        }
    }
}

/**
 * @brief 让 alu 随机的有效
 *
 * @param dut
 * @param sim_time
 */
void set_rnd_out_valid(Valu* dut, vluint64_t& sim_time)
{
    if (sim_time >= VERIF_START_TIME) {
        dut->in_valid = rand() % 2;
    }
}

/**
 * @brief 将初始化的东西封装起来，从 [3, 5]
 *
 * @param dut
 * @param sim_time
 */
inline void dut_reset(Valu* dut, vluint64_t& sim_time)
{
    dut->rst = 0;
    if (sim_time >= 3 && sim_time < 6) {
        dut->rst = 1;
        dut->a_in = 0;
        dut->b_in = 0;
        dut->op_in = 0;
        dut->in_valid = 0;
    }
}

int main(int argc, char** argv, char** env)
{
    /*(初始化 程序)*/
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    Valu* dut = new Valu;

    /*(初始化 vcd 记录器)*/
    Verilated::traceEverOn(true); // 启用了波形跟踪模块
    VerilatedVcdC* m_trace = new VerilatedVcdC; // 创建拿了一个 verilated_vcd_c 的模块。用于处理 vcd 文件，这个文件记录了 模拟过程的信号变化
    dut->trace(m_trace, 5); // 调用了 dut 对象的 trace 方法，
    m_trace->open("waveform.vcd"); // m_trace 用于处理 vcd 文件，这里创建了 vcd 文件

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->clk ^= 1;

        dut->eval(); // eval() 下面的东西，在下一个 while 循环才会被引用

        if (dut->clk == 1) {
            dut->in_valid = 0;
            posedge_cnt++;
            set_rnd_out_valid(dut, sim_time);
            check_out_valid(dut, sim_time);
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
