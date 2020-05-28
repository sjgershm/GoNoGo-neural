function [lik, latents] = lik_adaptive(param,data)
    
    % Likelihood function for the Adaptive Bayesian model from Dorfman & Gershman (2019, Nature Communications).
    %
    % USAGE: [lik, latents] = lik_adaptive(param,data)
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
    
    bt = param(1);   % inverse temperature
    mq = param(2);   % prior mean, instrumental
    pq = param(3);   % prior confidence, instrumental
    mv = param(4);   % prior mean, Pavlovian
    pv = param(5);   % prior confidence, Pavlovian
    
    if nargin > 5
        lapse = param(6);
    else
        lapse = 0;
    end
    
    if nargin > 6
        b = param(7);
    else
        b = 0;
    end
    
    u = unique(data.s);
    S = length(u);
    v = zeros(S,1) + mv;
    q = zeros(S,2) + mq;
    Mv = zeros(S,1) + pv;
    Mq = zeros(S,2) + pq;
    lik = 0;
    w0 = 0.5;
    L = log(w0) - log(1-w0);
    
    for n = 1:data.N
        
        s = data.s(n);  % stimulus
        w = 1./(1+exp(-L));
        d = (1-w)*q(s,1) - (1-w)*q(s,2) - b - w*v(s);
        P = 1./(1+exp(-bt*d)); % probability of NoGo
        c = data.a(n);
        r = data.r(n);
        P = (1-lapse)*P + lapse/2;
        
        if c==1
            lik = lik + safelog(P);
        else
            lik = lik + safelog(1-P);
        end
        
        if nargout > 1
            latents.q(n,1) = q(s,1) - q(s,2);
            latents.v(n,1) = v(s);
            latents.d(n,1) = d;
            latents.P(n,1) = P;
            latents.L(n,1) = L;
            if s > 2
                latents.acc(n,1) = P;
            else
                latents.acc(n,1) = 1-P;
            end
        end
        
        if r == 0
            L = L + log(1-abs(v(s))) - log(1-abs(q(s,c)));
        else
            L = L + log(abs(v(s))) - log(abs(q(s,c)));
        end
        
        Mv(s) = Mv(s) + 1;
        Mq(s,c) = Mq(s,c) + 1;
        v(s) = v(s) + (r-v(s))/Mv(s);
        q(s,c) = q(s,c) + (r-q(s,c))/Mq(s,c);
        
    end