# The target library's name
LIBRARY = gtk_light

# Commands to use for ocamlbuild and ocamlfind (in case they are not in $PATH)
OCAMLBUILD = ocamlbuild -tag debug
OCAMLFIND = ocamlfind

# Where ocamlbuild put the build files
BUILD_DIR = _build/

# Default to building bytecoode and native code libraries
all: byte opt
byte:
	$(OCAMLBUILD) $(LIBRARY).cma
opt:
	$(OCAMLBUILD) $(LIBRARY).cmxa

# (Un)Installation using ocamlfind
install:
	$(OCAMLFIND) install $(LIBRARY) \
	    META \
	    $(BUILD_DIR)${LIBRARY}.cmi \
	    $(BUILD_DIR)${LIBRARY}.cma \
	    $(BUILD_DIR)${LIBRARY}.cmxa \
	    $(BUILD_DIR)${LIBRARY}.a
uninstall:
	$(OCAMLFIND) remove $(LIBRARY)

# Clean up the build process using ocamlbuild
clean:
	$(OCAMLBUILD) -clean

