function pf_pmg_utilities_plotedf(conf)
% pf_pmg_plotedf(conf) is part of the 'utilities' chapter of the
% pf_pmg_batch. Specifically, it will simply plot the EDF+ data that was
% stored in conf.dir.plotedf. This is useful to have a quick look at your
% data.  
%
% Part of pf_pmg_batch.m

% ©Michiel Dirkx, 2014
% $ParkFunC, version 20150609

%--------------------------------------------------------------------------

%% Initiatilize
%--------------------------------------------------------------------------

nSub        =   length(conf.sub.name);
nSess		=	length(conf.sub.sess);
Fcnt        =   1;                      % initiate figure counter
SPcnt       =   1;                      % initiate subplot counter

%--------------------------------------------------------------------------

%% Analysis
%--------------------------------------------------------------------------

%--- Start Looping through all subjects/sessions --- %

fprintf('\n')

for h = 1:nSub
    
    CurSub              =   conf.sub.name{h};
    
    for j = 1:nSess
        
        CurSess				=	conf.sub.sess{j};
        
        fprintf('%s\n',['Working on ' CurSub '-' CurSess])
        
        % --- Load File --- %
        
        CurFile				=	pf_findfile(conf.dir.plotedf,conf.util.plotedf.file,'conf',conf,'CurSub',h,'CurSess',j,'fullfile');
        
        [CurDat,CurHDR]     =   ReadEDF_shapkin(CurFile);
        
        % --- Initiate Parameters CurFile --- %
        
        nChan               =   length(conf.util.plotedf.chans);
        nMark               =   length(CurHDR.annotation.event);    % Number of markers
        figure(Fcnt)
        
        % --- Loop through all channels/markers --- %
        
        for i = 1:nChan
            
            CurChan         =   conf.util.plotedf.chans{i,1};             % Channel label
            chanlabel       =   conf.util.plotedf.chans{i,2};
            iChan           =   pf_strcmp(CurHDR.labels,CurChan);
            
            if ~any(iChan)
                fprintf('%s\n',['- Could not find channel "' CurChan '", skipping...'])
                continue
            end
            
            CurUnit         =   CurHDR.units{iChan};             % Unit of measurement (usually mV)
            CurFs           =   CurHDR.samplerate(iChan);        % Sample rate in Hz??
            
            nD  =   length(CurDat{iChan});
            nT  =   nD/CurFs/60;              % Current time (minutes)
%             nT  =   nD/CurFs;              % Current time (seconds)
            
            % --- Plot Channel --- %
            
            subplot(conf.util.plotedf.rsp,1,SPcnt)
            plot(CurDat{iChan}');
            hold on
            title([CurSub '-' CurSess ' ' chanlabel],'fontsize',11,'fontweight','b')
            axis([0 nD -1*max(abs(CurDat{iChan}))*1.05 max(abs(CurDat{iChan}))*1.05])
            set(gca,'xtick',0:CurFs*60:nD,'xticklabel',0:1:nT)
            ylabel(['Amplitude ' CurUnit],'fontsize',16,'fontweight','b')
            xlabel('Time (minutes)','fontsize',16,'fontweight','b')
            SPcnt        =  SPcnt + 1;
            
            % --- Plot Markers --- %
            
            Y   =   get(gca,'ylim');
            Yf  =   1;            % Factor for making bigger/smaller
            
            for b = 1:nMark
                
                CurMark     =   CurHDR.annotation.event{b};
                CurStart    =   (CurHDR.annotation.starttime(b)-CurHDR.annotation.starttime(1))*CurFs;
                CurDur      =   CurHDR.annotation.duration(b)*CurFs;
                CurEnd      =   CurStart + CurDur;
                
                if CurDur == 0
                    pf_verline(CurStart,'color','r','linestyle','-','linewidth',2);
                else
%                     P   =   patch([CurStart CurEnd CurEnd CurStart],[min(Y)*Yf min(Y)*Yf max(Y)*Yf max(Y)*Yf],'k');
%                     set(P,'EdgeColor','none','FaceAlpha',0.1)
                    pf_verline(CurStart,'color','r','linestyle','-','linewidth',2);
                    pf_verline(CurEnd,'color','r','linestyle','-','linewidth',2);
              
                end
                    if mod(b,2) == 0
                        text(CurStart,max(Y)*(Yf-0.1),CurMark,'fontsize',9,'color','r')
                    else
                        text(CurStart,max(Y)*(Yf-0.05),CurMark,'fontsize',9,'color','r')
                    end
            end
            
            % --- Decide if start new figure --- %
            
            if SPcnt > conf.util.plotedf.rsp && sum([h j i]) ~= sum([nSub nSess nChan])
                 Fcnt     =   Fcnt + 1;
                 SPcnt    =   1;
                 figure(Fcnt)
            end

            % --- End of channel/marker ---%
        end
    end
end