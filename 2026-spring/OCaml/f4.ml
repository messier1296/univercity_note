let rec gcd n m = 
  if n = 0 then m
  else if m = 0 then n
  else if n > m then gcd(n-m) m
  else gcd(m-n) n

let lcm n m =
  n * m / gcd n m

let compose f n m = f (f n m)

let f4 n m k = compose  lcm n m k


let res = print_endline(string_of_int(f4 9 2 6))

