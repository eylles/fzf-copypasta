.POSIX:
PREFIX = ~/.local
.PHONY: install uninstall

install:
	chmod 755 copypastas
	chmod 755 pasta_preview
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -vf copypastas ${DESTDIR}${PREFIX}/bin
	cp -vf pasta_preview ${DESTDIR}${PREFIX}/bin
uninstall:
	rm -vf ${DESTDIR}${PREFIX}/bin/copypastas
	rm -vf ${DESTDIR}${PREFIX}/bin/pasta_preview

