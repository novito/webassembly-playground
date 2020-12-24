(module
  ;; Add function that takes 2 i32 operands and returns an i32
  (func $add (param $lhs i32) (param $rhs i32) (result i32)
    get_local $lhs ;; put first operand in stack (get_local gets a function scoped value and places it in stack)
    get_local $rhs ;; put second operand in stack
    i32.add) ;; call add operator (which pulls two operands from stack and puts result in stack)
  (export "add" (func $add))
)
