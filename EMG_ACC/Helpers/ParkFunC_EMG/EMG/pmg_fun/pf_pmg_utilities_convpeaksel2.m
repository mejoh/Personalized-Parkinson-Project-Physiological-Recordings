function pf_pmg_utilities_convpeaksel2(conf)
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

% uSub    =   unique(file(:,1)); % If only subjects in the file  
%subjects shown, where I have selceted a peak
uSub    =   cellfun(@(x) str2num(x(2:end)),conf.sub.name);       % If subjects in your configuration-all subjects,even if nothing is selected
nSub    =   length(uSub);

uSess   =   unique(file(:,2));
nSess   =   length(uSess);

uCond   =   unique(file(:,3));
nCond   =   length(uCond);

uSide   =   {'ma';'la'};
nSide   =   length(uSide);

% uType   =   {'move';'tremor'};
% nType   =   length(uType);
warningflag = 1;

%--------------------------------------------------------------------------

%% Run analysis
%--------------------------------------------------------------------------


for m = 1:nSess
    
    CurSess =   uSess(m);
    
    for a = 1:nSub
        
        CurSub  =   uSub(a);
        
        if m == 1
            cnt =   1;
        else 
            cnt =  32;
        end
        
        % --- Retrieve MA hand --- %
        
        subcode   =  ['p' sprintf('%02d',CurSub)];
        iSub      =  strfind(conf.sub.name,subcode);
        mahand    =  conf.sub.hand(~cellfun(@isempty,iSub));
        
        for b = 1:nCond
            
            CurCond  =   uCond(b);
            
            if CurCond==9
                uType    =   {'move';'tremor'};
            elseif CurCond==24
                uType    =   {;'tremor'};
            end
            nType    =   length(uType);
            
            for c = 1:nSide
                
                CurSide  =   uSide{c};
                
                % --- break if rest and LA --- %
                
                if CurCond~=9 && ~strcmp(CurSide,'ma')
                    break
                end
                
                for d = 1:nType
                    
                    CurType  =   uType{d};
                    
                    % --- Retrieve channels, based on CurSide --- %
                    
                    if strcmp(CurSide,'ma') && strcmp(mahand,'R')
                        channels    =   [15 4:5];
                    elseif strcmp(CurSide,'ma') && strcmp(mahand,'L')
                        channels    =   [16 11:12];
                    elseif strcmp(CurSide,'la') && strcmp(mahand,'R')
                        channels    =   [16 11:12];
                    elseif strcmp(CurSide,'la') && strcmp(mahand,'L')
                        channels    =   [15 4:5];
                    end
                    nChan       =   length(channels);
                    
                    % --- Retrieve correct typecode --- %

                    if strcmp(CurSide,'ma') && strcmp(CurType,'move')
                        typecode =   7;
                    elseif strcmp(CurSide,'la') && strcmp(CurType,'move')
                        typecode =   1;
                    elseif strcmp(CurType,'tremor')
                        typecode =   2;
                    end
                    
                    origtypecode = typecode;
                    
                    for e = 1:nChan
                        
                        %[subcode sesscode condcode chancode typecode freq power powerSTD powerCOV powerMIN powerMAX powerNDAT]
                        %[   1       2        3          4       5      6    7       8       9        10        11      12    ]
                        
                        CurChan  =   channels(e);
                        
                        % --- Change typecode because of bug!!!!  Comment this for new peaks--- 30.12.2015 not needed for the MDS poster anymore%
                        
                        if CurCond==9 && strcmp(mahand,'L') && CurChan==15 %&& ~strcmp(CurType,'tremor')
                            typecode = 7;
                            if warningflag
                            warning('convpeaksel:workaround','Using a workaround becaus of R-ACC bug!!')
                            warningflag=0;
                            end
                        else
                            typecode = origtypecode;
                        end
                           
                        % --- END workaround --- %
                        
                        sel      =   file(:,1)==CurSub & file(:,2)==CurSess & file(:,3)==CurCond & file(:,4)==CurChan & file(:,5)==typecode;
                        
                        CurDat   =   file(sel,:);
                        
                        if isempty(CurDat)
                            CurDat = nan(1,12);
                        end
                        
                        % --- Store selected data --- %
                        
                        if cnt==1 || cnt==32
                            storage(a,cnt:cnt+2)    =   [CurSub CurDat(6) CurDat(7)];
                            cnt = cnt+3;
                        else
                            storage(a,cnt:cnt+1)    =   [CurDat(6) CurDat(7)];
                            cnt = cnt+2;
                        end
                        
                    end
                end
            end
        end
    end
end

% --- save file --- %

intersel = storage;
save(fullfile(conf.dir.datsave,conf.util.convert.savename),'intersel') 
















