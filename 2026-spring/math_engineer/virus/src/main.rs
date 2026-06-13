use plotters::prelude::*;
use std::error::Error;
use std::fs::File;
use std::io::Write;

const MINUTES: usize = 60;
const TRIALS: usize = 10_000;
const SAFE_TRIALS: usize = 100;
const THRESHOLD: f64 = 15.0;

#[derive(Clone, Copy)]
struct SeriesStyle {
    label: &'static str,
    color: RGBColor,
}

fn main() -> Result<(), Box<dyn Error>> {
    let mask_series = vec![
        ("no_mask", "No mask", 1.0, SeriesStyle { label: "No mask", color: RED }),
        (
            "urethane",
            "Urethane mask",
            0.60,
            SeriesStyle { label: "Urethane mask", color: BLUE },
        ),
        (
            "nonwoven",
            "Non-woven mask",
            0.25,
            SeriesStyle { label: "Non-woven mask", color: GREEN },
        ),
    ];

    let distances = distances(0.5, 2.0, 0.1);
    let mut result_csv = String::from("experiment,condition,x,y\n");

    let mut mask_results = Vec::new();
    for (key, _label, mask_factor, style) in mask_series {
        let mut points = Vec::new();
        for &dist in &distances {
            let p = infection_probability(dist, TRIALS, mask_factor, 1.0, seed_for(key, dist));
            result_csv.push_str(&format!("mask,{},{:.1},{:.4}\n", key, dist, p));
            points.push((dist, p));
        }
        mask_results.push((style, points));
    }
    draw_probability_chart(
        "mask_effect.png",
        "Mask effect",
        "distance (m)",
        &mask_results,
        0.5..2.0,
    )?;

    let mut virulence_results = Vec::new();
    for multiplier in 1..=5 {
        let key = format!("x{}", multiplier);
        let style = SeriesStyle {
            label: match multiplier {
                1 => "x1",
                2 => "x2",
                3 => "x3",
                4 => "x4",
                _ => "x5",
            },
            color: match multiplier {
                1 => BLUE,
                2 => GREEN,
                3 => RGBColor(230, 130, 0),
                4 => MAGENTA,
                _ => RED,
            },
        };
        let mut points = Vec::new();
        for &dist in &distances {
            let p = infection_probability(dist, TRIALS, 1.0, multiplier as f64, seed_for(&key, dist));
            result_csv.push_str(&format!("virulence,{},{:.1},{:.4}\n", key, dist, p));
            points.push((dist, p));
        }
        virulence_results.push((style, points));
    }
    draw_probability_chart(
        "virulence_effect.png",
        "Virulence effect without masks",
        "distance (m)",
        &virulence_results,
        0.5..2.0,
    )?;

    let mut safe_points = Vec::new();
    for step in 0..=8 {
        let multiplier = 1.0 + step as f64 * 0.5;
        let safe_dist = first_safe_distance(multiplier);
        result_csv.push_str(&format!(
            "safe_distance,{:.1},{:.1},{:.1}\n",
            multiplier, multiplier, safe_dist
        ));
        safe_points.push((multiplier, safe_dist));
    }
    draw_safe_distance_chart("safe_distance.png", &safe_points)?;

    File::create("results.csv")?.write_all(result_csv.as_bytes())?;
    println!("created mask_effect.png, virulence_effect.png, safe_distance.png, results.csv");
    Ok(())
}

fn distances(start: f64, end: f64, step: f64) -> Vec<f64> {
    let mut xs = Vec::new();
    let mut x = start;
    while x <= end + 1e-9 {
        xs.push((x * 10.0).round() / 10.0);
        x += step;
    }
    xs
}

fn infection_probability(
    dist: f64,
    trials: usize,
    mask_factor: f64,
    virulence: f64,
    seed: u64,
) -> f64 {
    let mut rng = SimpleRng::new(seed);
    let mut infected = 0usize;
    for _ in 0..trials {
        let mut exposure = 0.0;
        for _ in 0..MINUTES {
            let a_speaks = rng.next_bool();
            if a_speaks {
                exposure += virulence * mask_factor / dist.powi(3);
            }
        }
        if exposure >= THRESHOLD {
            infected += 1;
        }
    }
    infected as f64 / trials as f64
}

fn first_safe_distance(virulence: f64) -> f64 {
    for dist in distances(0.5, 5.0, 0.1) {
        let p = infection_probability(dist, SAFE_TRIALS, 1.0, virulence, seed_for("safe", dist + virulence));
        if p == 0.0 {
            return dist;
        }
    }
    5.0
}

fn seed_for(label: &str, value: f64) -> u64 {
    let mut seed = 0xcbf29ce484222325u64;
    for b in label.bytes() {
        seed ^= b as u64;
        seed = seed.wrapping_mul(0x100000001b3);
    }
    seed ^ ((value * 1000.0).round() as u64)
}

struct SimpleRng {
    state: u64,
}

impl SimpleRng {
    fn new(seed: u64) -> Self {
        Self { state: seed }
    }

    fn next_bool(&mut self) -> bool {
        self.state = self
            .state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        (self.state >> 63) == 1
    }
}

fn draw_probability_chart(
    filename: &str,
    title: &str,
    x_label: &str,
    series: &[(SeriesStyle, Vec<(f64, f64)>)],
    x_range: std::ops::Range<f64>,
) -> Result<(), Box<dyn Error>> {
    let root = BitMapBackend::new(filename, (1000, 700)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        .caption(title, ("sans-serif", 34).into_font())
        .margin(28)
        .x_label_area_size(55)
        .y_label_area_size(70)
        .build_cartesian_2d(x_range, 0.0f64..1.05f64)?;

    chart
        .configure_mesh()
        .x_desc(x_label)
        .y_desc("infection probability")
        .x_labels(16)
        .y_labels(11)
        .label_style(("sans-serif", 18))
        .axis_desc_style(("sans-serif", 22))
        .draw()?;

    for (style, points) in series {
        chart
            .draw_series(LineSeries::new(points.iter().copied(), style.color.stroke_width(4)))?
            .label(style.label)
            .legend(move |(x, y)| {
                PathElement::new(vec![(x, y), (x + 35, y)], style.color.stroke_width(4))
            });
        chart.draw_series(
            points
                .iter()
                .map(|&(x, y)| Circle::new((x, y), 4, style.color.filled())),
        )?;
    }

    chart
        .configure_series_labels()
        .background_style(WHITE.mix(0.9))
        .border_style(BLACK)
        .label_font(("sans-serif", 20))
        .draw()?;
    root.present()?;
    Ok(())
}

fn draw_safe_distance_chart(filename: &str, points: &[(f64, f64)]) -> Result<(), Box<dyn Error>> {
    let root = BitMapBackend::new(filename, (1000, 700)).into_drawing_area();
    root.fill(&WHITE)?;
    let mut chart = ChartBuilder::on(&root)
        .caption("Safe distance by virulence", ("sans-serif", 34).into_font())
        .margin(28)
        .x_label_area_size(55)
        .y_label_area_size(70)
        .build_cartesian_2d(1.0f64..5.0f64, 0.5f64..5.0f64)?;

    chart
        .configure_mesh()
        .x_desc("virulence multiplier")
        .y_desc("safe distance (m)")
        .x_labels(9)
        .y_labels(10)
        .label_style(("sans-serif", 18))
        .axis_desc_style(("sans-serif", 22))
        .draw()?;

    chart.draw_series(LineSeries::new(points.iter().copied(), RED.stroke_width(4)))?;
    chart.draw_series(
        points
            .iter()
            .map(|&(x, y)| Circle::new((x, y), 5, RED.filled())),
    )?;
    root.present()?;
    Ok(())
}
