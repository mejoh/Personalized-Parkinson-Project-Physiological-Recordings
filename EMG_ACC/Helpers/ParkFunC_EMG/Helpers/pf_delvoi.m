
rootdir =   '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/M43_ICA-AROMAnonaggr_spmthrsh0c25_FARM1_han2s_EMG-log_broadband_retroicor18r-exclsub/RS';

conf.sub.name   =   {
                     'p30';'p08';'p11';'p28';'p14'; %5
                     'p18';'p27';'p02';'p60';'p59'; %10
                     'p62';'p38';'p49';'p40';'p19'; %15
                     'p29';'p36';'p42';'p33';'p71'; %20
                     'p21';'p70';'p64';'p50';'p72'; %25
                     'p47';'p56';'p24';'p48';'p43'; %30
                     'p63';'p75';'p74';'p76';'p77'; %35
                     'p78';'p73';'p80';'p81';'p82'; %40
                     'p83';                         %41
                     };     

                 
nSub = length(conf.sub.name);                 
                 
%% dfwfe


for a = 1:nSub
   
   clear CurFiles 
   CurSub = conf.sub.name{a};
   CurDir = fullfile(rootdir,CurSub);
   
   CurFiles = pf_findfile(CurDir,'/|VOI*/');
   
   if ~isempty(CurFiles)
      CurFiles = cellfun(@(x) fullfile(CurDir,x),CurFiles,'uniformoutput',0);
      for b=1:length(CurFiles)
        delete(CurFiles{b})
      end
   end
end