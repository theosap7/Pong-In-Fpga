module PanelDisplay_tb;

// set VGA_LOG = 0 to disable logging of the VGA output
parameter logic VGA_LOG = 1;

// TESTBENCH VARIABLES
integer fileout;
integer frame_cnt;
logic write_frame;
string s;

// DUT SIGNALS
logic clk;
logic rst;

logic vga_hsync;
logic vga_vsync;
logic [3:0] vga_red;
logic [3:0] vga_green;
logic [3:0] vga_blue;
logic move_enable;
logic button_up;
logic button_dn;
logic button_r;
logic button_l;
logic p1_up;
logic p2_up;
logic p1_dn;
logic p2_dn;
logic switch;
logic [15:0] led;
// DUT INSTANTIATION
PanelDisplay vga(.clk(clk), 
                 .rst(rst), 

				 .hsync(vga_hsync), 
				 .vsync(vga_vsync),
                 		 .red(vga_red), 
				 .green(vga_green),
				 .blue(vga_blue),
				 .led(led),
				 .switch(switch),
				 .p1_up(p1_up),
				 .p1_dn(p1_dn),
                                 .p2_up(p2_up),
				 .p2_dn(p2_dn),
				 .button_up(button_up),
				 .button_dn(button_dn),
 				 .button_l(button_l),
 				 .button_r(button_r),
				 .move_enable(move_enable))	;

// 100MHz CLOCK GENERATION
always begin
	clk = 0;
	#5ns;
	clk = 1;
	#5ns;
	button_up=1;
end

// STIMULUS
initial begin
   	
        
	$timeformat(-9, 0, " ns", 6);
  $display("Starting simulation...\n");
	RESET();
  $display("Reset complete, writing vga frame...\n");
 	
	WRITE_FRAME();
	$stop;
end

// End of the main body of the testbench
// ATTENTION: In the next lines you can find the implementation 
//            for the tasks used in the testbench.
 

// RESET TASK
task RESET();
	rst <= 1;
	repeat(2) @(posedge clk);
	rst <= 0;
	repeat(10) @(posedge clk);
endtask

task WRITE_FRAME();
  write_frame <= 1;
  @(negedge write_frame);
	@(posedge clk);
endtask

// Write frame to VGA log - DO NOT TOUCH
always @(negedge vga_vsync) begin
	if ( write_frame ) begin
		if (VGA_LOG==1) begin
			s.itoa(frame_cnt);	
			fileout = $fopen({"vga_frame_", s, ".txt"});
			repeat (13852800) begin
				@(posedge clk);
				$fdisplay(fileout, "%t: %b %b %b %b %b", $time, vga_hsync, vga_vsync, vga_red, vga_green, vga_blue);
			end
			@(negedge clk); 
	
			frame_cnt = frame_cnt +1;
			$fclose(fileout);
		end
		else begin
			repeat (13852800)@(posedge clk);
			@(negedge clk);
		end
	write_frame <= 0;
	end
end

endmodule
