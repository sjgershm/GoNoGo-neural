function y = safelog(x)
    
    % Natural logarithm, setting log(0) to log(realmin).
    
    x(x==0) = realmin;
    y = log(x);