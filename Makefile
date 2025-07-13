all:
	bison -d form.y
	flex form.l
	gcc -o form_generator form.tab.c lex.yy.c html_generator.c -lfl

run: all
	./form_generator < example.form > output.html

clean:
	rm -f form_generator form.tab.c form.tab.h lex.yy.c output.html
