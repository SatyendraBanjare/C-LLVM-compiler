#include "AST_tree.h"
// #include the output file of flex and bison

static LLVMContext TheContext;
static IRBuilder<> Builder(TheContext);
static std::unique_ptr<Module> TheModule;
static std::map<std::string, AllocaInst *> NamedValues;
static std::unique_ptr<KaleidoscopeJIT> TheJIT;
static std::map<std::string, std::unique_ptr<PrototypeAST>> FunctionProtos;

// Function to print errors for debugging.
Value *LogErrorV(const char *Str) {
  LogError(Str);
  return nullptr;
}

/// CreateEntryBlockAlloca - Create an alloca instruction in the entry block of
/// the function.  This is used for mutable variables etc.
static AllocaInst *CreateEntryBlockAlloca(Function *TheFunction,
                                          const std::string &VarName) {
  IRBuilder<> TmpB(&TheFunction->getEntryBlock(),
                   TheFunction->getEntryBlock().begin());
  return TmpB.CreateAlloca(Type::getDoubleTy(TheContext), nullptr, VarName);
}

static Value* IntExprNode::codegen(){

}

static Value* CharExprNode::codegen(){

}

static Value* DoubleExprNode::codegen(){

}

static Value* VariableExprNode::codegen(){

}

static Value* OperatorExprNode::codegen(){

}

static Value* BlockExprNode::codegen(){
`
}

static Value* AssignExprNode::codegen(){

}

static Value* FuncExprNode::codegen(){

}

static Value* CastExprNode::codegen(){

}

static Value* ExprStatementNode::codegen(){

}

static Value* ReturnStatementNode::codegen(){

}

static Value* VarDecStatementNode::codegen(){

}

static Value* ArrayDecStatementNode ::codegen(){

}

static Value* IndexExprNode::codegen(){

}

static Value* FuncDecStatementNode::codegen(){

}

static Value* ExternFuncDecStatementNode::codegen(){

}

static Value* IfStatementNode::codegen(){

}

static Value* ForStatementNode::codegen(){

}


