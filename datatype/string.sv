/* ---------- ---------- string ---------- ---------- */

module tb;
  // Declare a string variable called "dialog" to store string literals
  // Initialize the variable to "Hello!"
  string dialog = "Hello!";

  initial begin
    // Display the string using %s string format
    $display("%s", dialog);

    // Iterate through the string variable to identify individual characters and print
    // 遍历
    foreach (dialog[i]) begin
      $display("%s", dialog[i]);
    end

  end
endmodule

/* ---------- ---------- verilog 的 string 实现 ---------- ---------- */

// verilog 中的 string 是 数组字符
reg [16*8-1:0] my_string;  // Can store 16 characters

/* ---------- ---------- string 的操作 ---------- ---------- */

module tb;
  string str = "Hello World!";

  initial begin
    string tmp;

    // Print length of string "str"
    $display("str.len() = %0d", str.len());

    // Assign to tmp variable and put char "d" at index 3
    tmp = str;
    tmp.putc(3, "d");
    $display("str.putc(3, d) = %s", tmp);

    // Get the character at index 2
    $display("str.getc(2) = %s (%0d)", str.getc(2), str.getc(2));

    // Convert all characters to lower case
    $display("str.tolower() = %s", str.tolower());

    // Comparison
    tmp = "Hello World!";
    $display("[tmp,str are same] str.compare(tmp) = %0d", str.compare(tmp));
    tmp = "How are you ?";
    $display("[tmp,str are diff] str.compare(tmp) = %0d", str.compare(tmp));

    // Ignore case comparison
    tmp = "hello world!";
    $display("[tmp is in lowercase] str.compare(tmp) = %0d", str.compare(tmp));
    tmp = "Hello World!";
    $display("[tmp,str are same] str.compare(tmp) = %0d", str.compare(tmp));

    // Extract new string from i to j
    $display("str.substr(4,8) = %s", str.substr(4, 8));

  end
endmodule
