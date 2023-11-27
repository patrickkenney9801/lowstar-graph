#FROM projecteverest/everest-linux:commit-052c89d4258bd5d18319a462fe8b5dd9edac85e0 AS build

#USER root

#ENV FSTAR_HOME=/home/test/FStar
#ENV KRML_HOME=/home/test/karamel

#RUN ln -s /home/test/FStar/bin/fstar.exe /bin/fstar.exe
#RUN ln -s /home/test/karamel/krml /bin/krml

FROM docker.io/ocaml/opam:ubuntu-22.04-ocaml-4.12 AS build

USER root

RUN apt update && \
  apt install -y \
  libgmp-dev \
  python2.7 \
  pkg-config \
  libffi-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

USER opam

RUN opam update
RUN opam install ppx_deriving_yojson zarith pprint "menhir>=20161115" sedlex process fix "wasm>=2.0.0" visitors ctypes-foreign ctypes

RUN opam pin add fstar --dev-repo
RUN echo "export FSTAR_HOME=\"/home/opam/.opam/4.12/.opam-switch/build/fstar.$(eval opam info fstar | grep all-installed-versions | awk '{print $2}')\"" >> ~/.profile

RUN opam pin add karamel --dev-repo
RUN echo "export KRML_HOME=\"/home/opam/.opam/4.12/.opam-switch/build/karamel.$(eval opam info karamel | grep all-versions | awk '{print $2}')\"" >> ~/.profile

RUN echo "export OCAMLFIND_IGNORE_DUPS_IN=/home/opam/.opam/4.12/lib/ocaml/compiler-libs" >> ~/.profile
