cmake -G Ninja \
  -DCMAKE_CXX_COMPILER=/home/eumakri/Documents/analyzer_opts/build/bin/clang++ \
  -DLLVM_CONFIG_DIR=/home/eumakri/Documents/analyzer_opts/build/bin \
  -DLLVM_SRC_ROOT=/home/eumakri/Documents/analyzer_opts/llvm \
  -DLLVM_OBJ_ROOT=/home/eumakri/Documents/analyzer_opts/build/ \
  -DLLVM_INCLUDE_DIR=/home/eumakri/Documents/analyzer_opts/llvm/include \
  -DLLVM_LIB_DIR=/home/eumakri/Documents/analyzer_opts/build/lib \
  -DCLANG_INCLUDE_DIR=/home/eumakri/Documents/analyzer_opts/clang/include \
  -DCLANG_GENERATED_INCLUDE_DIR=/home/eumakri/Documents/analyzer_opts/build/tools/clang/include \
  ..
