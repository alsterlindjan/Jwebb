%% FX IMPLIED DISTRIBUTION FROM VOL SMILE (BLOOMBERG 10D/25D)
% -------------------------------------------------------------------------
% This script constructs an implied risk-neutral probability distribution
% for an FX rate (USD/SEK) using market-implied volatilities obtained from
% Bloomberg (OVDV).
%
% Key features:
% - Uses 10-delta and 25-delta risk reversals and butterflies from Bloomberg
% - Volatility smile is interpolated using a spline (instead of Malz method)
% - The implied distribution is extracted via the second derivative
%   (Hessian) of Black-Scholes option prices with respect to strike
% - Compares the smile-based distribution to a flat-vol Black-Scholes case
%
% Steps:
% 1. Input market data (spot, rates, vol quotes)
% 2. Construct volatility smile as function of delta
% 3. Convert grid of strikes via log-return space
% 4. Map delta -> implied volatility via interpolation
% 5. Compute implied PDF using Hessian of option pricing function
% 6. Normalize PDF and compute CDF
% 7. Visualize distributions and probability of a given level
% -------------------------------------------------------------------------

clear; close all;

%% === Market data (example: 2026-04-13 15:05) ===
r_dom = 2.176 / 100;
r_for = 3.764 / 100;
T     = 1.0;
S0    = 9.3085;

volATM = 10.475 / 100;
vol25C = 11.301 / 100;
vol25P = 10.464 / 100;
vol10C = 12.507 / 100;
vol10P = 10.967 / 100;

%% === Volatility smile (delta space) ===
deltas = [0.10 0.25 0.50 0.75 0.90];
vols   = [vol10P vol25P volATM vol25C vol10C];

volSmile = @(d) interp1(deltas, vols, d, 'spline');
% volSmile = @(d) interp1(deltas, vols, d, 'pchip');  % alternative

%% === Plot smile ===
delta_grid = linspace(0.10, 0.90, 100);
figure;
plot(delta_grid, volSmile(delta_grid) * 100, 'b-', 'LineWidth', 2); hold on;
scatter(deltas, vols * 100, 60, 'r', 'filled');
title('Interpolated Volatility Smile (USD/SEK)');
xlabel('Delta'); ylabel('Implied volatility (%)');
legend('Interpolated smile','Market data','Location','NorthWest');
legend boxoff; grid on;

%% === Strike grid ===
F = S0 * exp((r_dom - r_for) * T);

returns = linspace(-0.5, 0.5, 1000)';
K = F .* exp(returns);

nK = length(K);

sigK = NaN(nK,1);
pdf  = NaN(nK,1);
pdfBS = NaN(nK,1);

%% === Compute implied PDF ===
for i = 1:nK

    X = K(i);

    % --- Delta (ATM approximation) ---
    d = bsdelta(X, S0, r_dom, r_for, T, volATM);

    % Clamp to avoid extrapolation
    d = max(min(d, 0.90), 0.10);

    % --- Local volatility ---
    sigma = volSmile(d);
    sigK(i) = sigma;

    % --- Hessian (implied density) ---
    % NOTE:
    % The volatility sigma is treated as constant in this step.
    % Although sigma depends on strike via delta (smile), this dependence
    % is NOT accounted for in the numerical second derivative.
    % Hence, the method approximates the density using a "locally flat"
    % Black-Scholes volatility at each strike.
    pdf(i)   = hessian(@bscall2, X, S0, r_dom, r_for, T, sigma);
    pdfBS(i) = hessian(@bscall2, X, S0, r_dom, r_for, T, volATM);

end

%% === Normalize distributions ===
pdf   = pdf   / trapz(K, pdf);
pdfBS = pdfBS / trapz(K, pdfBS);

cdf   = cumtrapz(K, pdf);
cdfBS = cumtrapz(K, pdfBS);

%% === Tail probability ===
targetLevel = 0.85 * S0;

idx = find(K >= targetLevel, 1);

probTarget = cdf(idx);

%% === Visualization ===
figure;
plot(K, pdf, 'r-', K, pdfBS, 'r:', 'LineWidth', 2); hold on;

area(K(1:idx), pdf(1:idx), ...
    'FaceColor',[0.15 0.15 0.90], ...
    'FaceAlpha',0.5, ...
    'LineStyle','none');

grid on;
xlabel('USD/SEK');
xlim([6 13]);

legend('Smile-implied distribution','Black-Scholes','Location','NorthEast');
legend boxoff;

% Annotation
text(targetLevel, max(pdf)*0.1, ...
    {sprintf('P(USD/SEK < %.2f)', targetLevel), ...
     sprintf('= %.2f%%', probTarget*100)}, ...
     'FontSize', 9, 'FontWeight', 'bold');
``