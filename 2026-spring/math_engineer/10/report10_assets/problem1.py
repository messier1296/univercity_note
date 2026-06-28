for i in range(8):
    y = 2 ** i
    x = y / 20
    k = np.linspace(0,100,10001)
    p = []

    for j in k:
        pdf = ((x**y)/math.factorial(y-1))*(j**(y-1))*np.exp(-x*j)
        p.append(pdf)

    plt.plot(k,p,label=f"shape={y}")

plt.xlabel("k")
plt.ylabel("Probability density")
plt.title("Erlang distributions with mean 20")
plt.legend()
plt.show()
