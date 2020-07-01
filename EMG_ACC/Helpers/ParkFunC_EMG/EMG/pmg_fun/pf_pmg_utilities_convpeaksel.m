function pf_pmg_utilities_convpeaksel(conf)
% pf_pmg_utilities_convpeaksel(conf) is part of the utilities section of
% the pf_pmg_batch. Specifically, it is a utility to convert peaksel data
% which is stored in a logical matrix into another - for instance Heidi
% friendly - matrix format.
%
% Part of pf_pmg_batch

% © Michiel Dirkx, 2015
% $ParkFunC, version 20150604

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

file    =   load(conf.util.convert.input);
nm      =   fieldnames(file);
file    =   file.(nm{1});

%[subcode sesscode condcode chancode typecode freq power powerSTD powerCOV powerMIN powerMAX powerNDAT]
%[   1       2        3          4       5      6    7       8       9        10        11      12    ]

uSub    =   unique(file(:,1));
nSub    =   length(uSub);

uSess   =   unique(file(:,2));
nSess   =   length(uSess);

uCond   =   unique(file(:,3));
nCond   =   length(uCond);

fprintf('%s\n','Found the following unique condition codes:')
disp(uCond);
in      =   input('Enter here the order for the loop (first set of columns (one condition), second set of columns (one condition) etc.): \n');
uCond   =   in;

cntC    =   3;

%--------------------------------------------------------------------------

%% Loop through all
%--------------------------------------------------------------------------
keyboard
for a = 1:nSess
    
    CurSess = uSess(a);
    
    for b = 1:nCond
        
        CurCond =   uCond(b);
        
        for c = 1:nSub
            
            CurSub  =   uSub(c);
            
            % --- Retrieve MA hand --- %
            
            subcode   =  ['p' sprintf('%02d',CurSub)];
            iSub      =  strfind(conf.sub.name,subcode);
            mahand    =  conf.sub.hand(~cellfun(@isempty,iSub));
            
            if strcmp(mahand,'L')
                handcode =   0;
                CurChan  =   15;         % DIRTY CHANNEL SELECTION
            elseif strcmp(mahand,'R')
                handcode =   1;
                CurChan  =   16;        % 15: R-ACC, 16: L-ACC
            end
            
            if a==1
                    disp('ITS MA') % CHANGE THIS MANUALLY (DIRTY MA/LA SELECTION)
            end
            
            % --- sel --- %
            %[subcode sesscode condcode chancode typecode freq power powerSTD powerCOV powerMIN powerMAX powerNDAT]
            %[   1       2        3          4       5      6    7       8       9        10        11      12    ]
            
            sel =   file(:,2)==CurSess & file(:,3)==CurCond & file(:,1)==CurSub & file(:,4)==CurChan & file(:,5)==2;
            dat =   file(sel,:);
            
            %===FILLIN===%
            DAT(c,1:2)         =   [CurSub handcode];
            DAT(c,cntC:cntC+5) =   [dat(6:9) dat(11) dat(10)];
            
        end
        % --- Prepare for next round ---%
        cntC    =   cntC+6;
    end
    
end

%--------------------------------------------------------------------------

%% Save 
%--------------------------------------------------------------------------

peaksel  =   DAT;
savename =   fullfile(conf.dir.datsave,conf.util.convert.savename);

save(savename,'peaksel');

fprintf('%s\n',['- Saved converted files to ' savename])











