%--------------------------------------
% Calculates Garman-Kohlhagen
% FX Call price 
% Input: S0=underlying
%        X=strike
%        rhome=domestic interest rate
%        rstar=foregin interest rate
%        T=time
%        sig=volatility
% 
% Output: call=call price of option
% Jan Alsterlind, Sveriges Riksbank
%---------------------------------------

function call2=bscall2(X,S0,rhome,rstar,T,sig)
  d1=(log(S0/X)+(rhome-rstar+0.5*sig^2)*T)/(sig*sqrt(T));
  d2=(log(S0/X)+(rhome-rstar-0.5*sig^2)*T)/(sig*sqrt(T));
  call2=exp(-rstar*T)*S0*normcdf(d1)-exp(-rhome*T)*X*normcdf(d2);
end

        