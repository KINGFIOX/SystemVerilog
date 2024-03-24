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
