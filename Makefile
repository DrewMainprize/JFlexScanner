JAVAC=javac
#JFLEX=jflex
#JFLEX=/Users/fsong/Projects/jflex/bin/jflex
JFLEX=/Users/drewmainprize/Desktop/CIS*4650/WarmupAssignment/jflex/bin/jflex

all: Token.class Lexer.class Scanner.class

%.class: %.java
	$(JAVAC) $^

Lexer.java: sgml.flex
	$(JFLEX) sgml.flex

clean:
	rm -f Lexer.java *.class *~
