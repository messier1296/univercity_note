let f0h m l = 
  if m <= l && m > 0 then 1
  else 0

let f0 n m = 
  if n > 12 || n <= 0 then 0
  else if n = 1 || n = 3 || n = 5 || n = 7 || n = 8 || n = 10 || n = 12
    then f0h m 31
  else if  n <> 2 then f0h m 30
  else f0h m 28


let res = print_endline(string_of_int(f0 6 31))
let res = print_endline(string_of_int(f0 7 31))
let res = print_endline(string_of_int(f0 2 29))
