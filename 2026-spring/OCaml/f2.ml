let rec gcd n m = 
  if n = 0 then m
  else if m = 0 then n
  else if n > m then gcd(n-m) m
  else gcd(m-n) n

let f2i n m = 
  if gcd n m = 1 then 1
  else 0

let  rec f2h n m =
  if m > n then 0
  else f2i n m +  f2h n (m+1) 

let f2 n = 
  f2h n 2


let res = print_endline(string_of_int(f2 6))
let res = print_endline(string_of_int(f2 24))
let res = print_endline(string_of_int(f2 100))
