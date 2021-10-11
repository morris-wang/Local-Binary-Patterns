`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   		clk;
input   		reset;
output reg [13:0] 	gray_addr;
output reg gray_req;
input   		gray_ready;
input   [7:0] 	gray_data;
output reg [13:0] 	lbp_addr;
output  reg	lbp_valid;
output reg [7:0] 	lbp_data;
output reg finish;

reg [7:0] gc,g0,g1,g2,g3,g4,g5,g6,g7;
reg [3:0] count;
reg [13:0] nxt_lbp_addr,nxt_gray_addr;
reg [3:0] chg;
reg ctrl_lbp_data;

//====================================================================
always @(posedge clk ) begin //gray_req
	 if (gray_ready)
		gray_req <= 1;
end

always @(posedge clk or posedge reset) begin //count
	if(reset)
		count <= 0;
	else if (gray_req) 
		count <= chg;
end

always @(*) begin//chg
	case(count)
		4'd0: chg=4'd1;
		4'd1: chg=4'd2;
		4'd2: chg=4'd3;
		4'd3: chg=4'd4;
		4'd4: chg=4'd5;
		4'd5: chg=4'd6;
		4'd6: chg=4'd7;
		4'd7: chg=4'd8;
		4'd8: chg=4'd0;
		default: chg=0;
	endcase
end

always @(posedge clk or posedge reset) begin //gray_addr
	if(reset)
		gray_addr <= 0;
	else if(gray_req)
		gray_addr <=  nxt_gray_addr;
end

always @(*) begin
	case(count)
		4'd0: nxt_gray_addr=gray_addr+8'd128;
		4'd1: nxt_gray_addr=gray_addr+8'd128;
		4'd2: nxt_gray_addr=gray_addr-8'd255;
		4'd3: nxt_gray_addr=gray_addr+8'd128;
		4'd4: nxt_gray_addr=gray_addr+8'd128;
		4'd5: nxt_gray_addr=gray_addr-8'd255;
		4'd6: nxt_gray_addr=gray_addr+8'd128;
		4'd7: nxt_gray_addr=gray_addr+8'd128;
		4'd8: nxt_gray_addr=gray_addr-8'd255;
	endcase
end

always @(posedge clk) begin//nine
	if (count%3==0) begin
		g2 <= gray_data;
		g1 <= g2;
		g0 <= g1;
	end
	else if (count%3==1) begin
		g4 <= gray_data;
		gc <= g4;
		g3 <= gc;
	end
	else if (count%3==2) begin
		g7 <= gray_data;
		g6 <= g7;
		g5 <= g6;
	end
end

always @(posedge clk) begin //lbp_data[0]
	lbp_data[0]<=(g0<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[1] 
	lbp_data[1]<=(g1<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[2]
	lbp_data[2]<=(g2<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[3]
	lbp_data[3]<=(g3<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[4]
	lbp_data[4]<=(g4<gc)? 0:1;
end

always @(posedge clk) begin //lbp_data[5]
	lbp_data[5]<=(g5<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[6]
	lbp_data[6]<=(g6<gc)?0:1;
end

always @(posedge clk) begin //lbp_data[7]
	lbp_data[7]<=(g7<gc)?0:1;
end

always @(posedge clk or posedge reset) begin//lbp_addr
	if (reset) 
		lbp_addr <= 129;
	else if(ctrl_lbp_data && count%3==1)
		lbp_addr <= lbp_addr + 1;
end

always @(posedge clk or posedge reset) begin //lbp_valid
	if(reset)
		lbp_valid <=0;
	else if(count%3==0 && lbp_addr%128!=127 && lbp_addr%128!=0)
		lbp_valid <= 1;
	else 
		lbp_valid <=0;
end

always @(posedge clk or posedge reset) begin //ctrl_lbp_data
	if(reset)
		ctrl_lbp_data <=0;
	else if(count>=8)
		ctrl_lbp_data <=1;
end

always @(posedge clk or posedge reset) begin //finish
	if(reset)
		finish <=0;
	else if(lbp_addr>=16254&&lbp_valid)
		finish <=1;
end






//====================================================================

endmodule
