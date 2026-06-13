use rand::{self, random_range};

fn main() {
    for _ in 0..10000000 {
        println!("{}", random_range(0..usize::MAX));
    }
}
