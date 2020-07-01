function pf_pmg_utilities_classplotpostpd(conf)
% pf_pmg_utilities_classplotpostpd(conf) is part of the utilities chapter
% of the pf_pmg_batch. Specifically, it is a very specific type of plot
% (which is why it does not fall under the plot chapter of the batch) for
% the POSTPD chapter, where we will try to classify all patients in one
% plot: on the Y-axis will be the change in frequency of rest vs.
% reemergent and on the X-axis will be the decrease (if present) in tremor
% power
%
% Part of pf_pmg_batch

% (c) Michiel Dirkx, 2015
% $ParkFunC, version 20151114

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

peaksel      = load(conf.util.class.peaksel);
fn           = fieldnames(peaksel);
peaksel      = peaksel.(fn{1});

fragmentana  = load(conf.util.class.fragmentana);
fn           = fieldnames(fragmentana);
fragmentana  = fragmentana.(fn{1});

nSub         = length(conf.sub.name);
nSess        = length(conf.sub.sess);

peakselcond  = {'RestAVG';'POSHAVG'};
nCond        = length(peakselcond);

willplot     = 1;

%--------------------------------------------------------------------------

%% Run 
%--------------------------------------------------------------------------


figure
for a = 1:nSub
    
   CurSub   =   conf.sub.name{a}; 
   CurHand  =   conf.sub.hand{a};
   subcode  =   str2double(CurSub(2:end));
   
   iSub     =   pf_strcmp(conf.util.class.channel(:,1),CurHand);
   chan     =   conf.util.class.channel{iSub,2};
    
   for b = 1:nSess
       
       CurSess  =   conf.sub.sess{b};
       sesscode =   pf_pmg_sesscode(CurSess);
       
       % --- Retrieve peaks of reemergent and rest --- %
       
       for c = 1:nCond
           
           CurCond  =   peakselcond{c};
           condcode =   pf_pmg_condcode(CurCond);
           
           sel      =   peaksel(:,1)==subcode & peaksel(:,2)==sesscode & peaksel(:,3)==condcode & peaksel(:,4)==chan;
           if isempty(find(sel, 1))
              fprintf('%s\n',['- Could not find peaksel of ' CurSub '-' CurSess ' ' CurCond  '. Subject will not be plotted.']) 
              willplot = 0;
           end
           
           if strcmp(CurCond,'RestAVG')
               rest =   peaksel(sel,6);
               if length(rest)>1
                   iRest    =   peaksel(sel,7)==max(peaksel(sel,7));
                   rest     =   rest(iRest);
               end
           elseif strcmp(CurCond,'POSHAVG')
               reemergent = peaksel(sel,6);
           end           
       end
       
       freqdif  =   reemergent-rest;
%        if freqdif<1.5
%            disp(['Subject ' CurSub ' dF<1.5'])
%        end
       disp(['Subect ' CurSub ': dF = ' num2str(freqdif)])


       % --- Retrieve fragmentdata --- %
       
       % [1     2             3       4      5      6        7        8          9        10         11       12        13      14         15       16               17         ]
       % [Sub   Session  Condition Channel Type  timemin   timemax   FreqMin  FreqMax  meanTFR     stdTFR    covTFR   minTFR   maxTFR   nDatTFR   firstvalTFR    lastvalTFR     ]
       xval     =   nan(length(conf.util.class.fragments),1);
       xstd     =   nan(length(conf.util.class.fragments),1);
       
       for c = 1:length(conf.util.class.fragments)
           CurFrag  =   conf.util.class.fragments{c};
           
           sel      =   fragmentana(:,1)==subcode & fragmentana(:,2)==sesscode & fragmentana(:,3)==condcode & fragmentana(:,4)==chan & fragmentana(:,6)==CurFrag(1) & fragmentana(:,7)==CurFrag(2);
           dat      =   fragmentana(sel,:);
           if isempty(find(sel, 1))
              fprintf('%s\n',['- Could not find fragmentana of ' CurSub '-' CurSess ' ' CurCond  '. Subject will not be plotted.']) 
              willplot = 0;
           else
               if strcmp(conf.util.class.fragmentval,'meanTFR')
                   xval(c)    =   dat(10);
                   xstd(c)    =   dat(11);
               elseif strcmp(conf.util.class.fragmentval,'maxTFR')
                   xval(c)    =   dat(14);
                   xstd(c)    =   dat(11);
               elseif strcmp(conf.util.class.fragmentval,'last-first')
                   if c == 1
                       xval(c) = dat(16);
                       xstd(c) = dat(11);
                   elseif c==2
                       xval(c) = dat(17);
                       xstd(c) = dat(11);
                   end
               elseif strcmp(conf.util.class.fragmentval,'meanTFR-first')
                   if c == 1
                       xval(c) = dat(10);
                       xstd(c) = dat(11);
                   elseif c==2
                       xval(c) = dat(16);
                       xstd(c) = dat(11);
                   end
               end
           end
       end
       dP =   xval(1)-xval(2);
       
       if strcmp(conf.util.class.stdcrit,'on')
           if dP < 2*xstd(1)
               dP = 0;
           elseif dP > 2*xstd(1)
               dP = 1;
           end
       end
       
       
       % --- OK, so let's plot dF vs dP --- %
       
       if willplot
            plot(dP,freqdif,'x');
            hold on
       end
       willplot = 1;
   end
    
    
end
title('Classification: freqdif VS meandrop (reemergent subs)')
xlabel('dP (meanTFR_POST - meanTFR_PRE)','interpreter','none')
ylabel('dF (reemergent - rest)');
xx = get(gca,'xlim');
yy = get(gca,'ylim');
axis([xx(1)-0.5 xx(2)+0.5 yy(1) yy(2)])



