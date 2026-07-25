let g1 l =
  let sum = List.fold_left ( +. ) 0. l in
  sum /. float_of_int (List.length l)

let g2 l =
  let average = g1 l in
  let sum = List.fold_left (fun acc x -> acc +. (x -. average) ** 2.) 0. l in
  sum /. float_of_int (List.length l)

let g3 l =
  match l with
  | [] -> 0
  | _ ->
      let threshold = g1 l +. sqrt (g2 l) in
      List.fold_left (fun acc x -> if x >= threshold then acc + 1 else acc) 0 l

let g4 l =
  List.map (fun f -> f 3) l

let g5 l =
  List.fold_right (fun f acc -> f acc) l 3
