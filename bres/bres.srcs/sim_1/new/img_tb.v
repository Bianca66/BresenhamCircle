`timescale 1ns / 1ps
//---------------------------Constants---------------------------//
`define CLK_PERIOD 10
`define read_fileName "D:\\test\\c2.bmp"
`define write_fileName "D:\\test\\c2_tb.bmp"
//---------------------------------------------------------------//


module img_tb();
//----------Signals----------//
    //General
    reg clk;
    //RGB signals
    reg [7:0] start_x;
    reg [7:0] start_y;
    reg [7:0] radius;
    //Control input signal
    reg        go;
    //Output Gray signal
    wire [15:0] address;
    wire        busy;
    wire        we;
//---------------------------//
    
//-----------Instantiate Module------------//

circle circle_m (// General
                 .clk      (clk),
                 //  Coordinates for centroid and radius
                 .start_x   (start_x),
                 .start_y  (start_y),
                 .radius   (radius),
                 // Control input signal
                 .go  (go),
                 // Output Gray signal
                 .address (address),
                 .busy (busy),   
                 .we   (we)   
                 );
//-----------------------------------------//    

integer j;
localparam RESULT_ARRAY_LEN = 100*1024*24;
reg [7:0] result [0:RESULT_ARRAY_LEN-1];

//-----------Init + Gen Clock------------//                   
    initial
    begin
        clk = 1;
        forever
        begin
            #(`CLK_PERIOD/2) clk = ~clk;
        end
    end
//-----------------------------------------// 

    
//---------------BMP values----------------//  
    // Array length
    //localparam BMP_ARRAY_LEN = 797*1024*24;
    localparam BMP_ARRAY_LEN = 255*1024*24;
    // Mem Data
    reg [7:0] bmp_data [0:BMP_ARRAY_LEN-1];
    // Other Constants from BMP header
    integer bmp_size;
    integer bmp_start_pos;
    integer bmp_width;
    integer bmp_height;
    integer biBitCount;
//-----------------------------------------// 



//---------------Read BMP data----------------// 
    task readBMP;
            integer fileId, i;
            begin
                fileId = $fopen(`read_fileName,"rb");
                if(fileId == 0)
                begin
                    $display("Open BMP error!\n");
                    $finish;
                end
                else
                begin
                    $fread(bmp_data,fileId);
                    $fclose(fileId);
                    
                    bmp_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
                    $display("bmp_size = %d!\n", bmp_size);
                    
                    bmp_start_pos = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
                    $display("bmp_start_pos = %d!\n", bmp_start_pos);
                    
                    bmp_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
                    $display("bmp_width = %d!\n", bmp_width);
                    
                    bmp_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
                    $display("bmp_height = %d!\n", bmp_height); 
                    
                    biBitCount = {bmp_data[29], bmp_data[28]};
                    $display("biBitCount = %d!\n", biBitCount);
                    
                    for(i = bmp_start_pos; i < bmp_size; i = i + 1)
                    begin
                        $display("%h", bmp_data[i]);
                    end
                end
            end
        endtask
//-----------------------------------------// 


//---------------Write BMP data----------------// 
    task writeBMP;
            integer fileId, i;
            begin
                fileId = $fopen(`write_fileName,"wb");  
                
                for(i = 0; i < bmp_size; i = i + 1)
                begin
                    $fwrite(fileId,"%c", bmp_data[i]);
                end    
                
                $fclose(fileId);
                $display("writeBMP: done!\n");
                $display("%d\n!!!!!!!!!",bmp_data[600]);
                
                for(i = bmp_start_pos; i < bmp_size; i = i + 1)
                                    begin
                                        $display("%h", bmp_data[i]);
                                    end
            end
    endtask
//-----------------------------------------// 

/*    task data;
        integer j;
        while(we)
        begin
            j = bmp_start_pos + address[7:0]*bmp_width + address[15:8];
            bmp_data[j]     = 8'd0;
        end
    endtask*/
    
    task data;
        while(busy)
        begin
             bmp_data[bmp_start_pos + address[7:0]*bmp_width + address[15:8]]   = 8'd0;  
             bmp_data[bmp_start_pos + address[7:0]*bmp_width + address[15:8]+1] = 8'd0;  
             bmp_data[bmp_start_pos + address[7:0]*bmp_width + address[15:8]+2] = 8'd0;  
        end
    endtask
    
    initial
    begin
        #(`CLK_PERIOD*21);
        go        = 0;
            
    end
    
    integer i;
    initial
    begin
        go        = 0;
        start_x   = 0;
        radius    = 0;
        start_y   = 0;
        readBMP;
        
        #(`CLK_PERIOD*5);
        go        = 1;
        start_x   = 50;
        start_y   = 50;
        radius    = 20;
        
        //data;
        
        #(`CLK_PERIOD);
        writeBMP;
     end   
endmodule