fn main() {
    let v = [1, 2, 3];
    let mut sm = 0;
    for i in v.iter {
        sm += i;
    }

    let x = v.iter().sum::<i32>();

    println!("sm:{},{}", sm, x);
}
