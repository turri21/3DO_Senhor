module VE
(
	input              CLK,
	input              RST_N,
	input              EN,
	
	input              VCE_R,
	input              VCE_F,
	
	output             HSYNC_N,
	output             VSYNC_N,
	
	output             HS_N,
	output             VS_N,
	output             HBLK_N,
	output             VBLK_N,
	output             DCLK,
	
	input      [ 7: 0] DBG_EXT,
	input              DBG_BORD_DIS,
	output     [ 9: 0] DBG_HS_START,DBG_HS_END
);

	bit  DCLK_DIV;
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin
			DCLK_DIV <= '0;
		end
		else if (EN && VCE_R) begin
			DCLK_DIV <= ~DCLK_DIV;
		end
	end 
	wire DCE_R =  DCLK_DIV & VCE_R;
	wire DCE_F = ~DCLK_DIV & VCE_R;
	
	wire [ 9: 0] HBLANK_START = 10'd58 + 10'd16 + (DBG_BORD_DIS ? 10'd0 : 10'd8) + 10'd640;
	wire [ 9: 0] HBLANK_END = 10'd58 + 10'd16 - (DBG_BORD_DIS ? 10'd0 : 10'd8);
	
	bit  [ 9: 0] HCNT;
	bit  [ 8: 0] VCNT;
	bit          HSYNC,HSYNC2;
	bit          VSYNC;
	bit          HBLK;
	bit          VBLK;
	always @(posedge CLK or negedge RST_N) begin
		bit  [ 7: 0] DBG_EXT_OLD;
		
		if (!RST_N) begin
			HCNT <= '0;
			VCNT <= '0;
			HSYNC <= 1;
			VSYNC <= 1;
			HSYNC2 <= 1;
			DBG_HS_START <= 10'd752;
			DBG_HS_END <= 10'd30;
		end
		else if (EN && VCE_R) begin
			if (DCLK_DIV) begin
				HCNT <= HCNT + 10'd1;
				if (HCNT == 10'd780 - 1) begin
					HCNT <= '0;
					HSYNC <= 1;
					
					VCNT <= VCNT + 9'd1;
					if (VCNT == 9'd263 - 1) begin
						VCNT <= '0;
						VSYNC <= 1;
					end
					if (VCNT == 9'd3 - 1) begin
						VSYNC <= 0;
					end
					
					if (VCNT == 9'd21 + 9'd240 - 1) begin
						VBLK <= 1;
					end
					if (VCNT == 9'd21 - 1) begin
						VBLK <= 0;
					end
				end
				if (HCNT == 10'd58 - 1) begin
					HSYNC <= 0;
				end
				
				
				if (HCNT == (DBG_HS_START - 10'd1)) begin
					HSYNC2 <= 1;
				end
				if (HCNT == (DBG_HS_END - 10'd1)) begin
					HSYNC2 <= 0;
				end
				
				if (HCNT == HBLANK_START - 1) begin
					HBLK <= 1;
				end
				if (HCNT == HBLANK_END - 1) begin
					HBLK <= 0;
				end
			end
			
			DBG_EXT_OLD <= DBG_EXT;
			if (DBG_EXT[6] && !DBG_EXT_OLD[6]) if (DBG_HS_START > 10'd732) begin DBG_HS_START <= DBG_HS_START - 10'd1; DBG_HS_END <= DBG_HS_END - 10'd1; end
			if (DBG_EXT[7] && !DBG_EXT_OLD[7]) if (DBG_HS_START < 10'd772) begin DBG_HS_START <= DBG_HS_START + 10'd1; DBG_HS_END <= DBG_HS_END + 10'd1; end
		end
	end 
	
	
	assign HSYNC_N = ~HSYNC;
	assign VSYNC_N = ~VSYNC;

	assign HS_N = ~HSYNC2;
	assign VS_N = ~VSYNC;
	assign HBLK_N = ~HBLK;
	assign VBLK_N = ~VBLK;
	assign DCLK = DCLK_DIV;

endmodule
