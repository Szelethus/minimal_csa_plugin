cmake -G Ninja \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DLLVM_SRC_ROOT=~/Documents/analyzer_opts/llvm \
  -DLLVM_OBJ_ROOT=~/Documents/analyzer_opts/build/ \
  -DLLVM_INCLUDE_DIR=~/Documents/analyzer_opts/llvm/include \
  -DLLVM_LIB_DIR=~/Documents/analyzer_opts/build/lib \
  -DCLANG_INCLUDE_DIR=~/Documents/analyzer_opts/clang/include \
  -DCLANG_GENERATED_INCLUDE_DIR=~/Documents/analyzer_opts/build/tools/clang/include \
  ..
