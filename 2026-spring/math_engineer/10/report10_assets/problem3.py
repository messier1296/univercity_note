arrival_rates = np.arange(0.1, 0.9, 0.1)

for shape in (1, 2, 4):
    mean_customer_list = []
    for arrival_rate in arrival_rates:
        mean_customers, _, _, _ = simulation_mg1_erlang(
            arrival_rate, shape, shape
        )
        mean_customer_list.append(mean_customers)
    plt.plot(arrival_rates, mean_customer_list, marker="o", label=f"shape={shape}")

plt.xlabel("arrival rate")
plt.ylabel("mean number of customers")
plt.legend()
plt.show()
