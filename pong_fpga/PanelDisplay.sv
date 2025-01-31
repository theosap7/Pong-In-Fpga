module PanelDisplay (
input logic clk,
input logic rst,
input logic button_up,
input logic button_dn,
input logic button_r,
input logic button_l,
input logic switch,
output logic [5:0] P1_Score,
output logic [5:0] P2_Score,
output logic hsync,
output logic vsync,
output logic move_enable,
output logic [3:0] red,
output logic [3:0] green,
output logic [3:0] blue);
// code HERE
reg [5:0]counter1=0;
reg [5:0]counter2=0;
assign P1_Score=counter1;
assign P2_Score=counter2;
parameter hpixels = 800; // horizontal pixels per line
parameter vlines = 600; // vertical lines per frame
parameter hpulse = 120; // hsync pulse length
parameter vpulse = 6; // vsync pulse length
parameter hbp = 64; 	
parameter hfp = 56; 	
parameter vbp = 23;
parameter vfp = 37;

 
// registers for storing the horizontal & vertical counters
reg [10:0]hc=0;
reg [9:0]vc=0;
assign hsync = (hc < 920) ? 1:0; 
assign vsync = (vc < 660) ? 1:0;

//assign_valid
assign valid_move_p1= button_up ^ button_l;
assign valid_move_p2= button_dn ^ button_r;

// paddle 1 kai 2
reg[10:0]p1h=264;
reg[9:0]p1v=278;
reg[10:0]p2h=648;
reg[9:0]p2v=278;

//p1 move
always_ff @(posedge clk) begin
if (rst) begin
p1h<=264;
p1v<=278;
end  if (valid_move_p1 && move_enable && switch) begin
     if(p1v>=189 && p1v<368) begin
	   if(p1_up==1) 
	     p1v<=p1v+10;
	
	  else if(p1_dn==1) 
	    p1v<=p1v-10;
	  
	
	
      end else if(p1v<189 && p1_up==1) 
	   p1v<=219;
       else if(p1v>=368 && p1_dn==1)
		p1v<=367;
	end
 
end

//p2 move
always_ff @(posedge clk) begin
if (rst) begin
    p2h<=648;
    p2v<=278;
end  
else if (valid_move_p2 && move_enable==1 && switch ) begin
    if(p2v>=189 && p2v<368) begin
	   if(p2_up==1) 
	        p2v<=p2v+10;
	
	   else if(p2_dn==1) 
	        p2v<=p2v-10;	
	end
	else if(p2v<189 && p2_up==1) 
	   p2v<=190;
    else if(p2v>=368 && p2_dn==1)
	   p2v<=367;
	end
 
end


//button up
logic [1:0] p1_up_reg;
always_ff @(posedge clk) begin
 if (rst)
 p1_up_reg <= 2'b00;
 else begin
 p1_up_reg[1] <= p1_up_reg[0];
 p1_up_reg[0] <= button_up;
 end
 end
 assign p1_up= p1_up_reg[1];
//button left
logic [1:0] p1_dn_reg;
always_ff @(posedge clk) begin
 if (rst)
 p1_dn_reg <= 2'b00;
 else begin
 p1_dn_reg[1] <= p1_dn_reg[0];
 p1_dn_reg[0] <= button_l;
 end
 end
 assign p1_dn= p1_dn_reg[1];
  
//button right

logic [1:0] p2_up_reg;
always_ff @(posedge clk) begin
 if (rst)
 p2_up_reg <= 2'b00;
 else begin
 p2_up_reg[1] <= p2_up_reg[0];
 p2_up_reg[0] <= button_r;
 end
 end
 assign p2_up= p2_up_reg[1];
//button down
logic [1:0] p2_dn_reg;
always_ff @(posedge clk) begin
 if (rst)
 p2_dn_reg <= 2'b00;
 else begin
 p2_dn_reg[1] <= p2_dn_reg[0];
 p2_dn_reg[0] <= button_dn;
 end
 end
 assign p2_dn= p2_dn_reg[1];
  
//PixelClock
logic pxlClk;
always_ff @(posedge clk) begin
 if (rst)
 pxlClk <= 1'b1;
 else
 pxlClk <= ~pxlClk;
end

//Move_Enable
logic [1:0] s_reg;
always_ff @(posedge clk) begin
 if (rst)
 s_reg <= 2'b11;
 else begin
 s_reg[1] <= s_reg[0];
 s_reg[0] <= vsync;
 end
 end
 assign move_enable = s_reg[1] & ~s_reg[0];
//vcounter kai hcounter
 always_ff @(posedge clk) begin
 if (rst) begin
 hc <=0;
 vc <=0;
 end
 else if (pxlClk) begin
	if (hc < 1040 )
	   hc <= hc + 1; 
	else begin
	hc<=0;
	if(vc<666)
		vc<=vc+1;
	else
		vc<=0;


	end

   
   end 
end
//mpalaki
reg move_r=0;
reg move_u=1;
reg[10:0]hsq;
reg[9:0]vsq;

always_ff @(posedge clk) begin
 if (rst) begin
 hsq <=454;
 vsq <=313;
counter1<=0;
counter2<=0;
 end else if (vsync==0 && move_enable==1 && switch) begin
	
 	if (hsq < 628 && hsq > 264 && vsq < 458 && vsq >= 187) begin//278 allakse
   		 if (move_r == 1) 
       			 hsq <= hsq + 5;
		 else 
			hsq<= hsq-5;
   		end
		
   		 if (move_u == 1) 
      			  vsq <= vsq - 5;
    		 else  
      			  vsq <= vsq + 5;
		  	
 	end
// an akoumpisei sto paddle2
    else if (hsq+20>=p2h && move_r == 1) begin
      	if(vsq+20>=p2v && vsq<=p2v+90)begin
	hsq <= hsq - 5;
        move_r <= 0;
	end else begin
	 hsq <=454;
 	 vsq <=313;
	 counter1<=counter1+1;
end
        //an akoumpisei sto paddle 1
    end else if (hsq<=p1h &&  move_r == 0) begin
       	if(vsq+20>=p1v && vsq<=p1v+90) begin
	 hsq <= hsq + 5;
         move_r <= 1;
	 end else begin
	  
	  hsq <=454;
 	 vsq <=313;
	 counter2<=counter2+1;
	end

	// anakoumpisei sto kato orio
    end else if (vsq >= 438 && move_u == 0) begin
        vsq <= vsq - 5;    
        move_u <= 1;
     // an akoumpisei sto pano orio
    end else if (vsq < 188 && move_u == 1) begin
        vsq <= vsq + 5;
        move_u <= 0;
    end


end





always_ff @(posedge clk) begin
if (rst) begin
  	red = 4'b0000;
	green = 4'b0000;
    	blue = 4'b0000;
end
   // ean to hcounter einai sta porches tote ola mavra
if (pxlClk ) begin 
	if (hc > (hpixels + hbp) || hc < hbp || vc > (vlines + vbp) || vc< vbp)begin
	    red = 4'b0000;
    	    green = 4'b0000;
            blue = 4'b0000;
  	end
// protes kai teleutaies 150 grammes
	else if (vc <=149+vbp || vc >= 450+vbp ) begin
	    	red = 4'b0000;
    		green = 4'b0000;
		blue = 4'b0000;	
        end
// horizontal borders
	else if ((vc >= 150+vbp && vc <= 164+vbp)||(vc >= 435+vbp && vc <= 449+vbp)) begin
 	 
     		if ( hc <= 263 || (hc >= 664 && hc<= 1039)) begin
       			red = 4'b0000;
       			green = 4'b0000;
	   		blue = 4'b0000;       
	        end 
     		else begin
      	 		red = 4'b1111;
      	 		green = 4'b1111;
	  		blue = 4'b1111;                           
       		end
        end
// vertical borders
 	else if (vc>= 165+vbp && vc<= 434+vbp) begin
    				

		 if(hc>=hsq && hc<hsq+20 &&  vc>=vsq && vc<vsq+20 ) begin
      	 			red = 4'b1111;
      	 			green = 4'b1111;
	  		 	blue = 4'b1111;		
				
	

			end
			
  		
			else if(hc>=p1h && hc<p1h+15 && vc>=p1v && vc<p1v+90) begin
				red = 4'b1111;
      	 			green = 4'b1111;
	  		 	blue = 4'b1111;		
				end
			else if(hc>=p2h && hc<p2h+15 && vc>=p2v && vc<p2v+90) begin
      	 			red = 4'b1111;
      	 			green = 4'b1111;
	  		 	blue = 4'b1111;
			end	

			
			else begin
      	 			red = 4'b0000;
      	 			green = 4'b0000;
	  		 	blue = 4'b0000;
			end	

end    
	

end
end
endmodule