#include <iostream>
#include <fstream>
#include <unistd.h>
#include "AST_tree.h"

using namespace std;
using namespace llvm;

extern FILE* yyin;
extern BlockExprNode* root;
extern int yyparse();
extern void linkExternalFunctions(GenContext &context);

void usage() {
	cout << "\nusage: ./compiler  <filename.c>\n" << endl;
}

int main(int argc, char **argv) {
	char *filename;
	
	// check args
	if (argc == 2) {
		filename = argv[1];
	} else {
		usage();
		return 0;
	}

	// check filename
	int len = strlen(filename);
	if (filename[len - 1] != 'c' || filename[len - 2] != '.') {
		usage();
		return 0;
	}
	yyin = fopen(filename, "r");
	if (!yyin) {
        perror("File opening failed");
        return EXIT_FAILURE;
    }
	if (yyparse()){
		cout << "ERROR!" << endl;
		return EXIT_FAILURE;
	}
	
	GenContext context;
	InitializeNativeTarget();
	InitializeNativeTargetAsmPrinter();
	InitializeNativeTargetAsmParser();
	linkExternalFunctions(context);
	cout << "Generating LLVM code" << endl;
	cout << "--------------------" << endl;
	context.CodeGen(*root);
	cout << endl;
	cout << "--------------------" << endl;
	cout << "Finished" << endl;

	filename[len-1] = 'l';
	filename[len] = 'l';
	filename[len+1] = '\0';
	ofstream outfile;
	outfile.open(filename, ios::out);
	context.OutputCode(outfile);
	outfile.close();

	cout << "Run LLVM code" << endl;
	cout << "-------------" << endl;
	context.run();
	cout << endl;
	cout << "-------------" << endl;
	cout << "Rnd LLVM code ends" << endl;
	cout << "Finished" << endl;

	fclose(yyin);

	return 0;
}
