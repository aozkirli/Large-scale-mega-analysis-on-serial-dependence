function es = computeHedges_g(x,y)
    % Calculate correction factor for Hedges' g
    n = length(x);
    corr_factor = 1 - (3 / (8 * n - 9));
    
    
    % Calculate Hedges' g
    es = (mean(x - y, 'omitnan') / std(x - y, 'omitnan')) * corr_factor;
end