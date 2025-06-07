.POSIX:
NAME = copypastas
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
LIB_LOC = $(DESTDIR)${PREFIX}/lib/$(NAME)
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
EGPREFIX = $(DESTDIR)$(PREFIX)/share/doc/$(NAME)/examples
.PHONY: install uninstall install-all clean all

all: $(NAME)

pasta_preview:
	cp pasta_preview.sh pasta_preview
	chmod 755 pasta_preview

$(NAME): pasta_preview
	sed "s|examples-placeholder|$(EGPREFIX)|; s|copypastas-sh|$(NAME)|; s|@lib@|$(LIB_LOC)|" \
		copypastas.sh > $(NAME)
	sed "s|copypastas-sh|$(NAME)|" configrc.template > configrc
	chmod 755 $(NAME)

install: $(NAME)
	mkdir -p $(BIN_LOC)
	mkdir -p $(LIB_LOC)
	mkdir -p $(EGPREFIX)
	cp -v $(NAME) $(BIN_LOC)/
	cp -v pasta_preview $(LIB_LOC)/
	cp -v gnu+linux $(EGPREFIX)/
	cp -v configrc $(EGPREFIX)/

install-desktop:
	@echo "INSTALL fzf-copypasta.desktop"
	mkdir -p $(DESK_LOC)
	cp fzf-copypasta.desktop $(DESK_LOC)/

install-all: install install-desktop

uninstall:
	rm -vf $(BIN_LOC)/$(NAME)
	rm -vf $(LIB_LOC)/pasta_preview
	rm -rf $(LIB_LOC)
	rm -vf $(EGPREFIX)/gnu+linux
	rm -vf $(EGPREFIX)/configrc
	rm -rf $(EGPREFIX)
	rm -vf $(DESK_LOC)/fzf-copypasta.desktop

clean:
	rm -vf $(NAME) pasta_preview configrc
