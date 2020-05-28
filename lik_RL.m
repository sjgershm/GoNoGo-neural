function [lik, latents] = lik_RL(param,data)
    
    % Likelihood function for the RL model from Guitart-Masip et al. (2012, NeuroImage).
    %
    % USAGE: [lik, latents] = lik_RL(param,data)
    %
    % INPUTS:
    %   param - parameter vector
    %   data - data structure for single subject
    %
    % OUTPUTS:
    %   lik - log likelihood
    %   latents - structure containing latent variables
    %
    % Sam Gershman, May 2020
    
    rho = param(1);     % reward weight
    w = param(2);       % Pavlovian weight
    b = param(3);       % Pavlovian bias
    eta = param(4);     % learning rate
    lapse = param(5);   % lapse rate
    
    u = unique(data.s);
    S = length(u);
    v = zeros(S,1);
    q = zeros(S,2);
    lik = 0;
    
    for n = 1:data.N
        
        s = data.s(n);  % stimulus
        d = q(s,1) - q(s,2) - b - w*v(s);
        P = 1./(1+exp(-d)); % probability of NoGo
        P = (1-lapse)*P + lapse/2;
        c = data.a(n);
        r = data.r(n);
        
        if c==1
            lik = lik + safelog(P);
        else
            lik = lik + safelog(1-P);
        end
        
        if nargout > 1
            latents.q(n,:) = q(s,:);
            latents.v(n,1) = v(s);
            latents.P(n,1) = P;
        end
        
        v(s) = v(s) + eta*(rho*r-v(s));
        q(s,c) = q(s,c) + eta*(rho*r-q(s,c));
        
    end