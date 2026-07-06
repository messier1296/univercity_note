let f1h n m = 
  if n mod m = 0 then m + n / m
  else 0

let rec f1i n m = 
  if m = 0 || m * m > n then 0
  else if m * m = n then m
  else f1h n m + f1i n (m+1)

let f1 n = 
  if n <= 0 then 0
  else f1i n 1


let res = print_endline(string_of_int(f1 6))
let res = print_endline(string_of_int(f1 24))
let res = print_endline(string_of_int(f1 100))
