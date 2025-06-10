module async_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter PTR_WIDTH = 4;

    reg wr_clk = 0, rd_clk = 0;
    reg wr_rst = 1, rd_rst = 1;
    reg wr_en = 0, rd_en = 0;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) uut (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock generation
    always #5  wr_clk = ~wr_clk; // 100MHz
    always #7  rd_clk = ~rd_clk; // ~71MHz 

    // Test 
    initial begin
        $dumpfile("async_fifo_tb.vcd");
        $dumpvars(0, async_fifo_tb);

        // Reset
        #20 wr_rst = 0; rd_rst = 0;

        // Write 
        repeat(10) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en <= 1;
                wr_data <= $random;
            end else begin
                wr_en <= 0;
            end
        end
        wr_en <= 0;

        // Read 
        #50;
        repeat(10) begin
            @(posedge rd_clk);
            if (!empty) rd_en <= 1;
            else rd_en <= 0;
        end
        rd_en <= 0;

        #100;
        $finish;
    end

endmodule
