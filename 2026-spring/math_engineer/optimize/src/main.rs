use std::env;
use std::error::Error;
use std::fs;

const CSV_PATH: &str = "spots_tsukuba.csv";
const START_ID: &str = "tsukuba_station";
const INF: f64 = 1.0e18;

#[derive(Clone, Debug)]
struct Spot {
    id: String,
    name: String,
    lat: f64,
    lon: f64,
    indoor_outdoor: String,
    meal_type: String,
    stay_minutes: f64,
    cost_yen: i32,
    tsukuba_score: f64,
    fun_conversation_score: f64,
    photo_memory_score: f64,
    food_rest_score: f64,
    mobility_score: f64,
    cost_score: f64,
    researcher_fit_score: f64,
    calm_score: f64,
    japan_season_score: f64,
    recommended_transport: String,
}

#[derive(Clone, Copy, Debug)]
enum ScenarioKind {
    B,
    C,
}

#[derive(Clone, Debug)]
struct Scenario {
    kind: ScenarioKind,
    label: &'static str,
    transport: &'static str,
    speed_kmh: f64,
    detour_factor: f64,
    max_total_minutes: f64,
    max_move_minutes: f64,
    max_leg_minutes: f64,
    max_cost_yen: i32,
    min_visits: usize,
    max_visits: usize,
    require_meal: bool,
    require_break: bool,
    require_outdoor: bool,
    move_penalty_per_min: f64,
}

#[derive(Clone, Debug)]
struct Candidate {
    spot_index: usize,
    score: f64,
}

#[derive(Clone, Debug)]
struct Solution {
    objective: f64,
    score: f64,
    total_minutes: f64,
    move_minutes: f64,
    stay_minutes: f64,
    cost_yen: i32,
    route: Vec<usize>,
}

fn main() -> Result<(), Box<dyn Error>> {
    let spots = read_spots(CSV_PATH)?;
    let start = spots
        .iter()
        .position(|spot| spot.id == START_ID)
        .ok_or("start spot was not found")?;

    let args: Vec<String> = env::args().collect();
    let scenarios = match args.get(1).map(String::as_str) {
        Some("b") | Some("B") => vec![scenario_b()],
        Some("c") | Some("C") => vec![scenario_c()],
        Some(other) => {
            eprintln!("unknown scenario: {other}");
            eprintln!("usage: cargo run -- [b|c]");
            return Ok(());
        }
        None => vec![scenario_b(), scenario_c()],
    };

    for scenario in scenarios {
        println!("\n=== {} ===", scenario.label);
        match solve_scenario(&spots, start, &scenario) {
            Some(solution) => print_solution(&spots, &scenario, &solution),
            None => println!("条件を満たすルートが見つかりませんでした。"),
        }
    }

    Ok(())
}

fn scenario_b() -> Scenario {
    Scenario {
        kind: ScenarioKind::B,
        label: "(b) 地元の友達が1泊で遊びに来た時",
        transport: "bike",
        speed_kmh: 13.0,
        detour_factor: 1.20,
        max_total_minutes: 420.0,
        max_move_minutes: 90.0,
        max_leg_minutes: 25.0,
        max_cost_yen: 4000,
        min_visits: 4,
        max_visits: 6,
        require_meal: true,
        require_break: true,
        require_outdoor: true,
        move_penalty_per_min: 0.015,
    }
}

fn scenario_c() -> Scenario {
    Scenario {
        kind: ScenarioKind::C,
        label: "(c) 学会で海外から研究者が来た時に，午後空いている時",
        transport: "walk",
        speed_kmh: 4.0,
        detour_factor: 1.15,
        max_total_minutes: 240.0,
        max_move_minutes: 60.0,
        max_leg_minutes: 15.0,
        max_cost_yen: 2000,
        min_visits: 3,
        max_visits: 4,
        require_meal: false,
        require_break: true,
        require_outdoor: true,
        move_penalty_per_min: 0.025,
    }
}

fn solve_scenario(spots: &[Spot], start: usize, scenario: &Scenario) -> Option<Solution> {
    let candidates: Vec<Candidate> = spots
        .iter()
        .enumerate()
        .filter(|(index, spot)| *index != start && is_available_for(spot, scenario))
        .map(|(spot_index, spot)| Candidate {
            spot_index,
            score: scenario_score(spot, scenario),
        })
        .collect();

    let n = candidates.len();
    if n == 0 || n > 62 {
        return None;
    }

    let leg_minutes = build_leg_minutes(spots, start, &candidates, scenario);
    let (dp, parent) = tsp_subset_dp(&leg_minutes);
    let mut best: Option<Solution> = None;

    for mask in 1usize..(1usize << n) {
        let visit_count = mask.count_ones() as usize;
        if visit_count < scenario.min_visits || visit_count > scenario.max_visits {
            continue;
        }

        let mut score = 0.0;
        let mut stay_minutes = 0.0;
        let mut cost_yen = 0;
        let mut has_meal = false;
        let mut has_break = false;
        let mut has_outdoor = false;

        for (i, candidate) in candidates.iter().enumerate() {
            if (mask & (1usize << i)) == 0 {
                continue;
            }
            let spot = &spots[candidate.spot_index];
            score += candidate.score;
            stay_minutes += spot.stay_minutes;
            cost_yen += spot.cost_yen;
            has_meal |= spot.meal_type == "meal" || spot.meal_type == "light_meal";
            has_break |= spot.meal_type == "light_meal" || spot.indoor_outdoor == "outdoor";
            has_outdoor |= spot.indoor_outdoor == "outdoor";
        }

        if scenario.require_meal && !has_meal {
            continue;
        }
        if scenario.require_break && !has_break {
            continue;
        }
        if scenario.require_outdoor && !has_outdoor {
            continue;
        }
        if cost_yen > scenario.max_cost_yen {
            continue;
        }

        let (move_minutes, last) = best_closed_tour_for_mask(mask, n, &dp, &leg_minutes);
        if !move_minutes.is_finite() || move_minutes > scenario.max_move_minutes {
            continue;
        }
        let total_minutes = stay_minutes + move_minutes;
        if total_minutes > scenario.max_total_minutes {
            continue;
        }
        if !all_legs_within_limit(
            mask,
            n,
            &dp,
            &parent,
            &leg_minutes,
            last,
            scenario.max_leg_minutes,
        ) {
            continue;
        }

        let objective = score - scenario.move_penalty_per_min * move_minutes;
        if best
            .as_ref()
            .is_none_or(|solution| objective > solution.objective)
        {
            let route = restore_route(mask, last, &parent, &candidates);
            best = Some(Solution {
                objective,
                score,
                total_minutes,
                move_minutes,
                stay_minutes,
                cost_yen,
                route,
            });
        }
    }

    best
}

fn is_available_for(spot: &Spot, scenario: &Scenario) -> bool {
    if spot.recommended_transport == "walk/bike" {
        return true;
    }
    spot.recommended_transport == scenario.transport
}

fn scenario_score(spot: &Spot, scenario: &Scenario) -> f64 {
    match scenario.kind {
        ScenarioKind::B => {
            0.20 * spot.tsukuba_score
                + 0.25 * spot.fun_conversation_score
                + 0.10 * spot.photo_memory_score
                + 0.20 * spot.food_rest_score
                + 0.15 * spot.mobility_score
                + 0.10 * spot.cost_score
        }
        ScenarioKind::C => {
            0.25 * spot.researcher_fit_score
                + 0.25 * spot.tsukuba_score
                + 0.20 * spot.mobility_score
                + 0.15 * spot.calm_score
                + 0.10 * spot.japan_season_score
                + 0.05 * spot.cost_score
        }
    }
}

fn build_leg_minutes(
    spots: &[Spot],
    start: usize,
    candidates: &[Candidate],
    scenario: &Scenario,
) -> Vec<Vec<f64>> {
    let n = candidates.len();
    let mut minutes = vec![vec![0.0; n + 1]; n + 1];
    let start_node = n;

    for i in 0..n {
        let spot_i = candidates[i].spot_index;
        let start_minutes = travel_minutes(&spots[start], &spots[spot_i], scenario);
        minutes[start_node][i] = start_minutes;
        minutes[i][start_node] = start_minutes;
        for j in 0..n {
            if i == j {
                continue;
            }
            let spot_j = candidates[j].spot_index;
            minutes[i][j] = travel_minutes(&spots[spot_i], &spots[spot_j], scenario);
        }
    }

    minutes
}

fn tsp_subset_dp(leg_minutes: &[Vec<f64>]) -> (Vec<Vec<f64>>, Vec<Vec<Option<usize>>>) {
    let n = leg_minutes.len() - 1;
    let start = n;
    let states = 1usize << n;
    let mut dp = vec![vec![INF; n]; states];
    let mut parent = vec![vec![None; n]; states];

    for last in 0..n {
        dp[1usize << last][last] = leg_minutes[start][last];
    }

    for mask in 1usize..states {
        for last in 0..n {
            if (mask & (1usize << last)) == 0 {
                continue;
            }
            let prev_mask = mask ^ (1usize << last);
            if prev_mask == 0 {
                continue;
            }
            for prev in 0..n {
                if (prev_mask & (1usize << prev)) == 0 {
                    continue;
                }
                let next_cost = dp[prev_mask][prev] + leg_minutes[prev][last];
                if next_cost < dp[mask][last] {
                    dp[mask][last] = next_cost;
                    parent[mask][last] = Some(prev);
                }
            }
        }
    }

    (dp, parent)
}

fn best_closed_tour_for_mask(
    mask: usize,
    n: usize,
    dp: &[Vec<f64>],
    leg_minutes: &[Vec<f64>],
) -> (f64, usize) {
    let start = n;
    let mut best = INF;
    let mut best_last = 0;

    for last in 0..n {
        if (mask & (1usize << last)) == 0 {
            continue;
        }
        let cost = dp[mask][last] + leg_minutes[last][start];
        if cost < best {
            best = cost;
            best_last = last;
        }
    }

    (best, best_last)
}

fn restore_route(
    mut mask: usize,
    mut last: usize,
    parent: &[Vec<Option<usize>>],
    candidates: &[Candidate],
) -> Vec<usize> {
    let mut route = Vec::new();
    loop {
        route.push(candidates[last].spot_index);
        match parent[mask][last] {
            Some(prev) => {
                mask ^= 1usize << last;
                last = prev;
            }
            None => break,
        }
    }
    route.reverse();
    route
}

fn all_legs_within_limit(
    mask: usize,
    n: usize,
    dp: &[Vec<f64>],
    parent: &[Vec<Option<usize>>],
    leg_minutes: &[Vec<f64>],
    last: usize,
    max_leg_minutes: f64,
) -> bool {
    let candidate_route = restore_candidate_route(mask, last, parent);
    let start = n;
    let mut prev = start;

    for &node in &candidate_route {
        if leg_minutes[prev][node] > max_leg_minutes {
            return false;
        }
        prev = node;
    }

    dp[mask][last].is_finite() && leg_minutes[prev][start] <= max_leg_minutes
}

fn restore_candidate_route(
    mut mask: usize,
    mut last: usize,
    parent: &[Vec<Option<usize>>],
) -> Vec<usize> {
    let mut route = Vec::new();
    loop {
        route.push(last);
        match parent[mask][last] {
            Some(prev) => {
                mask ^= 1usize << last;
                last = prev;
            }
            None => break,
        }
    }
    route.reverse();
    route
}

fn travel_minutes(a: &Spot, b: &Spot, scenario: &Scenario) -> f64 {
    let km = haversine_km(a.lat, a.lon, b.lat, b.lon);
    km / scenario.speed_kmh * 60.0 * scenario.detour_factor
}

fn haversine_km(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let r = 6371.0_f64;
    let d_lat = (lat2 - lat1).to_radians();
    let d_lon = (lon2 - lon1).to_radians();
    let lat1 = lat1.to_radians();
    let lat2 = lat2.to_radians();
    let h = (d_lat / 2.0).sin().powi(2) + lat1.cos() * lat2.cos() * (d_lon / 2.0).sin().powi(2);
    2.0 * r * h.sqrt().asin()
}

fn print_solution(spots: &[Spot], scenario: &Scenario, solution: &Solution) {
    println!("目的関数値: {:.3}", solution.objective);
    println!("スポット評価合計: {:.3}", solution.score);
    println!(
        "時間: 合計 {:.1} 分 / 滞在 {:.1} 分 / 移動 {:.1} 分",
        solution.total_minutes, solution.stay_minutes, solution.move_minutes
    );
    println!("費用: {} 円", solution.cost_yen);
    println!("交通手段: {}", scenario.transport);
    println!("ルート:");
    println!(
        "  0. {}",
        spots.iter().find(|spot| spot.id == START_ID).unwrap().name
    );
    for (step, spot_index) in solution.route.iter().enumerate() {
        let spot = &spots[*spot_index];
        println!(
            "  {}. {} 滞在 {:.0}分 費用 {}円",
            step + 1,
            spot.name,
            spot.stay_minutes,
            spot.cost_yen
        );
    }
    println!(
        "  {}. {}",
        solution.route.len() + 1,
        spots.iter().find(|spot| spot.id == START_ID).unwrap().name
    );
}

fn read_spots(path: &str) -> Result<Vec<Spot>, Box<dyn Error>> {
    let text = fs::read_to_string(path)?;
    let mut lines = text.lines();
    let header = lines.next().ok_or("CSV is empty")?;
    let columns: Vec<&str> = header.split(',').collect();
    let mut spots = Vec::new();

    for (line_number, line) in lines.enumerate() {
        if line.trim().is_empty() {
            continue;
        }
        let values = parse_csv_line(line);
        if values.len() != columns.len() {
            return Err(format!(
                "CSV column count mismatch at line {}: expected {}, got {}",
                line_number + 2,
                columns.len(),
                values.len()
            )
            .into());
        }
        spots.push(Spot {
            id: get(&columns, &values, "id")?.to_string(),
            name: get(&columns, &values, "name")?.to_string(),
            lat: parse_f64(&columns, &values, "lat")?,
            lon: parse_f64(&columns, &values, "lon")?,
            indoor_outdoor: get(&columns, &values, "indoor_outdoor")?.to_string(),
            meal_type: get(&columns, &values, "meal_type")?.to_string(),
            stay_minutes: parse_f64(&columns, &values, "stay_minutes")?,
            cost_yen: parse_i32(&columns, &values, "cost_yen")?,
            tsukuba_score: parse_f64(&columns, &values, "tsukuba_score")?,
            fun_conversation_score: parse_f64(&columns, &values, "fun_conversation_score")?,
            photo_memory_score: parse_f64(&columns, &values, "photo_memory_score")?,
            food_rest_score: parse_f64(&columns, &values, "food_rest_score")?,
            mobility_score: parse_f64(&columns, &values, "mobility_score")?,
            cost_score: parse_f64(&columns, &values, "cost_score")?,
            researcher_fit_score: parse_f64(&columns, &values, "researcher_fit_score")?,
            calm_score: parse_f64(&columns, &values, "calm_score")?,
            japan_season_score: parse_f64(&columns, &values, "japan_season_score")?,
            recommended_transport: get(&columns, &values, "recommended_transport")?.to_string(),
        });
    }

    Ok(spots)
}

fn parse_csv_line(line: &str) -> Vec<String> {
    let mut values = Vec::new();
    let mut current = String::new();
    let mut in_quotes = false;
    let mut chars = line.chars().peekable();

    while let Some(ch) = chars.next() {
        match ch {
            '"' if in_quotes && chars.peek() == Some(&'"') => {
                current.push('"');
                chars.next();
            }
            '"' => in_quotes = !in_quotes,
            ',' if !in_quotes => {
                values.push(current);
                current = String::new();
            }
            _ => current.push(ch),
        }
    }

    values.push(current);
    values
}

fn get<'a>(columns: &[&str], values: &'a [String], key: &str) -> Result<&'a str, Box<dyn Error>> {
    let index = columns
        .iter()
        .position(|column| *column == key)
        .ok_or_else(|| format!("missing column: {key}"))?;
    Ok(values[index].as_str())
}

fn parse_f64(columns: &[&str], values: &[String], key: &str) -> Result<f64, Box<dyn Error>> {
    Ok(get(columns, values, key)?.parse()?)
}

fn parse_i32(columns: &[&str], values: &[String], key: &str) -> Result<i32, Box<dyn Error>> {
    Ok(get(columns, values, key)?.parse()?)
}
