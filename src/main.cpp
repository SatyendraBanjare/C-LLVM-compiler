#include <istream>
#include <fstream>
#include <unistd.h>

using namespace std;
using namespace llvm;

extern FILE* file_name;

int main(int argc, char const *argv[])
{
	// Handle file
	file_name = fopen(filename, "r");
	if (!file_name) {
        perror("File opening failed");
        return EXIT_FAILURE;
    }
	if (yyparse()){
		cout << "ERROR!" << endl;
		return EXIT_FAILURE;
	}

	GenContext context;
	context.CodeGen(*root);

	// ADD JIT flavour compilation.
	InitializeNativeTarget();
	InitializeNativeTargetAsmPrinter();
	InitializeNativeTargetAsmParser();

	// Emit the generated llvm IR
	filename[len-1] = 'l';
	filename[len] = 'l';
	filename[len+1] = '\0';
	ofstream outfile;
	outfile.open(filename, ios::out);
	context.OutputCode(outfile);
	outfile.close();

	context.run();
	fclose(file_name);

	return 0;
}
