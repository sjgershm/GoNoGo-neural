function [results, bms_results] = fit_models(data,models,results)
    
    % Fit models to Go/NoGo data. Requires mfit package (https://github.com/sjgershm/mfit/).
    %
    % USAGE: [results, bms_results] = fit_models(data,[models],[results])
    %
    % INPUTS:
    %   data - multi-subject data structure
    %   models (optional) - 1 (fixed Bayesian), 2 (adaptive Bayesian), or 3 (RL)
    %
    % OUTPUTS:
    %   results - results structure
    %   bms_results - random effects model selection structure
    %
    % Sam Gershman, May 2020
    
    likfuns = {'lik_fixed' 'lik_adaptive' 'lik_RL'};
    
    if nargin < 2; models = 1:length(likfuns); end
    
    pmin = 0.01;    % minimum prior confidence
    pmax = 100;     % maximum prior confidence
    btmin = 1e-3;   % minimum inverse temperature
    btmax = 50;     % maximum inverse temperature
    
    for mi = 1:length(models)
        m = models(mi);
        disp(['... fitting model ',num2str(m)]);
        fun = str2func(likfuns{m});
        
        switch likfuns{m}
            
            case 'lik_fixed'
                
                param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','w','logpdf',@(x) 0,'lb',0.001,'ub',0.999);
                param(3) = struct('name','mq','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(4) = struct('name','pq','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                param(5) = struct('name','mv','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(6) = struct('name','pv','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                
            case 'lik_adaptive'
                
                param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','mq','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(3) = struct('name','pq','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                param(4) = struct('name','mv','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(5) = struct('name','pv','logpdf',@(x) 0,'lb',pmin,'ub',pmax);

                
            case 'lik_RL'
                
                param(1) = struct('name','rho','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','w','logpdf',@(x) 0,'lb',0,'ub',10);
                param(3) = struct('name','b','logpdf',@(x) 0,'lb',-5,'ub',5);
                param(4) = struct('name','eta','logpdf',@(x) 0,'lb',0.001,'ub',0.999);
                param(5) = struct('name','lapse','logpdf',@(x) 0,'lb',0,'ub',0.2);
                
        end
        
        results(m) = mfit_optimize(fun,param,data);
        clear param
    end
    
    % Bayesian model selection
    if nargout > 1
        bms_results = mfit_bms(results,1);
    end