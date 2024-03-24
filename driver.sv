// The driver is responsible for driving transactions to the DUT
// All it does is to get a transaction from the mailbox if it is
// available and drive it out into the DUT interface.

// 定义了一个 driver 类

// driver 是用来：驱动 transactions 到 DUT
// 如果 mailbox 是可用的，那么从 mailbox 中得到 transaction ，并将他设置到 DUT interface

class driver;
  virtual switch_if vif;  // 定义了 虚拟接口 的成员变量 vif ，数据类型是 switch_if 
  // 是连接 环境 与 DUT 的桥梁

  event drv_done;  // 声明出了一个事件 drv_done 。允许一个或多个进程等待一个或多个事件的发生。
  // 事件通过 -> 运算符触发。进程可以通过 `@` 等待一个时间的发生 

  mailbox drv_mbx;  // 声明了一个邮箱，邮箱用于：不同进程的通信（管道）

  task run();  // 定义了一个名为 run 的 任务

    $display("T=%0t [Driver] starting ...", $time);
    @(posedge vif.clk);

    // Try to get a new transaction every time and then assign
    // packet contents to the interface. But do this only if the
    // design is ready to accept new transactions
    forever begin
      switch_item item;

      $display("T=%0t [Driver] waiting for item ...", $time);
      drv_mbx.get(item);
      item.print("Driver");
      vif.vld  <= 1;
      vif.addr <= item.addr;
      vif.data <= item.data;

      // When transfer is over, raise the done event
      @(posedge vif.clk);
      vif.vld <= 0;
      ->drv_done;
    end
  endtask
endclass
