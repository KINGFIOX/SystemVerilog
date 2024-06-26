module tb;

  // Create an event variable that processes can use to trigger and wait
  event event_a;

  // Thread1: Triggers the event using "->" operator
  initial begin
    #20->event_a;  // 触发事件
    $display("[%0t] Thread1: triggered event_a", $time);
  end

  // Thread2: Waits for the event using "@" operator
  initial begin
    $display("[%0t] Thread2: waiting for trigger ", $time);
    @(event_a);  // 等待事件
    $display("[%0t] Thread2: received event_a trigger ", $time);
  end

  // Thread3: Waits for the event using ".triggered"
  initial begin
    $display("[%0t] Thread3: waiting for trigger ", $time);
    wait (event_a.triggered);
    $display("[%0t] Thread3: received event_a trigger", $time);
  end
endmodule
