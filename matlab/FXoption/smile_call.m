function price = smile_call(K, S0, r_dom, r_for, T, volSmile, volATM)

    % Compute delta (using ATM vol as initial approximation)
    d = bsdelta(K, S0, r_dom, r_for, T, volATM);
    
    % Clamp to interpolation range
    d = max(min(d, 0.90), 0.10);
    
    % Get volatility from smile
    sigma = volSmile(d);
    
    % Compute call price
    price = bscall2(K, S0, r_dom, r_for, T, sigma);

end