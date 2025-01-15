
# **Hardware Implementation of SHA-256 for Secure Hashing on FPGA**

This project demonstrates the hardware implementation of the SHA-256 cryptographic hashing algorithm using Verilog on the Altera DE2 FPGA board (Cyclone II). The design processes a string input, computes the corresponding 256-bit hash value using the SHA-256 algorithm, and outputs the result in real-time.
## **Modules Description**

### Core Functional Modules

- **decoder_mapping.v**
    - The `decoder_mapping` module maps a 6-bit input (`data_in`) to an 8-bit ASCII character output (`ascii_out`), which translates input data into readable characters for further processing.

- **sha_256_constants.v**
    - The `sha_256_constants` module provides a 32-bit constant (`K`) for each of the 64 rounds in the SHA-256 algorithm, based on a 7-bit input index (0 to 63). These constants are critical for the hash computation process.

- **sha_256_functions.v**
    - The `sha_256_functions` module computes the core SHA-256 operations: 
        - **Ch** (Choice): `(x & y) ^ (~x & z)`
        - **Maj** (Majority): `(x & y) ^ (y & z) ^ (z & x)`
        - **sigma0** and **sigma1**: Transformations of `x` using bit rotations and XOR.

- **seven_segment_display_driver.v**
    - The `seven_segment_display_driver` module controls a 7-segment display, showing the hash value (0-9, A-F) corresponding to a 4-bit input, based on the `rounds_done` signal. If `rounds_done` is 0, it turns off the display.

### System and Process Integration Modules

- **decoder_input.v**
    - This module decodes the 6-bit input data and pads it to a 512-bit message. It uses a finite state machine (FSM) to manage states: **IDLE**, **PROCESSING**, and **COMPLETE**. It adds padding and appends the message length as the last 64 bits, outputting the final padded message as `padded_msg`.

- **sha_256_message_scheduler.v**
    - The `sha_256_message_scheduler` module generates the 64 words for SHA-256 by processing a 512-bit input block. The first 16 words are initialized from the input, and the remaining words are computed using the SHA-256 expansion formula.

- **sha_256_round.v**
    - This module executes the 64 rounds of SHA-256, updating the hash state variables (`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`) with each round. It uses the message scheduler, constants, and function modules to perform these calculations and outputs the final 256-bit hash after completing the rounds.

- **sha_256.v**
    - The `sha_256` module integrates the entire SHA-256 hashing process: from input padding (using `decoder_input`) to the final hash computation and display. The `sha_256_round` module processes the padded message, and the hash is displayed using the `seven_segment_display_driver` once the rounds are complete.


## **Step-by-Step Implementation**

### 1. Input Decoding
**Module: `decoder_input`**  
- Processes a string input, decodes it into ASCII characters, and pads it to a 512-bit block.  
- Uses a finite state machine (FSM) with the following states:
  - **IDLE:** Waits for the input signal.
  - **PROCESSING:** Decodes and accumulates input data.
  - **COMPLETE:** Pads the message and appends the message length in the last 64 bits.  
- **Output:** A fully padded 512-bit message block (`padded_msg`).



### 2. ASCII Character Mapping
**Module: `decoder_mapping`**  
- Maps 6-bit encoded input to corresponding 8-bit ASCII characters.  
- **Input:** 6-bit binary data.  
- **Output:** ASCII character in 8-bit format.  



### 3. Message Scheduling
**Module: `sha_256_message_scheduler`**  
- Expands the 512-bit message block into 64 32-bit words for SHA-256.  
- **Process:**
  - Initializes the first 16 words (`W[0]` to `W[15]`) from the input block.
  - Computes the remaining 48 words using using SHA-256's message expansion formula 
- **Output:** One 32-bit word at a time (`W_temp`).



### 4. Round Computation
**Module: `sha_256_round`**  
- Performs 64 rounds of the SHA-256 algorithm, updating hash state variables (`a` to `h`).  
- Uses constants, logical functions, and message scheduler words.  
- **Finite State Machine (FSM):**
  - **IDLE:** Waits for signal to start computation.
  - **ROUNDS:** Executes 64 iterative computations.
  - **FINAL:** Outputs the final 256-bit hash.  
- **Output:** 256-bit hash value.



### 5. Constant Generation
**Module: `sha_256_constants`**  
- Supplies pre-defined 32-bit constants K(0) to K(63) for each round.  
- **Input:** 7-bit round index.  
- **Output:** Corresponding constant.



### 6. SHA-256 Functions
**Module: `sha_256_functions`**  
- Implements critical logical operations:
  - **Ch** (Choice): `(x & y) ^ (~x & z)`
  - **Maj** (Majority): `(x & y) ^ (y & z) ^ (z & x)`
  - **sigma0**: A transformation of `x` using bit rotations and XOR.
  - **sigma1**: Another transformation of `x` with different bit rotations and XOR.


### 7. Hash Visualization
**Module: `seven_segment_display_driver`**  
- Displays the first 8 hexadecimal characters of the 256-bit hash on 7-segment LEDs.  
- **Input:** 
  - 4-bit value (`value`) from the hash.  
  - Signal (`rounds_done`) indicating computation completion.  
- **Output:** Activates LED segments to represent the hexadecimal values (0-9, A-F).  


### 8. Integration
**Module: `sha_256`**  
- Combines all modules to implement end-to-end SHA-256 functionality.  
- **Workflow:**
  1. Accepts string input, decodes it, and pads it using `decoder_input`.
  2. Generates 64 32-bit words using `sha_256_message_scheduler`.
  3. Performs 64 rounds of computation with `sha_256_round`.
  4. Displays the first 8 characters of the hash on 7-segment LEDs using `seven_segment_display_driver`.

## **Key Features**

1. **Hardware-Optimized:** Designed for efficient FPGA implementation.
2. **High Modularity:** Independent modules for ease of debugging and reusability.
3. **Real-Time Visualization:** Displays hash output dynamically on 7-segment LEDs.

## **Future Enhancements**
- Extend functionality to support multiple 512-bit blocks for larger inputs.
- Implement additional cryptographic hash algorithms (e.g., SHA-3).
- Optimize hardware usage for lower power consumption and higher speed.
## **Example**

- **Input:** `abc@123`
- **Output:** `e5857b335afdf35ca81a110bc81f38682f8a89892cc597f5398dfef82d42b513`

## **Output Waveform**

- We have given the input : `abc@123`  
  (i.e.000000(a),000001(b),000010(c),100101(@),011011(1),011100(2),011101(3) input to the decoder )

![App Screenshot](https://github.com/itsharshschoice/Hardware-Implementation-of-SHA-256-for-Secure-Hashing-on-FPGA/blob/main/input.png?raw=true)

- We get the 256 bit hash output :
  `e5857b335afdf35ca81a110bc81f38682f8a89892cc597f5398dfef82d42b513`

![App Screenshot](https://github.com/itsharshschoice/Hardware-Implementation-of-SHA-256-for-Secure-Hashing-on-FPGA/blob/main/output.png?raw=true)
## **RTL**

![App Screenshot](https://github.com/itsharshschoice/Hardware-Implementation-of-SHA-256-for-Secure-Hashing-on-FPGA/blob/main/RTL.png?raw=true)
## **Conclusion**

This project provides an efficient hardware-based implementation of the SHA-256 algorithm. The integration of key modules demonstrates the ability to process input data, schedule messages, execute rounds, and display the final hash value in real-time using FPGA-based hardware.
