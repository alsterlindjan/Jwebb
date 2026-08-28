
# In this example, we start from a given gamma variance in CreditRisk+.
# The asset correlation rho in the Vasicek model is determined SOLELY
# through a numerical calibration that matches the 99% quantile (VaR_99).
#
# Mean values and VaR_99 are then calculated and compared across the two
# models based on this numerical mapping.
#
# No analytical variance-matching approach is used in this example.
#
# File developed for Spider


import numpy as np
from scipy.stats import norm
from scipy.optimize import bisect

np.random.seed(42)

# -------------------------------------------------
# Portfolio
# -------------------------------------------------
n_exposures = 10_000
pd = 0.01
n_sims = 50_000

# -------------------------------------------------
# Assumed gamma variance in CreditRisk+
# -------------------------------------------------
CV2 = 0.50
CV = np.sqrt(CV2)

# -------------------------------------------------
# CreditRisk+
# -------------------------------------------------
def cr_stats(CV2):
    E_Lambda = n_exposures * pd
    alpha = 1 / CV2
    beta = E_Lambda / alpha

    Lambda = np.random.gamma(alpha, beta, n_sims)
    N = np.random.poisson(Lambda)

    return np.mean(N), np.quantile(N, 0.99)

CR_mean, CR_q99 = cr_stats(CV2)

# -------------------------------------------------
# Vasicek (ASRF)
# -------------------------------------------------
Z = np.random.randn(n_sims)
c = norm.ppf(pd)

def vas_stats(rho):
    p_Z = norm.cdf((c - np.sqrt(rho) * Z) / np.sqrt(1 - rho))
    N = n_exposures * p_Z
    return np.mean(N), np.quantile(N, 0.99)

# -------------------------------------------------
# Numerical mapping: determine rho by matching 
# the 99% quantile (VaR_99).
# -------------------------------------------------
def objective(rho):
    _, q99 = vas_stats(rho)
    return q99 - CR_q99

rho_star = bisect(objective, 0.001, 0.50)

VAS_mean, VAS_q99 = vas_stats(rho_star)

# -------------------------------------------------
# Results
# -------------------------------------------------
print("Starting point: CreditRisk+")
print(f"  CV^2                 : {CV2:.2f}")
print(f"  Mean                 : {CR_mean:.1f}")
print(f"  VaR 99%              : {CR_q99:.1f}")

print("\nNumerically matched Vasicek model")
print(f"  Implied rho          : {rho_star:.3f}")
print(f"  Mean                 : {VAS_mean:.1f}")
print(f"  VaR 99%              : {VAS_q99:.1f}")
