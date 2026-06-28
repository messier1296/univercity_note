def simulation_gm1_erlang(service_rate, arrival_rate, shape):
    customers = 0
    time = 0.0
    measured_time = 0.0
    area = 0.0
    next_arrival = erlang(arrival_rate, shape)
    residual_service = math.inf
    arrival_times = deque()
    sojourn_times = []
    customer_counts = []
    event_times = []
    burn_in = 10000

    for state in range(110000):
        customers_before = customers

        if next_arrival <= residual_service:
            interval = next_arrival
            if customers > 0:
                residual_service -= interval
            time += interval
            customers += 1
            arrival_times.append(time)
            next_arrival = erlang(arrival_rate, shape)
            if customers == 1:
                residual_service = exp(service_rate)
        else:
            interval = residual_service
            next_arrival -= interval
            time += interval
            customers -= 1
            arrived_at = arrival_times.popleft()
            if state >= burn_in:
                sojourn_times.append(time - arrived_at)
            residual_service = exp(service_rate) if customers > 0 else math.inf

        if state >= burn_in:
            measured_time += interval
            area += interval * customers_before
            customer_counts.append(customers)
            event_times.append(measured_time)

    mean_customers = area / measured_time
    return mean_customers, customer_counts, event_times, sojourn_times


mean_customers, customer_counts, event_times, sojourn_times = (
    simulation_gm1_erlang(1.25, 2, 2)
)
plt.plot(event_times, customer_counts)
plt.xlabel("time after burn-in")
plt.ylabel("number of customers")
plt.show()
