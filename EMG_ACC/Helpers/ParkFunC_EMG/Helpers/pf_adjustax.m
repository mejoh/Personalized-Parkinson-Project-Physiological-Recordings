function pf_adjustax(h,option)
% 
% pf_adjustax(h,option) adjusts the axes of the (sub)plots with handle h.
% You can use the following options:
%       'maxfig':   All subplots are adjusted to the maximum Ylim of the 
%                   subplot in the figure 
%       'maxrow':   All subplots are adjusted to the maximum Ylim of the 
%                   current row of subplots.
%       'maxcol':   All subplots are adjusted to the maximum Ylim of the 
%                   current column of subplots.
%
% Function is particularly useful for comparing figures: setting the axis
% accordingly is a very useful tool for this.

% ©Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Initiate stuff
%--------------------------------------------------------------------------

nH      =   size(h);
Ylim    =   cell(nH(1),nH(2));

cnt     =   1;

% -------------------------------------------------------------------------

%% Retrieve plot information
%--------------------------------------------------------------------------

for a = 1:prod(nH)
    Ylim{a}   =   get(h(a),'YLim');
end

%--------------------------------------------------------------------------

%% Adjust figure accordingly
%--------------------------------------------------------------------------

switch option
    case 'maxfig'
        
        % --- Calculate Y --- %
        
        Ymax   =   max(max(cellfun(@max,Ylim)));
        Ymin   =   min(min(cellfun(@min,Ylim)));
        Y      =   [Ymin Ymax];
        
        % --- Adjust axis --- %
        
        for a = 1:prod(nH)
            set(h(a),'Ylim',Y)
        end
        
        % === END === %
        
    case 'maxrow'
        
        % --- Calculate Y --- %
        
        Ymax   =   nan(nH(1),1);
        Ymin   =   nan(nH(1),1);
        
        for a = 1:nH(1)
            Ymax(a,1) = max(max(cellfun(@max,Ylim(a,:))));
            Ymin(a,1) = min(min(cellfun(@min,Ylim(a,:))));
        end
        
        Y       =  [Ymin Ymax];
        
        % --- Adjust axis --- %
        
        for a = 1:prod(nH)
            CurY    =   Y(cnt,:);
            set(h(a),'Ylim',CurY)
            cnt     =   cnt+1;
            if mod(cnt,nH(2)) == 0; cnt = 1; end
        end
        
        % === End === %
    
    case 'maxcol'
        
        % --- Calculate Y --- %
        
        Ymax   =   nan(nH(2),2);
        Ymin   =   nan(nH(3),2);
        
        for a = 1:nH(1)
            Ymax(a,1) = max(max(cellfun(@max,Ylim(:,a))));
            Ymin(a,1) = min(min(cellfun(@min,Ylim(:,a))));
        end
        
        Y       =  [Ymin Ymax];
        
        % --- Adjust axis --- %
        
        for a = 1:prod(nH)
            CurY    =   Y(cnt,:);
            set(h(a),'Ylim',CurY)
            if mod(cnt,nH(2)) == 0; cnt = cnt+1; end
        end
        
        % === End === %
        
end
            
            
            
            
        
        
        
        
        
        
        
        
        
        
        

        
        
        
        
        