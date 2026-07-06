let f0h m l =
  if m <= l && m > 0 then 1
  else 0

let f0 n m =
  if n > 12 || n <= 0 then 0
  else if n = 1 || n = 3 || n = 5 || n = 7 || n = 8 || n = 10 || n = 12 then f0h m 31
  else if n <> 2 then f0h m 30
  else f0h m 28

let f1h n m =
  if n mod m = 0 then m + n / m
  else 0

let rec f1i n m =
  if m = 0 || m * m > n then 0
  else if m * m = n then m
  else f1h n m + f1i n (m + 1)

let f1 n =
  if n <= 0 then 0
  else f1i n 1

let rec gcd n m =
  if n = 0 then m
  else if m = 0 then n
  else if n > m then gcd (n - m) m
  else gcd (m - n) n

let f2i n m =
  if gcd n m = 1 then 1
  else 0

let rec f2h n m =
  if m > n then 0
  else f2i n m + f2h n (m + 1)

let f2 n =
  f2h n 2

let rec f3 n k =
  if k = 0 then n mod 2
  else f3 (n / 2) (k - 1)

let lcm n m =
  n * m / gcd n m

let compose f n m =
  f (f n m)

let f4 n m k =
  compose lcm n m k
