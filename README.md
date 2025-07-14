<picture>
  <source
    srcset="docs/qu_banner_dark.svg"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="docs/qu_banner_light.svg"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="docs/qu_banner_light.svg" alt="The Qu Processor README Top Banner" />
</picture><br /><br />

The Qu Processor is a 32-bit RISC-V CPU designed in SystemVerilog with a superscalar, out-of-order, and speculative execution pipeline.

## Status

All stages are fully implemented and tested for R, I, B & S-type instructions. The pipeline now supports speculative execution.

### Next Steps

- 🚧 Other instruction types in the RV32I ISA module
- 🚧 ISA extensions Zicsri and Zifencei
- 🚧 Full verification and compliance tests
- 🚧 Branch prediction

## Contributing

All types of contributions (pull requests, issues, etc.) are welcome and encouraged.

## License

The Qu Processor is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---