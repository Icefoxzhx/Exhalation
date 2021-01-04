# RISC-V CPU

MS108, Computer Architecture project in ACM class.

### Features

- 5-stage pipelined
- 1KB iCache, direct mapped.
- Branch Prediction using 2-bit saturating counter BHT with Branch Target Buffer(Size is 128*4 Byte).
- Running on FPGA with 200MHz
- Data forwarding supported.

### Summary

- Fixing io_buffer_full for uartboom: not only write 0x30000 needs to wait&&check, but also write 0x30004, otherwise the program won't finish.

- Wrong forwarding when reading from reg[0], the same bug as PPCA!!!!! [it's **ironic**.]

- Can't run on FPGA at first since I deal with *rdy* wrong, then forget to initialize some BHT/iCache ValidBits.

- Don't have time to support CSR, dCache and try some other Prediction scheme. What's a pity.

- Maybe get going earlier next time.

- Doing something with the FPGA is really interesting.(like manipulating with the leds)


### Reference

- Thanks a lot to **stneng, ZYHowell** and many other people for helping me a lot.
- Thanks **Pioooooo** for *display_ctrl* related codes.

### Repo Structure

```
|--bit/                   A demo about how to create a project in Vivado
|--common/                Provided UART and RAM
|--Basys-3-Master.xdc     constraint file
|--cpu.v                  My CPU 
|--hci.v                  A bus between UART/RAM and CPU
|--ram.v                  RAM
|--riscv_top.v            Top design
|--display_ctrl.v         Controller for the 4-digit 7-segment displayer on FPGA.
```

