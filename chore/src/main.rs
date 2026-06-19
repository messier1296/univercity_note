use std::collections::HashMap;

use proconio::input;
use rand::{self, random_range};

fn main() {
    input! {
        t:usize,
    }
    for _ in 0..t {
        input! {
            a:i64,
            b:i64,
            x:i64,
            y:i64,
        }
        let mut cur = HashMap::new();
        let mut nex = HashMap::new();
        let iteration = (x.abs() + y.abs()) * 2;
        cur.insert((0, 0), 0);
        for i in 1..iteration {
            for (p, value) in cur {
                nex.entry(p)
                    .and_modify(|&mut v| v.min(value))
                    .or_insert(value);
            }
            cur = nex;
        }
    }
}
