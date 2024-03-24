// design 设计文件，硬件设计的实现
module switch #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16,
    parameter ADDR_DIV   = 8'h3F
) (
    input clk,
    input rstn,  // 重置信号，低电平有效
    input vld,

    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data,

    output reg [ADDR_WIDTH-1:0] addr_a,
    output reg [DATA_WIDTH-1:0] data_a,

    output reg [ADDR_WIDTH-1:0] addr_b,
    output reg [DATA_WIDTH-1:0] data_b
);

  always @(posedge clk) begin
    if (!rstn) begin
      addr_a <= 0;
      data_a <= 0;
      addr_b <= 0;
      data_b <= 0;
    end else begin
      if (vld) begin  // 当 vld 为高电平的时候才会进行设置

        if (addr >= 0 & addr <= ADDR_DIV) begin
          addr_a <= addr;  // 当地址位于 0~ADDR_DIV 之间的时候，保存到 a 区域
          data_a <= data;
          addr_b <= 0;
          data_b <= 0;
        end else begin
          addr_a <= 0;
          data_a <= 0;
          addr_b <= addr;
          data_b <= data;
        end
      end
    end
  end
endmodule
