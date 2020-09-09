function plot_figures(fig,data,results)
    
    % Plot results figures.
    %
    % USAGE: plot_figures(fig)
    %
    % To reproduce the figures in the paper, specify fig as one of the
    % following:
    %   'fig2'
    %   'fig3'
    %   'fig4'
    %   'figS1'
    %   'figS2'
    %
    % Sam Gershman, May 2020
    
    N = 6;  % number of quantile bins
    
    switch fig
        
        case 'fig2'
            
            subplot(2,2,1);
            load cavanagh_data
            load results_cavanagh
            h = bar(bms_results.pxp); set(h,'FaceColor','k')
            set(gca,'FontSize',25,'XTickLabel',{'Fixed' 'Adaptive' 'RL'},'YLim',[0 1],'XLim',[0.5 3.5]);
            ylabel('PXP','FontSize',25);
            
            subplot(2,2,3);
            plot_figures('gobias',data,results)
            legend({'Win' 'Avoid'},'FontSize',25,'Location','NorthWest','Box','Off')
            
            subplot(2,2,2);
            load guitartmasip_data
            load results_guitartmasip
            h = bar(bms_results.pxp); set(h,'FaceColor','k')
            set(gca,'FontSize',25,'XTickLabel',{'Fixed' 'Adaptive' 'RL'},'YLim',[0 1],'XLim',[0.5 3.5]);
            ylabel('PXP','FontSize',25);
            
            subplot(2,2,4);
            plot_figures('gobias',data,results)
            
            set(gcf,'Position',[200 200 1000 950]);
            
        case 'fig3'
            
            load cavanagh_data
            load results_cavanagh
            
            for s = 1:length(data)
                L = results(2).latents(s).L;
                w = 1./(1+exp(-L));
                x(s,:) = quantile_stats(data(s).y,w,N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25);
            ylabel('Frontal theta power','FontSize',25);
            xlabel('Weight quantile','FontSize',25);
            
            [~,p,~,stat] = ttest(x(:,1),x(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            
        case 'fig4'
            
            subplot(2,2,1);
            plot_figures('guitartmasip_IFG_weight');
            
            subplot(2,2,2);
            plot_figures('guitartmasip_vmPFC_weight');
            
            subplot(2,2,3);
            plot_figures('guitartmasip_IFG_gonogo');
            
            subplot(2,2,4);
            plot_figures('guitartmasip_vmPFC_gonogo');
            
            set(gcf,'Position',[200 200 1000 950]);
            
        case 'figS1'
            
            load guitartmasip_data.mat
            subplot(1,2,1);
            plot_figures('accuracy',data)
            title('Guitart-Masip et al. (2012)','FontSize',25,'FontWeight','Bold');
            
            load results_guitartmasip_sim.mat
            subplot(1,2,2);
            plot_figures('accuracy',data)
            title('Model simulation','FontSize',25,'FontWeight','Bold');
            
            set(gcf,'Position',[200 200 1000 500])
            
        case 'figS2'
            
            C = 5;
            
            for i = 1:2
                if i ==1
                    load results_cavanagh
                else
                    load results_guitartmasip
                end
                latents = results(2).latents;
                
                for s = 1:length(latents)
                    L = results(2).latents(s).L;
                    w = 1./(1+exp(-L));
                    W(s,:,i) = interval_stats(w,1:length(L),C);
                end
            end
            
            [se,m] = wse(W);
            errorbar(m,se,'LineWidth',4);
            set(gca,'FontSize',25,'XTickLabel',{'1st' '2nd' '3rd' '4th'},'XTick',1:4,'XLim',[0.5 4.5]);
            ylabel('Pavlovian weight','FontSize',25);
            xlabel('Trial epoch (quarters)','FontSize',25);
            legend({'EEG data set' 'fMRI data set'},'FontSize',25);
            
        case 'figS3'
            
            load cavanagh_data
            load results_cavanagh
            
            labels = {'Go-to-win' 'Go-to-avoid' 'NoGo-to-win' 'NoGo-to-avoid'};
            
            for s = 1:length(data)
                L = results(2).latents(s).L;
                w = 1./(1+exp(-L));
                for i = 1:4
                    ix = data(s).s==i;
                    x(s,:,i) = quantile_stats(data(s).y(ix),w(ix),N);
                end
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            Q = repmat(Q',1,4);
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25,'YLim',[-0.4 0.4]);
            ylabel('Frontal theta response','FontSize',25);
            xlabel('Weight quantile','FontSize',25);
            
            legend(labels,'FontSize',20,'Location','NorthWest','Box','Off');
            
        case 'figS4'
            
            load guitartmasip_data
            load results_guitartmasip
            
            regions = {'vmPFC' 'VS' 'IFG'};
            labels = {'Go-to-win' 'Go-to-avoid' 'NoGo-to-win' 'NoGo-to-avoid'};
            
            for j = 1:length(regions)
                for s = 1:length(data)
                    y = data(s).(regions{j});
                    L = results(2).latents(s).L;
                    w = 1./(1+exp(-L));
                    for i = 1:4
                        ix = data(s).s==i;
                        x(s,:,i) = quantile_stats(y(ix),w(ix),N);
                    end
                end
                
                subplot(1,3,j);
                
                [err,m] = wse(x);
                Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
                Q = repmat(Q',1,4);
                errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
                set(gca,'XLim',[0 1],'FontSize',25,'YLim',[-0.4 0.4]);
                ylabel('Response','FontSize',25);
                xlabel('Weight quantile','FontSize',25);
                title(regions{j},'FontSize',25,'FontWeight','Bold');
                
                if j==2
                    legend(labels,'FontSize',20,'Location','NorthWest','Box','Off');
                end
            end
            
            set(gcf,'Position',[200 200 1400 500]);
            
        case 'figS5'
            
            load results_cavanagh.mat
            x = results(2).x;
            load results_guitartmasip.mat
            x = [x; results(2).x];
            L = {'Inverse temperature' 'Instrumental prior mean' 'Instrumental prior confidence' 'Pavlovian prior mean' 'Pavlovian prior confidence'};
            
            for i = 1:size(x,2)
                subplot(2,3,i);
                hist(x(:,i));
                set(gca,'FontSize',25);
                ylabel('Frequency','FontSize',25);
                xlabel(L{i});
            end
            
            set(gcf,'Position',[200 200 1300 600])
            
        case 'gobias_early_late'
            
            c = 40;
            
            for s = 1:length(data)
                trials = (1:data(s).N)';
                ix = trials<=c;
                go_bias(s,1) = mean(data(s).acc(ix&data(s).s==2)) - mean(data(s).acc(ix&data(s).s==4));
                ix = trials>(data(s).N-c);
                go_bias(s,2) = mean(data(s).acc(ix&data(s).s==2)) - mean(data(s).acc(ix&data(s).s==4));
            end
            
            mean(go_bias)
            [~,p,~,stat] = ttest(go_bias)
            
        case 'gobias'
            
            for s = 1:length(data)
                L = results(2).latents(s).L;
                w = 1./(1+exp(-L));
                go_bias = @(ix) mean(data(s).acc(ix&data(s).s==1)) - mean(data(s).acc(ix&data(s).s==3));
                x(s,:,1) = quantile_stats(go_bias,w,N);
                go_bias = @(ix) mean(data(s).acc(ix&data(s).s==2)) - mean(data(s).acc(ix&data(s).s==4));
                x(s,:,2) = quantile_stats(go_bias,w,N);
                
                go_bias = @(ix) mean(results(2).latents(s).acc(ix&data(s).s==1)) - mean(results(2).latents(s).acc(ix&data(s).s==3));
                f(s,:,1) = quantile_stats(go_bias,w,N);
                go_bias = @(ix) mean(results(2).latents(s).acc(ix&data(s).s==2)) - mean(results(2).latents(s).acc(ix&data(s).s==4));
                f(s,:,2) = quantile_stats(go_bias,w,N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            C = linspecer(2);
            errorbar(Q,m(:,1),err(:,1),'o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w','Color',C(1,:)); hold on
            errorbar(Q,m(:,2),err(:,2),'o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w','Color',C(2,:))
            m = squeeze(nanmean(f));
            plot(Q,m(:,1),'-','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w','Color',C(1,:))
            plot(Q,m(:,2),'-','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w','Color',C(2,:))
            set(gca,'XLim',[0 1],'FontSize',25);
            ylabel('Go bias','FontSize',25);
            xlabel('Weight quantile','FontSize',25);
            
            [~,p,~,stat] = ttest(squeeze(x(:,1,1)),squeeze(x(:,end,1)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            [~,p,~,stat] = ttest(squeeze(x(:,1,2)),squeeze(x(:,end,2)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            z = squeeze(x(:,:,1)-x(:,:,2));
            [~,p,~,stat] = ttest(z(:,1),z(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            z = squeeze(mean(x,3));
            [~,p,~,stat] = ttest(z(:,1),z(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
         
        case 'accuracy'
            
            for s = 1:length(data)
                for i = 1:4
                    ix = data(s).s==i;
                    acc(s,i) = mean(data(s).acc(ix));
                end
            end
            
            [se,m] = wse(acc);
            barerrorbar(m',se');
            colormap bone
            set(gca,'XTickLabel',{'Go-to-win' 'Go-to-avoid' 'NoGo-to-win' 'NoGo-to-avoid'},'FontSize',25,'XLim',[0.5 4.5]);
            ylabel('Probability correct','FontSize',25);
            xtickangle(gca,45);
            
        case 'cavanagh_pavbias_individual'
            
            load cavanagh_data
            load results_cavanagh
            
            for s = 1:length(data)
                rew_go = sum(data(s).a(data(s).s==1|data(s).s==3)==2)./sum(data(s).a==2);
                pun_nogo = sum(data(s).a(data(s).s==2|data(s).s==4)==1)./sum(data(s).a==1);
                pav_bias(s,1) = 0.5*rew_go + 0.5*pun_nogo;
                L = results(2).latents(s).L;
                w = 1./(1+exp(-L));
                W(s,1) = mean(w);
                x = quantile_stats(data(s).y,w,N);
                d(s,1) = x(1)-x(end);
            end
            
            [r,p] = corr(pav_bias(ix),d(ix))
        
        case 'guitartmasip_IFG_weight'
            
            load guitartmasip_data
            load results_guitartmasip
            
            N = 6;
            
            for s = 1:length(data)
                L = results(2).latents(s).L;
                w = 1./(1+exp(-L));
                ix = data(s).s<3;
                x(s,:,1) = quantile_stats(data(s).IFG(ix),w(ix),N);
                ix = data(s).s>=3;
                x(s,:,2) = quantile_stats(data(s).IFG(ix),w(ix),N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            Q = repmat(Q',1,2);
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25);
            ylabel('IFG response','FontSize',25);
            xlabel('Weight quantile','FontSize',25);
            legend({'Go' 'NoGo'},'FontSize',25,'Location','North','Box','Off')
            
            [~,p,~,stat] = ttest(squeeze(x(:,1,1)),squeeze(x(:,1,2)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            [~,p,~,stat] = ttest(squeeze(x(:,end,1)),squeeze(x(:,end,2)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            [~,p,~,stat] = ttest(squeeze(x(:,1,1)),squeeze(x(:,end,1)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            [~,p,~,stat] = ttest(squeeze(x(:,1,2)),squeeze(x(:,end,2)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            x = squeeze(x(:,:,1)-x(:,:,2));
            [~,p,~,stat] = ttest(x(:,1),x(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            
        case 'guitartmasip_IFG_gonogo'
            
            load guitartmasip_data
            load results_guitartmasip
            
            N = 6;
            
            for s = 1:length(data)
                P = results(2).latents(s).P;
                x(s,:) = quantile_stats(data(s).IFG,P,N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25);
            ylabel('IFG response','FontSize',25);
            xlabel('P(NoGo) quantile','FontSize',25);
            
            [~,p,~,stat] = ttest(x(:,1),x(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            
        case 'guitartmasip_vmPFC_weight'
            
            load guitartmasip_data
            load results_guitartmasip
            
            for s = 1:length(data)
                L = results(2).latents(s).L;
                %w = 1./(1+exp(-L));
                w = results(2).latents(s).acc;
                ix = data(s).s==1|data(s).s==3;
                x(s,:,1) = quantile_stats(data(s).vmPFC(ix),w(ix),N);
                ix = data(s).s==2|data(s).s==4;
                x(s,:,2) = quantile_stats(data(s).vmPFC(ix),w(ix),N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            Q = repmat(Q',1,2);
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25);
            ylabel('vmPFC response','FontSize',25);
            xlabel('Weight quantile','FontSize',25);
            legend({'Win' 'Avoid'},'FontSize',25,'Location','North','Box','Off')
            
            [~,p,~,stat] = ttest(squeeze(x(:,1,1)),squeeze(x(:,end,1)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            [~,p,~,stat] = ttest(squeeze(x(:,1,2)),squeeze(x(:,end,2)));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            z = squeeze(x(:,:,1)-x(:,:,2));
            [~,p,~,stat] = ttest(z(:,1),z(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            z = squeeze(mean(x,3));
            [~,p,~,stat] = ttest(z(:,1),z(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            z = squeeze(mean(x,2));
            [~,p,~,stat] = ttest(z(:,1),z(:,2));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            
        case 'guitartmasip_vmPFC_gonogo'
            
            load guitartmasip_data
            load results_guitartmasip
            
            N = 6;
            
            for s = 1:length(data)
                P = results(2).latents(s).P;
                x(s,:) = quantile_stats(data(s).vmPFC,P,N);
            end
            
            [err,m] = wse(x);
            Q = linspace(0,1,N); Q = Q(1:end-1)+diff(Q)/2;
            errorbar(Q,m,err,'-o','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w')
            set(gca,'XLim',[0 1],'FontSize',25,'YLim',[-0.2 0.2]);
            ylabel('IFG response','FontSize',25);
            xlabel('P(NoGo) quantile','FontSize',25);
            
            [~,p,~,stat] = ttest(x(:,1),x(:,end));
            disp(['t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)])
            
        case 'parameter_correlations'
            
            for i = 1:2
                if i == 1
                    load results_cavanagh
                    T = 'cavanagh';
                else
                    load results_guitartmasip
                    T = 'guitartmasip';
                end
                
                latents = results(2).latents;
                rv = zeros(size(latents));
                rq = zeros(size(latents));
                
                for s = 1:length(latents)
                    L = latents(s).L; w = 1./(1+exp(-L));
                    v = latents(s).v;
                    q = latents(s).q;
                    rv(s) = corr(v,w);
                    rq(s) = corr(q,w);
                end
                
                p = signrank(rv);
                disp([T,': median r(v,w) = ',num2str(median(rv)),', p = ',num2str(p)]);
                p = signrank(rq);
                disp([T,': median r(q,w) = ',num2str(median(rq)),', p = ',num2str(p)]);
            end
    end
    
end

function [m,se,X] = quantile_stats(x,y,N)
    
    q = quantile(y,N);
    
    for i = 1:length(q)-1
        ix = y>q(i) & y<=q(i+1);
        X{i} = x(ix);
        m(i) = nanmean(x(ix));
        se(i) = nanstd(x(ix))./sqrt(sum(~isnan(x(ix))));
    end
    
end

function [m,se,X] = interval_stats(x,y,N)
    
    q = linspace(min(y),max(y),N);
    
    for i = 1:length(q)-1
        ix = y>q(i) & y<=q(i+1);
        X{i} = x(ix);
        m(i) = nanmean(x(ix));
        se(i) = nanstd(x(ix))./sqrt(sum(~isnan(x(ix))));
    end
end