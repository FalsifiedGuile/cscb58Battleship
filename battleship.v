module battleship
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,
		HEX0//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [14:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [6:0] HEX0;
	wire resetn;
	assign resetn = KEY[0];
	reg [4:0] count;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	reg [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x + xCount),
			.y(y + yCount),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
			
			
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "test.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
		
		wire win, ld_ac, ld_bs, ld_sub, ld_cru, ld_des, data_processed, guess;
		wire [6:0] ac, bs, sub, cru, des;
		wire [6:0] conv_coor;
		wire [1:0] xCount;
		wire [1:0] yCount;
		wire correct_guess;
	//converts user input SW[7:4] x cord and SW[3:0] y cord to appropriate vga coordinates
	coordinateConverter c1(.user_x(SW[7:4]), .user_y(SW[3:0]), .outputConv(conv_coor), .outputX(x), .outputY(y));
	// The unfully implemented fsm controller
	 control counters(
     .clk(CLOCK_50),
     .go(~KEY[1]),
     .win(win),
     .data_processed(data_processed),
	 .conv_coor(conv_coor),
			.bs(bs),
		.sub(sub),
		.cru(cru),
		.des(des),
    .ld_ac(ld_ac), 
	 .ld_bs(ld_bs), 
	 .ld_cru(ld_cru), 
	 .ld_sub(ld_sub), 
	 .ld_des(ld_des), 
	 .guess(guess),
    );
	 // The counter aka datapath where the grid coordinate is modified to print to VGA
	counter c0 (
        .start(~KEY[1]),
        .clk(CLOCK_50),
		  .ld_ac(ld_ac), 
		  .ld_bs(ld_bs), 
		  .ld_sub(ld_sub), 
		  .ld_cru(ld_cru), 
		  .ld_des(ld_des), 
		  .guess(guess),
		  .converted_coordinate(conv_coor),
        .x_offset(xCount),  
        .y_offset(yCount),
        .plot(writeEn),
		  .win(win),
		  .ac(ac)
     ); 
	  
	// where the tile change is inputted. 
	always@(*)begin 
		  if (conv_coor >= 7'd1 && conv_coor <= 7'd5) begin
				colour <= 100;
				count <= count + 1'b1;
			end
			else if (conv_coor >= 7'd32  && conv_coor <= 7'd35) begin
				colour <= 100;
				count <= count + 1'b1;
			end
			else if (conv_coor >= 7'd62 && conv_coor <= 7'd64) begin
				colour <= 100;
				count <= count + 1'b1;
			end
			else if (conv_coor >= 7'd74 && conv_coor <= 7'd76) begin
				colour <= 100;
				count <= count + 1'b1;
			end
			else begin
				colour <= 010;
				count <= count + 1'b1;
			end
		end
		
	  hex_decoder H0(
	  .hex_digit(ac[3:0]), 
	  .segments(HEX0)
	  );
	/*save s0 (
        .clk(CLOCK_50),
        .val(SW[6:0]),
        .save),
        .resetn(KEY[0]),
    
        .x(x)
    ); */
	//convert coordinate to proper ones
	
    // Instansiate datapath
	//datapath d1(~KEY[1], CLOCK_50 ,converted_coordinate, ld_ac, ld_bs, ld_sub, ld_cru, ld_des, guess, ac, bs, cru, sub, des, xCount, yCount, count, win, writeEn);
    // Instansiate FSM control
	
   
endmodule
 module counter (
    input start,
    input clk,
    input ld_ac,
	 input ld_bs,
	 input ld_sub,
	 input ld_cru,
	 input ld_des,
	 input guess,
	 input converted_coordinate,
    output [1:0] x_offset, y_offset,
    output plot,
	 output reg win,
	 output [6:0] ac
    );
    
    reg continue;
    reg [3:0] count;
	 reg [6:0] ac1;
    assign x_offset = count[3:2];
    assign y_offset = count[1:0];
    assign plot = continue;
    
    always@(posedge clk)
    begin
        if (start == 1'b1 && count == 4'b1111 && ld_des == 1'b1)
            begin
                continue = 1'b1;
                count = 4'b0000;
            end
        else if (count < 4'b1111)
            begin
                count = count + 1'b1;
            end
        else
            continue = 1'b0;
    end
	always @(posedge clk) 
		begin
			// storage_mod(coordnate, 1 if boat tile exists, S_LOAD_ACclk, 1 for write, data_result);
			if(ld_ac) begin
				win <= 0;
				ac1 <= converted_coordinate;
			end
			/*if (ld_des) begin
				if(correct_guess)begin
					countguess <= countguess + 1;
				end
			end*/
		end
	 assign ac = ac1; 
endmodule 

module control(
    input clk,
    input go,
    input win,
    input data_processed,
	input conv_coor,

    output reg  ld_ac, ld_bs, ld_cru, ld_sub, ld_des, guess,
	 output reg [6:0] bs, cru, sub, des
    );
    reg [5:0] current_state, next_state; 
    
    localparam  S_LOAD_AC        = 5'd0, //state 0: load the air cruiser
                S_LOAD_AC_WAIT   = 5'd1, 
                S_LOAD_BS       = 5'd2, //state 1: load the battle cruiser
                S_LOAD_BS_WAIT   = 5'd3,
                S_LOAD_CRU        = 5'd4, //state 2: load the cruiser
                S_LOAD_CRU_WAIT   = 5'd5,
                S_LOAD_SUB        = 5'd6, //state 3: load submarine 
                S_LOAD_SUB_WAIT   = 5'd7,
                S_LOAD_DES        = 5'd7, //state 4: load destroyer
                S_LOAD_DES_WAIT   = 5'd8,
                S_CYCLE_0       = 5'd9,
					 S_CYCLE_0_WAIT      = 5'd10; //state 5: techinically should be renamed to S_GUESS
                
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_AC: next_state = go ? S_LOAD_AC_WAIT : S_LOAD_AC; // Loop in current state until value is input
                S_LOAD_AC_WAIT: next_state = go ? S_LOAD_AC_WAIT : S_LOAD_BS; // Loop in current state until go signal goes low
                S_LOAD_BS: next_state = go ? S_LOAD_BS_WAIT : S_LOAD_BS; // Loop in current state until value is input
                S_LOAD_BS_WAIT: next_state = go ? S_LOAD_BS_WAIT : S_LOAD_CRU; // Loop in current state until go signal goes low
                S_LOAD_CRU: next_state = go ? S_LOAD_CRU_WAIT : S_LOAD_CRU; // Loop in current state until value is input
                S_LOAD_CRU_WAIT: next_state = go ? S_LOAD_CRU_WAIT : S_LOAD_SUB; // Loop in current state until go signal goes low
                S_LOAD_SUB: next_state = go ? S_LOAD_SUB_WAIT : S_LOAD_SUB; // Loop in current state until value is input
                S_LOAD_SUB_WAIT: next_state = go ? S_LOAD_SUB_WAIT: S_LOAD_DES; //Loop in current state until go signal goes low
                S_LOAD_DES: next_state = go ? S_LOAD_DES_WAIT : S_LOAD_DES; // Loop in current state until value is input
                S_LOAD_DES_WAIT: next_state = go ? S_LOAD_DES_WAIT : S_LOAD_DES; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = go ? S_CYCLE_0_WAIT: S_CYCLE_0;
					 S_CYCLE_0_WAIT: next_state = go ? S_CYCLE_0_WAIT: S_CYCLE_0;//Loop in current state until the win input is true aka all the ship locations are guessed
				default: next_state = S_LOAD_DES;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  guess = 1'b0;
        ld_ac = 1'b0;
        ld_bs = 1'b0;
        ld_cru = 1'b0;
        ld_sub = 1'b0;
        ld_des = 1'b0;
		
		//guess2 = 1'b0;
        case (current_state)
            S_LOAD_AC: begin // setup phase
                ld_ac = 1'b1;
					
                end
            S_LOAD_BS: begin
                ld_bs = 1'b1;
				bs = conv_coor;
                end
            S_LOAD_CRU: begin
                ld_cru = 1'b1;
				cru = conv_coor;
                end
            S_LOAD_SUB: begin
                ld_sub = 1'b1;
				sub = conv_coor;
                end
            S_LOAD_DES: begin
                ld_des = 1'b1;
				des = conv_coor;
                end
            S_CYCLE_0: begin // guess phase
                guess = 1'b1;
            end
        endcase
    end

   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
            current_state <= next_state;
    end // state_FFS
	 
endmodule


 module coordinateConverter (user_x, user_y, outputConv, outputX, outputY);
	input [3:0] user_x, user_y;
	output [6:0] outputConv, outputY;
	output [7:0] outputX;
	
	assign outputConv = (user_y * 10) - 10 + user_x;
	assign outputY = user_y * 10;
	assign outputX = user_x * 10 + 1; 
 endmodule
 
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule