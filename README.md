# CSE 220 - System Fundamentals I

This includes all the projects that I have completed for my Systems Fundamentals I course where I used MIPS and Stony Brook University Fall 2019 version of MARS (MIPS Assembler and Runtime Simulator).

All the descriptions, assumptions, and examples are taken from the homework document created by my professor, Kevin McDonnell.

## proj1.asm
  This is an introductory project to the MIPS assembly, where I checked for any invalid inputs and print appropriate error message. Then I implemented a total of 4 different commands.
### (D) Decode a String of 8 Hexadecimal Digits that Encode a MIPS I-type Instruction
#### Description
  The `D` operation takes a command-line argument consisting of the characters `0x`, followed by exactly 8 hexadecimals that encode an I-type MIPS instruction. It will print out the fields as follows, formatted exactly as the following:
    `opcode rs_field rt_field immediate_field`
with the 4 values extracted from the encoded instruction all printed in base 10.
#### Assumption(s)
  * The immediate field is always signed.
#### Example
  Input: `D 0x30E9FFFC`
  
  Output: `12 7 9 -4`

### (E) Encode 4 Numerical Fields as an I-Type MIPS Instruction
#### Description
  The `E` operation takes 4 decimal values, treats them as the 4 fields of a MIPS I-type instruction. Using shifting and masking operations, it combines the 4 values into a single 32-bit integer that represents an I-type instruction.
#### Assumption(s)
  * The second, third, and fourth command-line arguments always consists of exactly 2 decimal digit characters that encode a positive intege.
  * The fifth argument consists of exactly 5 decimal digit characters with an optional negative sign on the left.
#### Example
  Input: `E 12 07 09 -4`
  
  Output: `0x30E9FFFC`
  
### (C) Convert from One Integer Representation to Another
#### Description
  The `C` operation converts an integer represented in one integer representation and prints the same integer in binary. Valid second and third arguments are 1, 2, or S, which represent one's complement, two's complement, and signed representation, respectively. If the second and third arguments have the same value, no conversion is needed.
#### Assumption(s)
  * Input value can be represented in the target representation.
  * The provided hexadecimal number is properly formatted.
#### Example
  Input: `C 2 S 0xFFFFFFFD` (`0xFFFFFFFD` is a two's complement integer and we want the signed representation of this value.)
  
  Output: `10000000000000000000000000000011`

### (B) Score a Hand of Cards 
#### Description
  The `B` operation accepts a String of 26 characters that encode a 13-card hand of Bridge and scores the hand according to the rules below. The operation prints the score in decimal.
  #### Rules
  Each card is represented by a two-character code: the rank followed by the suit. The ranks 2-10, Jack, Queen, King, and Ace are represented by the characters `2, 3, ..., 9, T, J, Q, K,` and `A`, respectively. The suits Hearts, Diamonds, Clubs, and Spades are represented by the characters `H, D, C`, and `S`.
  * A = 4 points
  * K = 3 points
  * Q = 2 points
  * J = 1 point
  * Others = 0 point
  If the hand has only 2 cards of a particular suit, then the hand is worth an extra point. If the hand has only one card of a particular suit, then the hand is worth 2 points. If the hand has no cards of a particular suit, then the hand is worth 3 extra points.
#### Assumption(s)
  * All input is valid. Every card will be unique in the 13-card hand.
#### Example
  Input: `B 6DQH2S3SJS6S6H5H5DAH8SJD8D`
  
  Output: `11`

## proj2
  
