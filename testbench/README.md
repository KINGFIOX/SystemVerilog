# README

这个仓库是用来学习 SystemVerilog 的。

## driver 与 monitor 的 mailbox 交互

### driver

```verilog
// The driver is responsible for driving transactions to the DUT
// All it does is to get a transaction from the mailbox if it is
// available and drive it out into the DUT interface.

// 定义了一个 driver 类

// driver 是用来：驱动 transactions 到 DUT
// 如果 mailbox 是可用的，那么从 mailbox 中得到 transaction ，并将他设置到 DUT interface

class driver;
  virtual switch_if vif;  // 定义了 虚拟接口 的成员变量 vif ，数据类型是 switch_if
  // 有两种 virtual ： 1. 虚拟接口（这里应该就是虚拟接口） 2. 虚拟方法

  // 是连接 环境 与 DUT 的桥梁。 driver 能直接与 DUT 交互

  event drv_done;  // 声明出了一个事件 drv_done 。允许一个或多个进程等待一个或多个事件的发生。
  // 事件通过 -> 运算符触发。进程可以通过 `@` 等待一个时间的发生

  mailbox drv_mbx;  // 声明了一个邮箱，邮箱用于：不同进程的通信（管道）

  task run();  // 定义了一个名为 run 的 任务 $display("T=%0t [Driver] starting ...", $time);  // 打印
    @(posedge vif.clk);  // 暂停当前的进程，但是不会阻塞整个仿真环境的进行
    // driver 确保在正确的时间点驱动信号，保持与 DUT 的同步

    // Try to get a new transaction every time and then assign
    // packet contents to the interface. But do this only if the
    // design is ready to accept new transactions
    forever begin

      switch_item item;

      $display("T=%0t [Driver] waiting for item ...", $time);
      drv_mbx.get(item);  // 从邮箱中获取一个 item

      item.print("Driver");

      // 使用对象
      vif.vld  <= 1;
      vif.addr <= item.addr;
      vif.data <= item.data;

      // When transfer is over, raise the done event
      @(posedge vif.clk);

      vif.vld <= 0;
      ->drv_done;  // 事件可以通过 -> 触发

    end

  endtask
endclass
```

### monitor

监视 DUT 的输出信号和行为

```verilog
// The monitor has a virtual interface handle with which
// it can monitor the events happening on the interface.
// It sees new transactions and then captures information
// into a packet and sends it to the scoreboard
// using another mailbox.

// 监视器有一个虚拟接口句柄，可以监视接口上发生的事件。
// 它看到新的事务，然后捕获信息到一个数据包，并使用另一个邮箱将其发送到记分板。

class monitor;
  virtual switch_if vif;
  mailbox scb_mbx;
  semaphore sema4;  // 信号灯

  function new();
    sema4 = new(1);
  endfunction

  task run();
    $display("T=%0t [Monitor] starting ...", $time);

    // To get a pipeline effect of transfers, fork two threads
    // where each thread uses a semaphore for the address phase

    fork  // fork 和 join 用于创建线程
      sample_port("Thread0");
      sample_port("Thread1");
    join

  endtask

  task sample_port(string tag = "");
    // This task monitors the interface for a complete
    // transaction and pushes into the mailbox when the
    // transaction is complete
    forever begin
      @(posedge vif.clk);
      if (vif.rstn & vif.vld) begin
        switch_item item = new;
        sema4.get();  // P 操作
        item.addr = vif.addr;
        item.data = vif.data;
        $display("T=%0t [Monitor] %s First part over", $time, tag);
        @(posedge vif.clk);
        sema4.put();  // V 操作
        item.addr_a = vif.addr_a;
        item.data_a = vif.data_a;
        item.addr_b = vif.addr_b;
        item.data_b = vif.data_b;
        $display("T=%0t [Monitor] %s Second part over", $time, tag);
        scb_mbx.put(item);  // 发邮箱给
        item.print({"Monitor_", tag});
      end
    end
  endtask
endclass
```
