// Verilator Example
// Norbertas Kremeris 2021
#include "Valu.h"
#include "Valu___024unit.h"
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

/**
 * @brief 只有 driver 才包含有 DUT
 *
 */

// 定义了数据交换的 transaction
// ALU input interface transaction item class
class AluInTx {
public:
    // 我们没有 设置 in_valid ，我们认为：只要发生了 transaction 那么就是 valid=1
    uint32_t a;
    uint32_t b;
    enum Operation {
        add = Valu___024unit::operation_t::add,
        sub = Valu___024unit::operation_t::sub,
        nop = Valu___024unit::operation_t::nop
    } op;
};

// ALU random transaction generator
// This will allocate memory for an AluInTx
// transaction item, randomise the data, and
// return a pointer to the transaction item object
AluInTx* rndAluInTx()
{
    // 20% chance of generating a transaction
    if (rand() % 5 == 0) {
        AluInTx* tx = new AluInTx();
        tx->op = AluInTx::Operation(rand() % 3);
        tx->a = rand() % 11 + 10;
        tx->b = random() % 6;
        return tx;
    } else {
        return NULL;
    }
}

// ALU input interface driver
// 这个 driver 也就是做了一个事情：给 dut 的端口赋值
class AluInDrv {
private:
    Valu* dut;

public:
    AluInDrv(Valu* dut)
    {
        this->dut = dut;
    }

    void drive(AluInTx* tx)
    {
        // we always start with in_valid set to 0, and set it to
        // 1 later only if necessary
        dut->in_valid = 0;

        // Don't drive anything if a transaction item doesn't exist
        if (tx != NULL) {
            if (tx->op != AluInTx::nop) {
                // If the operation is not a NOP, we drive it onto the
                // input interface pins
                dut->in_valid = 1;
                dut->op_in = tx->op;
                dut->a_in = tx->a;
                dut->b_in = tx->b;
            }
            // Release the memory by deleting the tx item
            // after it has been consumed
            delete tx;
        }
    }
};

// ALU output interface transaction item class
/**
 * @brief 因为我们只有一个输出
 *
 */
class AluOutTx {
public:
    uint32_t out;
};

// ALU scoreboard
/**
 * @brief scoreboard 负责计算
 *
 */
class AluScb {
private:
    std::deque<AluInTx*> in_q;

public:
    // Input interface monitor port
    /**
     * @brief 向 DUT 写入 transaction
     *
     * @param tx
     */
    void writeIn(AluInTx* tx)
    {
        // Push the received transaction item into a queue for later
        in_q.push_back(tx);
    }

    // Output interface monitor port
    // output
    void writeOut(AluOutTx* tx)
    {
        // We should never get any data from the output interface
        // before an input gets driven to the input interface
        // 如果 dut 不输出，那么肯定 writeOut 一定不会被调用
        if (in_q.empty()) {
            std::cout << "Fatal Error in AluScb: empty AluInTx queue" << std::endl;
            exit(1);
        }

        // Grab the transaction item from the front of the input item queue
        AluInTx* in = in_q.front();
        in_q.pop_front();

        switch (in->op) {
        // A valid signal should not be created at the output when there is no operation,
        // so we should never get a transaction item where the operation is NOP
        case AluInTx::nop:
            std::cout << "Fatal error in AluScb, received NOP on input" << std::endl;
            exit(1);
            break;

        // Received transaction is add
        case AluInTx::add:
            if (in->a + in->b != tx->out) {
                std::cout << std::endl;
                std::cout << "AluScb: add mismatch" << std::endl;
                std::cout << "  Expected: " << in->a + in->b
                          << "  Actual: " << tx->out << std::endl;
                std::cout << "  Simtime: " << sim_time << std::endl;
            }
            break;

        // Received transaction is sub
        case AluInTx::sub:
            if (in->a - in->b != tx->out) {
                std::cout << std::endl;
                std::cout << "AluScb: sub mismatch" << std::endl;
                std::cout << "  Expected: " << in->a - in->b
                          << "  Actual: " << tx->out << std::endl;
                std::cout << "  Simtime: " << sim_time << std::endl;
            }
            break;
        }
        // As the transaction items were allocated on the heap, it's important
        // to free the memory after they have been used
        delete in;
        delete tx;
    }
};

// ALU input interface monitor
/**
 * @brief 暗中观察，input 接口上发生的变化，就是这个上面的变化生命周期要比 transaction gen 长
 *
 */
class AluInMon {
private:
    Valu* dut;
    AluScb* scb;

public:
    AluInMon(Valu* dut, AluScb* scb)
    {
        this->dut = dut;
        this->scb = scb;
    }

    void monitor()
    {
        if (dut->in_valid == 1) {
            // If there is valid data at the input interface,
            // create a new AluInTx transaction item and populate
            // it with data observed at the interface pins
            AluInTx* tx = new AluInTx();
            tx->op = AluInTx::Operation(dut->op_in);
            tx->a = dut->a_in;
            tx->b = dut->b_in;

            // then pass the transaction item to the scoreboard
            scb->writeIn(tx);
        }
    }
};

// ALU output interface monitor
/**
 * @brief
 *
 */
class AluOutMon {
private:
    Valu* dut;
    AluScb* scb;

public:
    AluOutMon(Valu* dut, AluScb* scb)
    {
        this->dut = dut;
        this->scb = scb;
    }

    void monitor()
    {
        if (dut->out_valid == 1) {
            // If there is valid data at the output interface,
            // create a new AluOutTx transaction item and populate
            // it with result observed at the interface pins
            AluOutTx* tx = new AluOutTx();
            tx->out = dut->out;

            // then pass the transaction item to the scoreboard
            scb->writeOut(tx);
        }
    }
};

void dut_reset(Valu* dut, vluint64_t& sim_time)
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
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    Valu* dut = new Valu;

    // 注册 vcd
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    AluInTx* tx;

    // Here we create the driver, scoreboard, input and output monitor blocks
    // monitor 给 scb 写入，并不是传入一个 transaction 就写一次。而是 monitor 一次就
    // 注册
    AluInDrv* drv = new AluInDrv(dut);
    AluScb* scb = new AluScb();
    AluInMon* inMon = new AluInMon(dut, scb);
    AluOutMon* outMon = new AluOutMon(dut, scb);

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->clk ^= 1;
        dut->eval();

        // Do all the driving/monitoring on a positive edge
        if (dut->clk == 1) {

            if (sim_time >= VERIF_START_TIME) {
                // Generate a randomised transaction item of type AluInTx
                tx = rndAluInTx();

                // Pass the transaction item to the ALU input interface driver,
                // which drives the input interface based on the info in the
                // transaction item
                drv->drive(tx);

                // Monitor the input interface
                inMon->monitor();

                // Monitor the output interface
                // out monitor 写到 scoreboard 里面
                outMon->monitor();
            }
        }
        // end of positive edge processing

        // 写入日志
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    delete outMon;
    delete inMon;
    delete scb;
    delete drv;
    exit(EXIT_SUCCESS);
}
