(module
  (memory $mem 1) ;; indicates that the memory allocated must have at least 1 page (65 KB) of space
;; In order to store the state of the checkers board game, we need (ideally) an 8x8 data structure
;; what comes to mind is a multi-dimensional array, but that doesn't exist in wasm. All we have is linear memory.
;; So the question is, how can we use linear memory to represent what would be a multi-dimensional array?
;; We need to convert an (X,Y) type of coordinate to a (Z) offset. Let's see how we can do this:
;; Imagine a block of memory such as [_,_,_,_,_,_,_,_,_,_,_,_,_,_....], we could say that:
;; Position (0,0) is at offset 0 -> [(0,0),_,_,_,_,_,_,_,_,_,_,_,_,_....]
;; Position (0,1) is at offset 1 -> [(0,0),(0,1),_,_,_,_,_,_,_,_,_,_,_,_....]
;; Position (0,7) is at offset 8 -> [(0,0),(0,1),_,_,_,_,_,(0,7),_,_,_,_,_,_....]
;; Position (1,0) is at offset 9 -> [(0,0),(0,1),_,_,_,_,_,(0,7),(1,0),_,_,_,_,_....]
;; So, we can quickly see that the mapping formula is -> Z = (x + y*8).
;; This will not work, because Webassembly indexes memory by byte
;; So, if we are going to store a number (32 bit -> 4 bytes) in each memory spot, we need to change our mapping to:
;; Z = (x + y*8) * 4 - So, for example, the coordinate (0,1), will be at (1 + 0) * 4 = 4, and the (0,2) => 8
;; Let's write a function (and an auxiliary function) that does that for us:
(func $indexForPosition (param $x i32) (param $y i32) (result i32) 
  (i32.add
    (i32.mul 
      (i32.const 8) (get_local $y)
    )
    (get_local $x)
  )
)
;; Offset = ( x + y * 8 ) * 4
(func $offsetForPosition (param $x i32) (param $y i32) (result i32)
  (i32.mul
    (call $indexForPosition (get_local $x) (get_local $y)) 
    (i32.const 4)
  )
)

;; Now, in each memory slot, we have 32 bits that we can use. How can those represent the state of the cell in the board?
;; 00000000000000000000000000000000 -> This is what we have availabile in each memory spot, so, we can do:
;; If value is 0, it means that cell is empty
;; If value is 1, it means that cell has a black piece
;; If value is 2, it means that cell has a white piece
;; If value is 4, it means that cell has a crowned piece
;; So, examples:
;; How would I represent if the cell has a black-crowned piece? 1+4 = 5
;; How would I represent if the cell has a white-crowned piece? 2+4 = 6
;; So, maximum we are going to be using just 3 bits per cell!
;; Let's write some functions that will use bitwise operators to act upon these cells
;; Notice that these functions don't change the memory slot value. They just return new integers

(global $WHITE i32 (i32.const 2)) 
(global $BLACK i32 (i32.const 1)) 
(global $CROWN i32 (i32.const 4))

;; Determine if a piece has been crowned
;; We perform an AND bitwise operation, between the cell value and the CROWN mask (010), if the result is the CROWN mask, then it means that cell is crowned.
;; Example: Black and crowned = 1+4 = 101 - So, we do the AND operation: 101 & 010 = 010 => YES, it's crowned
;; Example: White and crowned = 2+4 = 110 - So, we do the AND operation: 110 & 010 = 010 => YES, it's crowned
;; Example: Black and not crowned = 001 - So, we do the AND operation: 001 & 010 = 000 => Nopes, not crowned!
(func $isCrowned (param $piece i32) (result i32)
  (i32.eq
    (i32.and (get_local $piece) (get_global $CROWN)) 
    (get_global $CROWN)
  ) 
)
;; Determine if a piece is white
(func $isWhite (param $piece i32) (result i32)
  (i32.eq
    (i32.and (get_local $piece) (get_global $WHITE)) (get_global $WHITE)
  ) 
)
;; Determine if a piece is black
(func $isBlack (param $piece i32) (result i32)
  (i32.eq
    (i32.and (get_local $piece) (get_global $BLACK)) (get_global $BLACK)
  ) 
)
;; Adds a crown to a given piece (no mutation)
(func $withCrown (param $piece i32) (result i32)
  (i32.or (get_local $piece) (get_global $CROWN)) 
)
;; Removes a crown from a given piece (no mutation)
(func $withoutCrown (param $piece i32) (result i32)
  (i32.and (get_local $piece) (i32.const 3)) 
)

(export "offsetForPosition" (func $offsetForPosition))
(export "isCrowned" (func $isCrowned))
(export "isWhite" (func $isWhite))
(export "isBlack" (func $isBlack))
(export "withCrown" (func $withCrown))
(export "withoutCrown" (func $withoutCrown))
)
