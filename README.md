# clang-multi-triple 

One clang to rule them all<sup>*</sup>. 

This project started out because I wanted one clang binary to build whatever I want, instead of 
having to install `<triple>-<compiler>` for each. 

Currently supports these triples 
* musl:
    * `i386-pc-linux-musl`
    * `x86_64-pc-linux-musl`
* baremetal (newlib):
    * `i386-unknown-none-elf` 
    * `x86_64-unknown-none-elf` 

riscv64 on musl and baremetal coming soon.

## Credits and references

This experiment wouldn't have been possible without the help from [@mstorsjo](https://github.com/mstorsjo), 
who kindly pointed me to the right resources and patiently answered all my questions! 
Heavily inspired from [mstorsjo/llvm-mingw/musl](https://github.com/mstorsjo/llvm-mingw/tree/musl). 

* https://clang.llvm.org/docs/Multilib.html
* https://clang.llvm.org/docs/CrossCompilation.html
* https://compiler-rt.llvm.org/
* https://musl.libc.org/
* https://sourceware.org/newlib/

<sup>* well, some of them, for now</sup> 
