Desired Docs:

Minimal example for compiling the simplest fst file from the command line.

```bash
fstar.exe fstar/code/*.fst --codegen krml --odir fstar/obj
krml fstar/obj/out.krml -tmpdir fstar/obj -skip-linking
```

How to build libraries, how to build a simple executable with a main function
