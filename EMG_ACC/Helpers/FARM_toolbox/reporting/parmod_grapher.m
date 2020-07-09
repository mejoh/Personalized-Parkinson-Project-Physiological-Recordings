
% make nicenclean figures -- from ANY kind of parametric modulation.
%
% function fh=parmod_grapher(pmodin,conditions)
%
% make use of this if you'd like to have a nice graph of your parametric
% modulators.

function fh=parmod_grapher(pmodin,conditions)

fh=figure;
for i=1:numel(pmodin)
    

    fieldnames=pmodin(1).name;


    
    legtitle={};
    colors={'r-','b-','g-'};
    for j=1:numel(fieldnames)

        ah=subplot(2,2,i);
        set(ah,'nextplot','add');
        
        m.(fieldnames{j}).d=pmodin(i).param{j};
        m.(fieldnames{j}).s=round(log10(mean(m.(fieldnames{j}).d)));
        
        if numel(m.(fieldnames{j}).d>0)
            
            plot(m.(fieldnames{j}).d/10^(m.(fieldnames{j}).s),colors{j});

            legtitle{j}=[fieldnames{j} ', *10^' num2str(-m.(fieldnames{j}).s)];
            ylim([0 max(m.(fieldnames{j}).d/10^(m.(fieldnames{j}).s))*4]);
        end
        
    end
    
    tmp=legend(legtitle);
    set(findobj(tmp,'fontsize',10),'fontsize',12);
    title(['burst characteristics, condition: ' conditions(i)]);
    
    
end 


set(fh,'position',[0 0 800 600]);
set(findobj(fh,'fontsize',10),'fontsize',12);

