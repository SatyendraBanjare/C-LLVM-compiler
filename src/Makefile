all: compiler

OBJS =  C_syntax.o  		\
	AST_tree.o 				\
	main.o    				\
	C_lexer.o  			

LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11 -g
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses -rdynamic
LIBS = `$(LLVMCONFIG) --libs`
SYSTEMLIBS = `$(LLVMCONFIG) —-system-libs`

C_syntax.cpp: C_syntax.yacc
	bison -d --no-lines -o $@ $^

C_syntax.hpp: C_syntax.cpp

C_lexer.cpp: C_lexer.lex C_syntax.hpp
	flex -L -o $@ $^

%.o: %.cpp
	g++ -c $(CPPFLAGS) -o $@ $< -fpermissive

compiler: $(OBJS)
	clang++ -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

clean:
	$(RM) -rf C_syntax.cpp C_syntax.hpp compiler y.output c_code/*.ll C_lexer.cpp $(OBJS)
