#ifndef AST_TREE_H
#define AST_TREE_H

#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Scalar/GVN.h"

#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/Support/MemoryBuffer.h"
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/Interpreter.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/Host.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/IR/LLVMContext.h>
#include "llvm/IR/Verifier.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"

#include <iostream>
#include <sstream>
#include <fstream>
#include <typeinfo>
#include <algorithm>
#include <cassert>
#include <cctype>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <memory>
#include <string>
#include <vector>

// pretty messed up, figuring out what I will need finally.
// Leaving it as it is for now.

using namespace llvm;
using namespace std;

enum Valid_Type {
    V_UNKNOWN = -1,
    V_VOID = 0,
    V_CONST,
    V_CHAR,
    V_INT,
    V_FLOAT,
    V_PTR,
    V_FUNC,
};

class ASTNode {
public:
    ASTNode() {};
    virtual ~ASTNode(){};
    virtual Value *codegen() = 0;
};

class ExprNode: public ASTNode {
public:
    Valid_Type _type;
};

class StatementNode: public ASTNode {};

class IntExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class CharExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class DoubleExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class VariableExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class OperatorExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class BlockExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class AssignExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class FuncExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class CastExprNode: public ExprNode {
public:
    virtual Value *codegen();
};

class ExprStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class ReturnStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class VarDecStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class ArrayDecStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class IndexExprNode : public ExprNode {
public:
    virtual Value *codegen();
};

class FuncDecStatementNode : public StatementNode { 
public:
    virtual Value *codegen();
};

class ExternFuncDecStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class IfStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

class ForStatementNode : public StatementNode {
public:
    virtual Value *codegen();
};

#endif
