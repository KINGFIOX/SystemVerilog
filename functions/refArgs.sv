// Use "ref" to make this function accept arguments by reference
// Also make the function automatic
function automatic int fn(ref int a);

  // Any change to this local variable will be
  // reflected in the main variable declared within the
  // initial block
  a = a + 5;

  // Return some computed value
  return a * 10;
endfunction
