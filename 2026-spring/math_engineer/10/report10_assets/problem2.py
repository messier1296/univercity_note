for shape in (1, 2, 4):
    mean_customers, customer_counts, event_times, sojourn_times = (
        simulation_mg1_erlang(0.5, shape, shape)
    )
    plt.plot(event_times, customer_counts, label=f"shape={shape}")

plt.xlabel("time after burn-in")
plt.ylabel("number of customers")
plt.legend()
plt.show()
