# README - tasks

task 如果不进行设置的话，默认是 static 的，
不是 static 的，就是 automatic 的，就是 global 的（定义在 所有 modules 之外的 task 就是 global 的）

### static

```systemverilog
module tb;

  initial display();  // 1
  initial display();  // 2
  initial display();  // 3
  initial display();  // 4

  // This is a static task
  task display();
    integer i = 0;
    i = i + 1;
    $display("i=%0d", i);
  endtask
endmodule
```

### automatic

```verilog
module tb;

  initial display();
  initial display();
  initial display();
  initial display();

  // Note that the task is now automatic
  task automatic display();
    integer i = 0;
    i = i + 1;
    $display("i=%0d", i);
    // i=1
    // i=1
    // i=1
    // i=1
  endtask
endmodule
```

### 模块内的 task

```verilog
module tb;
	des u0();
	initial begin
		u0.display();  // Task is not visible in the module 'tb'
	end
endmodule

module des;
	initial begin
		display(); 	// Task definition is local to the module
	end

	task display();
		$display("Hello World");
	endtask
endmodule
```

### disable a task

```verilog
module tb;

  initial display();

  initial begin
  	// After 50 time units, disable a particular named
  	// block T_DISPLAY inside the task called 'display'
    #50 disable display.T_DISPLAY;
  end

  task display();
    begin : T_DISPLAY
      $display("[%0t] T_Task started", $time); // [0] T_Task started
      #100;
      $display("[%0t] T_Task ended", $time);
    end

    begin : S_DISPLAY
      #10;
      $display("[%0t] S_Task started", $time);  // [60] S_Task started
      #20;
      $display("[%0t] S_Task ended", $time);  // [80] S_Task ended
    end
  endtask
endmodule
```
