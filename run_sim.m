function simdata = run_sim
    
    % Conditions:
    % 1: GotoWin
    % 2: GotoAvoid
    % 3: NoGotoWin
    % 4: NoGotoAvoid
    
    load guitartmasip_data.mat
    load results_guitartmasip.mat
    
    for s = 1:length(data)
        D = data(s);
        %D.R = [0.3 0.7; 0.3 0.7; 0.7 0.3; 0.7 0.3];
        D.R = [0.2 0.8; 0.2 0.8; 0.8 0.2; 0.8 0.2];
        simdata(s) = sim_adaptive(results(2).x(s,:),D);
    end
    
    for s = 1:length(data)
        simdata(s).acc = (simdata(s).s<3&simdata(s).a==2) | (simdata(s).s>2&simdata(s).a==1);
    end