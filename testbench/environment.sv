// The environment is a container object simply to hold
// all verification components together. This environment can
// then be reused later and all components in it would be
// automatically connected and available for use

// 环境是一个容器对象，简单地将所有的验证组件放在一起。
// 然后，这个环境可以在以后被重用，所有的组件都会自动连接并可用于使用
// 这个相当于是一个测试框架

class env;

  driver d0;  // Driver handle
  monitor m0;  // Monitor handle
  generator g0;  // Generator Handle
  scoreboard s0;  // Scoreboard handle

  mailbox drv_mbx;  // Connect GEN -> DRV
  mailbox scb_mbx;  // Connect MON -> SCB
  event drv_done;  // Indicates when driver is done

  virtual switch_if vif;  // Virtual interface handle

  function new();  // 环境的构造函数

    // new 与 new() 的效果是一样的，都是默认构造函数。
    // 如果一个 class 没有 new ，那么会默认生成
    d0 = new;
    m0 = new;
    g0 = new;
    s0 = new;
    drv_mbx = new();
    scb_mbx = new();

    d0.drv_mbx = drv_mbx;
    g0.drv_mbx = drv_mbx;
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;

    d0.drv_done = drv_done;
    g0.drv_done = drv_done;
  endfunction

  virtual task run();
    d0.vif = vif;
    m0.vif = vif;

    fork
      d0.run();
      m0.run();
      g0.run();
      s0.run();
    join_any
  endtask
endclass
