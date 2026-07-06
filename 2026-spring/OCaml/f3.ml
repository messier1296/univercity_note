let rec f3 n k =
  if k = 0 then n mod 2
  else f3 (n / 2) (k-1)

let res = print_endline(string_of_int(f3 11 0))
let res = print_endline(string_of_int(f3 11 1))
let res = print_endline(string_of_int(f3 11 2))
let res = print_endline(string_of_int(f3 11 3))
let res = print_endline(string_of_int(f3 11 4))
