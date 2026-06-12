%--------------------------------------
% Calculates Garman-Kohlhagen
% FX Call Delta
%
% Input: S0=underlying
%        X=strike
%        rhome=domestic interest rate
%        rstar=foreign interest rate
%        T=time
%        sig=volatility
%
% Output: delta=call option delta
% Jan Alsterlind, Sveriges Riksbank
%---------------------------------------

function delta = bsdelta(X, S0, rhome, rstar, T, sig)
  d1 = (log(S0./X) + (rhome - rstar + 0.5*sig.^2)*T) ...
       / (sig*sqrt(T));
  delta = exp(-rstar*T) * normcdf(d1);
end