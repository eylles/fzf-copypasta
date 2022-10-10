.POSIX:
NAME = copypastas
PREFIX = ~/.local
EGPREFIX = $(PREFIX)/share/doc/$(NAME)/examples
.PHONY: install uninstall

$(NAME):
	sed "s|examples-placeholder|$(EGPREFIX)|; s|copypastas-sh|$(NAME)|" copypastas.sh > $(NAME)

install: $(NAME)
	chmod 755 $(NAME)
	chmod 755 pasta_preview
	mkdir -p $(DESTDIR)${PREFIX}/bin
	mkdir -p $(DESTDIR)$(EGPREFIX)
	cp -v $(NAME) $(DESTDIR)${PREFIX}/bin
	cp -v pasta_preview $(DESTDIR)${PREFIX}/bin
	cp -v gnu+linux $(DESTDIR)$(EGPREFIX)/
	cp -v configrc $(DESTDIR)$(EGPREFIX)/
	rm $(NAME)

uninstall:
	rm -vf $(DESTDIR)$(PREFIX)/bin/$(NAME)
	rm -vf $(DESTDIR)$(PREFIX)/bin/pasta_preview
	rm -vf $(DESTDIR)$(EGPREFIX)/gnu+linux
	rm -vf $(DESTDIR)$(EGPREFIX)/configrc
	rm -rf $(DESTDIR)$(EGPREFIX)

