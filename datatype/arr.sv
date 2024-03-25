module tb;
  // The following two representations of fixed arrays are the same
  // myFIFO and urFIFO have 8 locations where each location can hold an integer value
  // 0,1 | 0,2 | 0,3 | ... | 0,7
  // 这两种数组是等价的
  int myFIFO [0:7];
  int urFIFO [  8];

  // Multi-dimensional arrays
  // 0,0 | 0,1 | 0,2
  // 1,0 | 1,1 | 1,2
  int myArray[  2] [3];

  initial begin

    myFIFO[5]     = 32'hface_cafe;  // Assign value to location 5 in 1D array
    // 不懂这个 32'hface_cafe 是什么意思

    myArray[1][1] = 7;  // Assign to location 1,1 in 2D array

    // Iterate through each element in the array
    foreach (myFIFO[i]) $display("myFIFO[%0d] = 0x%0h", i, myFIFO[i]);

    // Iterate through each element in the multidimensional array
    foreach (myArray[i])
    foreach (myArray[i][j]) $display("myArray[%0d][%0d] = %0d", i, j, myArray[i][j]);

  end
endmodule

/* ---------- ---------- 数组最短是 2 ---------- ---------- */

enum bit [0:0] {
  RED,
  YELLOW,
  GREEN
} light_6;  // Error: minimum 2 bits are required

/* ---------- ---------- static array ---------- ---------- */

module tb;
  bit [7:0] m_data;  // A vector or 1D packed array

  initial begin
    // 1. Assign a value to the vector
    m_data = 8'hA2;

    // 2. Iterate through each bit of the vector and print value
    for (int i = 0; i < $size(m_data); i++) begin
      $display("m_data[%0d] = %b", i, m_data[i]);
    end
  end

  /* ---------- packed 和 unpacked ---------- */
  bit [2:0][7:0] m_data;  // Packed
  bit [15:0] m_mem[10:0];  // Unpacked

endmodule

/* ---------- ---------- dynamic array 及其相关操作 ---------- ---------- */

module tb;
  // Create a dynamic array that can hold elements of type int
  int array[];

  initial begin
    // Create a size for the dynamic array -> size here is 5
    // so that it can hold 5 values
    array = new[5];

    // Initialize the array with five values
    array = '{31, 67, 10, 4, 99};

    // Loop through the array and print their values
    foreach (array[i]) $display("array[%0d] = %0d", i, array[i]);
  end
endmodule

/* ---------- ---------- 队列 ---------- ---------- */

module tt;
  int m_queue[$];  // Unbound queue, no size
  m_queue.push_back(
      23
  );  // Push into the queue
  int data = m_queue.pop_front();  // Pop from the queue
endmodule

/* ---------- ---------- unpacked array ---------- ---------- */

module tb;
  bit [3:0][7:0] m_data;  // A MDA, 4 bytes

  initial begin
    // 1. Assign a value to the MDA
    m_data = 32'hface_cafe;

    $display("m_data = 0x%0h", m_data);

    // 2. Iterate through each segment of the MDA and print value
    for (int i = 0; i < $size(m_data); i++) begin
      $display("m_data[%0d] = %b (0x%0h)", i, m_data[i], m_data[i]);
    end
    // m_data = 0xfacecafe
    // m_data[0] = 11111110 (0xfe)
    // m_data[1] = 11001010 (0xca)
    // m_data[2] = 11001110 (0xce)
    // m_data[3] = 11111010 (0xfa)
  end
endmodule


/* ---------- ---------- 关联数组 ---------- ---------- */

module tb;

  int    array1 [int];    // An integer array with integer index
  int    array2 [string];   // An integer array with string index
  string  array3 [string];   // A string array with string index

  initial begin
    // Initialize each dynamic array with some values
    array1 = '{1 : 22, 6 : 34};

    array2 = '{"Ross" : 100, "Joey" : 60};

    array3 = '{"Apples" : "Oranges", "Pears" : "44"};

    // Print each array
    $display("array1 = %p", array1);
    $display("array2 = %p", array2);
    $display("array3 = %p", array3);
    // ncsim> run
    // array1 = '{1:22, 6:34}
    // array2 = '{"Joey":60, "Ross":100}
    // array3 = '{"Apples":"Oranges", "Pears":"44"}
    // ncsim: *W,RNQUIE: Simulation is complete.
  end
endmodule

/* ---------- ---------- 操作数组 ---------- ---------- */

module tb;
  int array[9] = '{4, 7, 2, 5, 7, 1, 6, 3, 1};
  int res  [$];

  initial begin
    res = array.find(x) with (x > 3);
    $display("find(x) : %p", res);

    res = array.find_index with (item == 4);
    $display("find_index : res[%0d] = 4", res[0]);

    res = array.find_first with (item < 5 & item >= 3);
    $display("find_first : %p", res);

    res = array.find_first_index(x) with (x > 5);
    $display("find_first_index: %p", res);

    res = array.find_last with (item <= 7 & item > 3);
    $display("find_last : %p", res);

    res = array.find_last_index(x) with (x < 3);
    $display("find_last_index : %p", res);
  end
endmodule

/* */

class Register;
  string name;
  rand bit [3:0] rank;
  rand bit [3:0] pages;

  function new(string name);
    this.name = name;
  endfunction

  function void print();
    $display("name=%s rank=%0d pages=%0d", name, rank, pages);
  endfunction

endclass

/* ---------- ---------- sort with ---------- ---------- */

class Register;
  string name;
  rand bit [3:0] rank;
  rand bit [3:0] pages;

  function new(string name);
    this.name = name;
  endfunction

  function void print();
    $display("name=%s rank=%0d pages=%0d", name, rank, pages);
  endfunction

endclass

module tb;
  Register rt[4];
  string name_arr[4] = '{"alexa", "siri", "google home", "cortana"};

  initial begin
    $display("-------- Initial Values --------");
    foreach (rt[i]) begin
      rt[i] = new(name_arr[i]);
      rt[i].randomize();
      rt[i].print();
    end
    // -------- Initial Values --------
    // name=alexa rank=12 pages=13
    // name=siri rank=6 pages=12
    // name=google home rank=12 pages=13
    // name=cortana rank=7 pages=11

    $display("--------- Sort by name ------------");
    rt.sort(x) with (x.name);
    foreach (rt[i]) rt[i].print();
    // --------- Sort by name ------------
    // name=alexa rank=12 pages=13
    // name=cortana rank=7 pages=11
    // name=google home rank=12 pages=13
    // name=siri rank=6 pages=12

    $display("--------- Sort by rank, pages -----------");
    rt.sort(x) with ({x.rank, x.pages});
    foreach (rt[i]) rt[i].print();
    // --------- Sort by rank, pages -----------
    // name=siri rank=6 pages=12
    // name=cortana rank=7 pages=11
    // name=alexa rank=12 pages=13
    // name=google home rank=12 pages=13

  end
endmodule
