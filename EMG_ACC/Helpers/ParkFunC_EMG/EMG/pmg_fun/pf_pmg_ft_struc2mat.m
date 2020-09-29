function mat = pf_pmg_ft_struc2mat(struc)
% Helper function to convert the structure created of the frequency
% analyzed data in pf_pmf_ft_freqana2 to a matrix. This takes up less space
% and is easier with computing average results.
% UPDATE: after testing this it actually turns out that it takes up more
% space and it takes a while to convert, so even though you can still
% convert it I will not be implementing this throughout the rest of the
% batch.
%
% Part of pf_pmg_batch

% ©Michiel Dirkx, 2015
% $ParkFunC, 20150525

%--------------------------------------------------------------------------

%% initialize
%--------------------------------------------------------------------------

Sub       =   fieldnames(struc);
nSub      =   length(Sub);
cnt       =   1;

%--------------------------------------------------------------------------

%% Fill out matrix
%--------------------------------------------------------------------------

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
                case 'POST1'
                    condcode = 5;
                case 'POSH1'
                    condcode = 6;
                case 'POSW1'
                    condcode = 7;
                case 'EntrM'
                    condcode = 8;
                case 'EntrL'
                    condcode = 9;
                case 'Rest2'
                    condcode = 10;
                case 'RestCOG2'
                    condcode = 11;
                case 'RestmoM2'
                    condcode = 12;
                case 'RestmoL2'
                    condcode = 13;
                case 'POST2'
                    condcode = 14;
                case 'POSH2'
                    condcode = 15;
                case 'POSW2'
                    condcode = 16;
                case 'Rest3'
                    condcode = 17;
                case 'RestCOG3'
                    condcode = 18;
                case 'RestmoM3'
                    condcode = 19;
                case 'RestmoL3'
                    condcode = 20;
                case 'Weight'
                    condcode = 21;
                case 'IntentM'
                    condcode = 22;
                case 'IntentL'
                    condcode = 23;
            end
            
            % --- Amount of datapoints --- %
            
            nTime   =   length(struc.(CurSub).(CurSess).(CurCond).time);
            
            % --- Retrieve channel codes --- %
            
            Ch      =  struc.(CurSub).(CurSess).(CurCond).label;
            nCh     =  length(Ch);
            chandecoding   =   {
                                  'EEG 1-2'    1;    % Channel name (as labeled by the headbox) followed by your own name. Use a new row for every new channel, and a new column for your own name. Leave blanc ('') if original channel names used.
                                  'EEG 3-4'    2;    % 2      
                                  'EEG 5-6'    3;    % 3 
                                  'EEG 7-8'    4;    % 4
                                  'EEG 9-10'   5;    % 5
                                  'EEG 11-12'  6;    % 6
                                  'EEG 13-14'  7;    % 7
                                  'EEG 33-34'  8;    % 8
                                  'EEG 35-36'  9;    % 9                
                                  'EEG 37-38'  10;   % 10
                                  'EEG 39-40'  11;   % 11
                                  'EEG 41-42'  12;   % 12
                                  'EEG 43-44'  13;   % 13
                                  'EEG 45-46'  14;   % 14
                                  'EEG 31-32'  15;   % 15
                                  'EEG 61-62'  16;   % 16
                                  'EEG 63-64'  17;   % 17
                                };
                            
            chancode  = chandecoding(pf_strcmp(chandecoding(:,1),struc.(CurSub).(CurSess).(CurCond).label),2);
            chancode  = cell2mat(chancode);
            
            % --- Freq --- %
            
            freq    =   struc.(CurSub).(CurSess).(CurCond).freq;
            nFreq   =   length(freq);
            
            % --- Add codes to data matrix --- %
            
            for d = 1:nTime
                
                % Store in matrix:
                %[Dat(Chan,Freq) subcode sesscode condcode chancode time]
                
                CurTime             =   struc.(CurSub).(CurSess).(CurCond).time(d);
                CurDat              =   struc.(CurSub).(CurSess).(CurCond).powspctrm(:,:,d);
                CurDat(:,nFreq+1)   =   repmat(subcode,nCh,1);      % SubCode
                CurDat(:,nFreq+2)   =   repmat(sesscode,nCh,1);     % SessCode
                CurDat(:,nFreq+3)   =   repmat(condcode,nCh,1);     % CondCode
                CurDat(:,nFreq+4)   =   chancode;                   % ChanCode
                CurDat(:,nFreq+5)   =   repmat(CurTime,nCh,1);      % Time
                
                %===================Store big Matrix======================%
                mat(:,:,cnt)        =   CurDat;
                cnt                 =   cnt+1;
                %=========================================================%
            end            
        end
    end
end

%==========================================================================
