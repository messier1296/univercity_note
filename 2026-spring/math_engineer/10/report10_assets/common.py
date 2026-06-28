import math
from collections import deque

import matplotlib.pyplot as plt
import numpy as np
import numpy.random as random

random.seed(2026)


def exp(rate):
    return -math.log(random.random()) / rate


def erlang(rate, shape):
    value = 0
    for _ in range(shape):
        value += exp(rate)
    return value


def simulation_mg1_erlang(arrival_rate, service_rate, shape):
    customers = 0
    time = 0.0
    measured_time = 0.0
    area = 0.0
    next_arrival = exp(arrival_rate)
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
            next_arrival = exp(arrival_rate)
            if customers == 1:
                residual_service = erlang(service_rate, shape)
        else:
            interval = residual_service
            next_arrival -= interval
            time += interval
            customers -= 1
            arrived_at = arrival_times.popleft()
            if state >= burn_in:
                sojourn_times.append(time - arrived_at)
            residual_service = (
                erlang(service_rate, shape) if customers > 0 else math.inf
            )

        if state >= burn_in:
            measured_time += interval
            area += interval * customers_before
            customer_counts.append(customers)
            event_times.append(measured_time)

    mean_customers = area / measured_time
    return mean_customers, customer_counts, event_times, sojourn_times
