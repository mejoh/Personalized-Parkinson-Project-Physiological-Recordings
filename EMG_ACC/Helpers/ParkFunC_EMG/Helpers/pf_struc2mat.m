function [MAT,colhdr] = pf_struc2mat(struc,fields)
%
% convert PMG analyzed structure to a matrix.
%
%
% © Michiel Dirkx, 2014

%% Warming up

if nargin<1
    load('/home/action/micdir/data/PMG/analysis/powspct_dat/Ana_seltremor-move_Rest-CoCo-MoCo_first_p08etc.mat');
    struc = intersel;
end


%% Configuration

if nargin<2
    
    fields    = {
        {'p31';};%'p02';'p03';'p04';'p05';'p06';'p07';'p08';'p09';'p10';
        %                'p11';'p12';'p13';'p14';'p15';'p16';'p17';'p18';'p19';'p20';
        %                'p21';'p22';'p23';'p24';'p25';'p26';'p27';'p28';'p29';'p30';
        % 			   'p31';'p32';'p33';'p34';'p35';'p36';'p37';'p38';'p39';'p40';
        % 			   'p41';'p42';'p43';'p44';'p45';'p46';'p47';'p48';};
        
        {'OFF';'ON'};
        
        {'Rest1';'RestCOG1';'RestmoM1';'RestmoL1';'EntrM';'EntrL';
        'Rest2';'RestCOG2';'RestmoM2';'RestmoL2';
        'Rest3';'RestCOG3';'RestmoM3';'RestmoL3';};
        
        {'RighAccelerometer';'LeftAccelerometer'};
        
        {'move';'tremor';'harmonmv';'harmontr'};
        
        {'freq';'pow';'powstd';'powcov';'type'};
        };
    
end

%% Initialize

nFields     =   length(fields);
nnFields    =   nan(nFields,1);
for a = 1:nFields
    nnFields(a)     =   length(fields{a});
end

% MAT         =   nan(prod(nnFields(1:end-1)),9);
cnt         =   1;

%% Convert everything

if nFields>6
    error('struc2mat:nfields','This (crappy) script can currently only handle 6 fields')
end

Sub       =   fieldnames(struc);
nSub      =   length(Sub);

for a = 1:nSub
    
    CurSub    =   Sub{a};
    subcode   =   str2double(CurSub(2:end));
    
    Sess       =   fieldnames(struc.(CurSub));
    nSess      =   length(Sess);
    
    for b = 1:nSess
        
        CurSess   =   Sess{b};
        if strcmp(CurSess,'OFF')
            sesscode = 1;
        elseif strcmp(CurSess,'ON')
            sesscode = 2;
        end
        
        Cond   =   fieldnames(struc.(CurSub).(CurSess));
        nCond  =   length(Cond);
        
        for c = 1:nCond
            
            CurCond   =   Cond{c};
            switch CurCond
                case 'Rest1'
                    condcode = 1;
                case 'RestCOG1'
                    condcode = 2;
                case 'RestmoM1'
                    condcode = 3;
                case 'RestmoL1'
                    condcode = 4;
                case 'EntrM'
                    condcode = 5;
                case 'EntrL'
                    condcode = 6;
                case 'Rest2'
                    condcode = 7;
                case 'RestCOG2'
                    condcode = 8;
                case 'RestmoM2'
                    condcode = 9;
                case 'RestmoL2'
                    condcode = 10;
                case 'Rest3'
                    condcode = 11;
                case 'RestCOG3'
                    condcode = 12;
                case 'RestmoM3'
                    condcode = 13;
                case 'RestmoL3'
                    condcode = 14;
            end
            
            Ch   =   fieldnames(struc.(CurSub).(CurSess).(CurCond));
            nCh  =   length(Ch);
            
            for d = 1:nCh
                
                CurCh     =   Ch{d};
                
                switch CurCh
                    case 'RightAccelerometer'
                        chcode = 2;
                    case 'LeftAccelerometer'
                        chcode = 1;
                end
                
                Trmv  =   fieldnames(struc.(CurSub).(CurSess).(CurCond).(CurCh));
                nTrmv =   length(Trmv);
                
                for e = 1:nTrmv
                    
                    CurTrmv   =   Trmv{e};
                    
                    switch CurTrmv
                        case 'move'
                            type = 1;
                        case 'tremor'
                            type = 2;
                        case 'harmonmv'
                            type = 3;
                        case 'harmontr'
                            type = 4;
                    end
                    
                    freq    =   struc.(CurSub).(CurSess).(CurCond).(CurCh).(CurTrmv).freq;
                    pow     =   struc.(CurSub).(CurSess).(CurCond).(CurCh).(CurTrmv).pow;
                    powstd  =   struc.(CurSub).(CurSess).(CurCond).(CurCh).(CurTrmv).powstd;
                    powcov  =   struc.(CurSub).(CurSess).(CurCond).(CurCh).(CurTrmv).powcov;
                    
                    %=============FINALLYMOFO=============================%
                    MAT(cnt,:)  =   [subcode sesscode condcode chcode type freq pow powstd powcov];
                    cnt = cnt+1;
                    %=====================================================%
                     
                end 
            end 
        end 
    end
end

keyboard
sel  =   find(isnan(MAT));
mat =   MAT(1:sel(1)-1,:);




















