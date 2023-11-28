Build Instructions:

```bash
make podman-image
make podman
make check
make krml
make c
make exe
```

Desired Docs:

Minimal example for compiling the simplest fst file from the command line.

```bash
fstar.exe fstar/code/*.fst --codegen krml --odir fstar/obj
krml fstar/obj/out.krml -tmpdir fstar/obj -skip-linking
```

How to build libraries, how to build a simple executable with a main function

Cannot be asserted out of the box `assert (max l > hd ==> (hd < max l));`.

Given an object of a set S where S has a totalorder <
it is not given that for x, y in S
that x < y implies y < x.
