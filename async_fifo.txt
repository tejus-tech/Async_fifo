module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter PTR_WIDTH = 4  
)(
    input  wire                  wr_clk,
    input  wire                  wr_rst,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,

    input  wire                  rd_clk,
    input  wire                  rd_rst,
    input  wire                  rd_en,
    output reg [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    localparam DEPTH = 16;

    // Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write pointer
    reg [PTR_WIDTH:0] wr_ptr_bin = 0;
    reg [PTR_WIDTH:0] wr_ptr_gray = 0;
    reg [PTR_WIDTH:0] wr_ptr_gray_sync1 = 0, wr_ptr_gray_sync2 = 0;

    // Read pointer
    reg [PTR_WIDTH:0] rd_ptr_bin = 0;
    reg [PTR_WIDTH:0] rd_ptr_gray = 0;
    reg [PTR_WIDTH:0] rd_ptr_gray_sync1 = 0, rd_ptr_gray_sync2 = 0;

    wire [PTR_WIDTH-1:0] wr_addr = wr_ptr_bin[PTR_WIDTH-1:0];
    wire [PTR_WIDTH-1:0] rd_addr = rd_ptr_bin[PTR_WIDTH-1:0];

    // Write logic
    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && ~full) begin
            mem[wr_addr] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
        end
    end

    // Read logic
    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_ptr_bin <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && ~empty) begin
            rd_data <= mem[rd_addr];
            rd_ptr_bin <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // Synchronize pointers
    always @(posedge wr_clk) begin
        rd_ptr_gray_sync1 <= rd_ptr_gray;
        rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end

    always @(posedge rd_clk) begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end

    // Gray to binary
    function [PTR_WIDTH:0] gray_to_bin;
        input [PTR_WIDTH:0] gray;
        integer i;
        begin
            gray_to_bin[PTR_WIDTH] = gray[PTR_WIDTH];
            for (i = PTR_WIDTH-1; i >= 0; i = i - 1)
                gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
        end
    endfunction

    wire [PTR_WIDTH:0] rd_ptr_bin_sync = gray_to_bin(rd_ptr_gray_sync2);
    wire [PTR_WIDTH:0] wr_ptr_bin_sync = gray_to_bin(wr_ptr_gray_sync2);

    // Full and Empty 
  assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync2[PTR_WIDTH:PTR_WIDTH-1], rd_ptr_gray_sync2[PTR_WIDTH-2:0]});
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

endmodule
