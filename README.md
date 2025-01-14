
# Hardware Implementation of SHA-256 for Secure Hashing on FPGA

This project demonstrates the hardware implementation of the SHA-256 cryptographic hashing algorithm using Verilog on the Altera DE2 FPGA board (Cyclone II). The design processes a string input, computes the corresponding 256-bit hash value using the SHA-256 algorithm, and outputs the result in real-time.


## Modules Description

### Core Functional Modules

- **decoder_mapping.v**
- The `decoder_mapping` module takes a 6-bit input (`data_in`) and maps it to an 8-bit ASCII character output (`ascii_out`). This module is useful for translating 6-bit input data into readable characters for further processing or display.

- **sha_256_constants.v**
- The `sha_256_constants` module outputs a 32-bit constant (`K`) based on a 7-bit input index (0 to 63). Each index corresponds to a specific constant used in the SHA-256 algorithm's rounds. These constants are essential for the hash computation. If the index is invalid, the module outputs `32'h00000000`.

- **sha_256_functions.v**
- The sha_256_functions module computes four key SHA-256 operations:
    - **Ch** (Choice): `(x & y) ^ (~x & z)`
    - **Maj** (Majority): `(x & y) ^ (y & z) ^ (z & x)`
    - **sigma0**: A transformation of `x` using bit rotations and XOR.
    - **sigma1**: Another transformation of `x` with different bit rotations and XOR.

- These operations are used in the hash calculation process.


- **seven_segment_display_driver.v**
- The `seven_segment_display_driver` module drives a 7-segment display based on a 4-bit value (0-15) and a `rounds_done` signal. If `rounds_done` is 1, it displays the corresponding value (0-9, A-F) on the display; if 0, it turns off the display. The segment mappings are predefined for each digit and letter.

### System and Process Integration Modules

- **decoder_input.v**

- This Verilog module `decoder_input` handles the input data for a cryptographic process by decoding a 6-bit data stream into ASCII characters and padding it to a 512-bit message. It uses a finite state machine (FSM) with three states: **IDLE**, **PROCESSING**, and **COMPLETE**. In the PROCESSING state, it decodes and stores the input data, while in the COMPLETE state, it adds necessary padding (1-bit and zeros) and appends the message length as the last 64 bits. The final padded message is output as `padded_msg`, and the `done` signal indicates completion.

- **sha_256_message_scheduler.v**
- The `sha_256_message_scheduler` module processes a 512-bit input block to generate 64 32-bit words (`W_temp`) for SHA-256. It initializes the first 16 words from the input and computes the remaining words using SHA-256's message expansion formula. It outputs one 32-bit word (`W`) at a time and tracks the round with a counter.

- **sha_256_round.v**
- The `sha_256_round` module implements the core SHA-256 round logic. It processes a 512-bit input message block across 64 rounds, updating the hash state variables (`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`) at each round. The module uses a message scheduler to generate the message schedule words (`Wt`), and constants and functions modules for the necessary SHA-256 operations (like Ch, Maj, sigma). 
- It uses a finite state machine (FSM) with four states: **IDLE**, **ROUNDS**, **FINAL**, and **HOLD**.  In the IDLE state, it waits for the `done` signal to start the round operations. Once triggered, it moves to the ROUNDS state, where it performs 64 rounds of SHA-256 calculations. After completing the rounds, the module enters the FINAL state, where it finalizes the hash and sets the `rounds_done` signal to indicate completion. Finally, in the HOLD state, the module holds the final computed hash, marking the end of the process. The output is the 256-bit SHA-256 hash.

- **sha_256.v**
- The sha_256 module integrates the entire SHA-256 hashing process, including input padding, hash computation, and display of the final hash. It first uses the `decoder_input` module to pad the input message and signals when padding is complete. The `sha_256_round` module processes the padded message and performs the SHA-256 rounds to compute the 256-bit hash. Finally, the `seven_segment_display_driver` module display each 4-bit chunk of the hash on seven 7-segment displays, updating once the rounds are finished. The module demonstrates the flow of data from input to display based on the `input_start`, `input_complete`, and `rounds_done` signals.
