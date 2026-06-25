function [yzero] = NSS(betavec,mat)
%% NSS  Compute Nelson–Siegel–Svensson (NSS) zero-coupon yields
%
%   YZERO = NSS(BETAVEC, MAT) evaluates the Nelson–Siegel–Svensson yield
%   curve for the given parameter vector BETAVEC and maturity MAT.
%
%   Inputs:
%       betavec : N-by-6 matrix of NSS parameters, where each row contains
%                 [beta0, beta1, beta2, beta3, tau1, tau2]
%       mat     : Scalar maturity (in years) at which the yield is evaluated
%
%   Output:
%       yzero   : N-by-1 vector of zero-coupon yields corresponding to MAT
%
%   Model:
%       The NSS yield is computed as:
%
%           y(t) = beta0
%                + beta1 * (1 - exp(-t/tau1)) / (t/tau1)
%                + beta2 * [(1 - exp(-t/tau1)) / (t/tau1) - exp(-t/tau1)]
%                + beta3 * [(1 - exp(-t/tau2)) / (t/tau2) - exp(-t/tau2)]
%
%   Notes:
%       - BETAVEC may contain multiple rows; the function evaluates all rows
%         at the same maturity MAT.
%       - MAT is assumed to be strictly positive.
%
% _Jan Alsterlind 2025_
 
beta0=betavec(:,1); beta1=betavec(:,2); beta2=betavec(:,3);
beta3=betavec(:,4); tau1=betavec(:,5); tau2=betavec(:,6);
yzero=beta0 ...
   +beta1*(1-exp(-mat/tau1))/(mat/tau1) ...
   +beta2*((1-exp(-mat/tau1))/(mat/tau1)-exp(-mat/tau1)) ...
   +beta3*((1-exp(-mat/tau2))/(mat/tau2)-exp(-mat/tau2));
end

