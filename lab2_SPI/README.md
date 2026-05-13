# SPI Lab 2 - Xcelium Run Guide

This folder contains the SPI RTL and testbenches. The quickest way to run on Xcelium is with `xrun`.

## Files

- RTL: spi_top.v, spi_master.v, spi_slave.v
- Testbenches: tb_spi.v, tb_spi_master.v, tb_spi_slave.v, tb_spi_checklist.v
- Checklist split tests: tb_spi_chk_01_apb_gpu_power.v, tb_spi_chk_04_register_rw.v, tb_spi_chk_06_simple_bus.v
- Common include: tb_spi_checklist_common.vh

## Run on Xcelium

From the lab2_SPI directory:

```bash
xrun -access rw -licqueue -64BIT -l run.log \
  tb_spi.v spi_top.v spi_master.v spi_slave.v
```

Run a specific testbench by replacing `tb_spi.v` with one of:

- tb_spi_master.v
- tb_spi_slave.v
- tb_spi_checklist.v
- tb_spi_chk_01_apb_gpu_power.v
- tb_spi_chk_02_register_rw.v
- tb_spi_chk_03_simple_bus.v

### Waveforms

If you want Xcelium waveform dumping (waves.dsn / waves.trn), define `XCELIUM`:

```bash
xrun -access rw -licqueue -64BIT -l run.log +define+XCELIUM \
  tb_spi_checklist.v spi_top.v spi_master.v spi_slave.v
```

Check `run.log` after the run.
