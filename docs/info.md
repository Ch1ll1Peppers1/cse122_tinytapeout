<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## 3×3 Matrix Multiplication Accelerator

Tiny Tapeout Project
Author: LMRC

This project implements a synchronous 3×3 matrix multiplication accelerator in Verilog for Tiny Tapeout. It computes: A X B = C, where A & B are a 3×3 matrix of 8-bit unsigned integers and C is a 3×3 matrix of 16-bit unsigned integers. 

## How it works
When load = 1:
 - First 9 values are stored into matrix A
 - Next 9 values are stored into matrix B
 - One element is loaded per clock cycle

When start = 1 (single-cycle pulse):
 - The FSM begins matrix multiplication
 - Computation proceeds sequentially
 - Each output element is calculated as: cij = ai1 · b1j + ai2 · b2j + ai3 ·  b3j

Total compute cycles:
9 outputs × 3 multiply-accumulate operations = 27 cycles

When computation finishes:
 - done is asserted high for one cycle
 - Results are available for readout

## How to test

Run cd test and make

This will:
 - Compile RTL
 - Run cocotb test
 - Generate waveform files
 - Produce results.xml

The testbench:
 - Resets the design
 - Loads matrices A and B
 - Pulses start
 - Waits for done
 - Verifies output values

Example test matrices:

A = |1 2 3|
    |4 5 6|
    |7 8 9|

B = |9 8 7|
    |6 5 4|
    |3 2 1|

Expected result:

C = | 30  24  18 |
    | 84  69  54 |
    |138 114  90 |


## External hardware

To use this design on a physical Tiny Tapeout board:
 - Required Signals
 - Clock (provided by TT board)
 - Reset (active low)
 - 8 digital inputs
 - 8 digital outputs

## Acknowledgement use of AI

This project was completed with the help of Generative AI under what was designated as allowed under the instructions, specifically: Helping summarize this steps and help debug big errors in code to get to the current working implementation.
