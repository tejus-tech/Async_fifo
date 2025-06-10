# Project Asynchronous FIFO in Verilog

## Features
 
- Asynchronous read and write clock domains  
- Dual-clock synchronization to prevent metastability  
- Status flags: full and empty  
- Gray-coded pointer implementation for safe cross-domain updates  

## How It Works

Data is written on wr_en  using wr_clk and read on rd_en using rd_clk.  
Internally, two sets of pointers are maintained in **binary and Gray code** to safely synchronize across clock domains:   

The FIFO becomes:  
- Full when the write pointer catches up to the synchronized read pointer  
- Empty when the read pointer equals the synchronized write pointer  

## Simulation

### EDA Playground  
- Online platform support for multi-clock simulation

### Icarus Verilog  
iverilog -o async_sim.vvp Async_FIFO.v Async_FIFO_tb.v  
vvp async_sim.vvp  
gtkwave waveform.vcd  

## Waveform
![image](https://github.com/user-attachments/assets/4e053a1f-1096-49ac-a819-47c6d72e6dcc)

## Learning outcomes
- Gained understanding of asynchronous communication challenges
- Learned how to use Gray code pointers and dual-clock synchronizers
- Implemented and verified safe full and empty detection
- Simulated and visualized timing behavior with different clock frequencies
- Improved proficiency with Verilog and cross-domain design concepts
