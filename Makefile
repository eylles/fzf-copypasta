.POSIX:
NAME = copypastas
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
LIB_LOC = $(DESTDIR)${PREFIX}/lib/$(NAME)
EGPREFIX = $(DESTDIR)$(PREFIX)/share/doc/$(NAME)/examples
.PHONY: install uninstall

pasta_preview:
	cp pasta_preview.sh pasta_preview

$(NAME): pasta_preview
	sed "s|examples-placeholder|$(EGPREFIX)|; s|copypastas-sh|$(NAME)|; s|@lib@|$(LIB_LOC)|" \
		copypastas.sh > $(NAME)
	sed "s|copypastas-sh|$(NAME)|" configrc.template > configrc

install: $(NAME)
	chmod 755 $(NAME)
	chmod 755 pasta_preview
	mkdir -p $(BIN_LOC)
	mkdir -p $(LIB_LOC)
	mkdir -p $(DESTDIR)$(EGPREFIX)
	cp -v $(NAME) $(BIN_LOC)/
	cp -v pasta_preview $(LIB_LOC)/
	cp -v gnu+linux $(EGPREFIX)/
	cp -v configrc $(EGPREFIX)/
	rm $(NAME)
	rm pasta_preview
	rm configrc

uninstall:
	rm -vf $(BIN_LOC)/$(NAME)
	rm -vf $(LIB_LOC)/pasta_preview
	rm -rf $(LIB_LOC)
	rm -vf $(EGPREFIX)/gnu+linux
	rm -vf $(EGPREFIX)/configrc
	rm -rf $(EGPREFIX)

