function [o d sl m]=init(EEG,conf)


% handy for later on. makes it run quicker.

% parameters=load(regexprep([pwd '/../parameters'],'\\','/'))
parameters = conf.file.scanpar;    

% define srate and number of channels.
o.nch       =EEG.nbchan;
o.fs        =EEG.srate;
o.npnts     =size(EEG.data,2);
o.nslices   =parameters(2);
o.nvol      =parameters(3);



% determine 'optimal' correction parameters for both sampling rates.
% if o.fs==2048;
 if round(o.fs)==2048;   
    o.N         =18;
    o.N2        =14;
    o.skip      =1;
   
    o.window        =50;
    o.interpfactor  =10;
    o.beginshift    =0.07;
    o.sections      =7;
    o.MRtimes       =[0.0122    0.0171    0.0244    0.0486];

    o.pca.hpf                       =60;
    o.pca.usr_max_components        =5;
    o.pca.hpf2                      =60;
    o.pca.usr_max_components2       =0;
    
    o.pca.pca_rough                 =0;
    
    o.pca.omit_weird_shapes         =0;
    o.pca.corrs_thr                 =0.90;

    o.filter.anclpf     =250;
    o.filter.comb       =0;
    
elseif o.fs==1024;
    
    o.N         =16;
    o.N2        =12;
      o.skip      =1;
    
    o.window        =70;
    o.interpfactor  =10;
    o.beginshift    =0.05;
    o.sections      =7;
    o.MRtimes       =[0.0122    0.0171    0.0244    0.0486];

    o.pca.hpf                       =60;
    o.pca.usr_max_components        =5;
    o.pca.hpf2                      =60;
    o.pca.usr_max_components2       =0;
    
    o.pca.pca_rough                 =0;
    
    o.pca.omit_weird_shapes         =1;
    o.pca.corrs_thr                 =0.90;

    o.filter.anclpf     =250;
    o.filter.comb       =0;

 else 
    o.N         =18;
    o.N2        =14;
    o.skip      =1;
   
    o.window        =50;
    o.interpfactor  =10;
    o.beginshift    =0.07;
    o.sections      =7;
    o.MRtimes       =[0.0122    0.0171    0.0244    0.0486];

    o.pca.hpf                       =60;
    o.pca.usr_max_components        =5;
    o.pca.hpf2                      =60;
    o.pca.usr_max_components2       =0;
    
    o.pca.pca_rough                 =0;
    
    o.pca.omit_weird_shapes         =0;
    o.pca.corrs_thr                 =0.90;

    o.filter.anclpf     =250; % original!
%     o.filter.anclpf     =500;
    o.filter.comb       =0;  

end

o.filter.hpf        =30;
o.filter.alignhpf   =250; % original!
% o.filter.alignhpf   =500; % changed for high pass?
o.filter.declpf     =250; % original!
% o.filter.declpf     =500; % changed for high pass?


o.filter.hpffac     =1.2;
o.filter.lpffac     =3;
o.filter.trans      =0.15;

o.vol.rtime_first   =0.0234;
o.vol.rtime_last    =0.0234;

o.anc               =1;

% initialize the sl struct. eventually store the 'phase shifts' for 1024 
% sampling rate... but not now.
sl=struct(...
    'b',0,...
    'e',0,...
    'others',zeros(1,o.window),...
    'clusterdata',zeros(o.nch,o.window),...
    'chosenTemplate',zeros(1,o.nch),...
    'templateCorrelation',zeros(1,o.nch),...
    'templateAmplitude',zeros(1,o.nch),...
    'templateAngleWrtPrev',zeros(1,o.nch)...
    );

    % 'template_adjusts',single(zeros(1,o.nch))...
    % 'phase_adjusts',{}


% d = cleaned data, artifact-data, data after anc.
d.original=EEG.data';
d.clean=zeros(o.npnts,o.nch);
d.noise=zeros(o.npnts,o.nch);
d.anc=zeros(o.npnts,o.nch);

d.vol_original=sparse(zeros(o.npnts,o.nch));
d.vol_artifacts=sparse(zeros(o.npnts,o.nch));
d.vol_cleaned=sparse(zeros(o.npnts,o.nch));


% markers:
% slice 
m.ms=find(strcmp({EEG.event(:).type},'sliceTrigger'));
if numel(m.ms)==0
    m.ms=find(strcmp({EEG.event(:).type},'s'));
end
m.ms=m.ms;
m.ss=[EEG.event(m.ms).latency];


for i=2:numel(m.ss)
    sl(i)=sl(1);
end


% volume 
m.mv=find(strcmp({EEG.event(:).type},'65535'));
if numel(m.mv)==0
    m.mv=find(strcmp({EEG.event(:).type},'V'));
end
m.mv=m.mv;
m.sv=[EEG.event(m.mv).latency];


% don't know if this is required...
% for memory purposes: seclength!
o.seclength=floor(numel(m.ss)/o.sections);

% calculate # samples for slices.
o.sduration=ceil(median(m.ss(2:end)-m.ss(1:end-1)));
% calculate beginning for offset.
% keyboard;
o.soffset=round(-1*o.beginshift*o.sduration);

% apply a tiny offset; some of the artifact has already manifested when the
% marker is present/inserted.
m.sv = m.sv ;% + o.soffset;
m.ss = m.ss ;% + o.soffset;











%% OLD INT32
% % initialize the sl struct. eventually store the 'phase shifts' for 1024 
% % sampling rate... but not now.
% sl=struct(...
%     'b',int32(0),...
%     'e',int32(0),...
%     'others',int32(zeros(1,o.window)),...
%     'clusterdata',int16(zeros(o.nch,o.window)),...
%     'chosenTemplate',int16(zeros(1,o.nch)),...
%     'templateCorrelation',single(zeros(1,o.nch)),...
%     'templateAmplitude',single(zeros(1,o.nch)),...
%     'templateAngleWrtPrev',single(zeros(1,o.nch))...
%     );
% 
%     % 'template_adjusts',single(zeros(1,o.nch))...
%     % 'phase_adjusts',{}
% 
%     
%     
% % d = cleaned data, artifact-data, data after anc.
% d.original=EEG.data';
% d.clean=single(zeros(o.npnts,o.nch));
% d.noise=single(zeros(o.npnts,o.nch));
% d.anc=single(zeros(o.npnts,o.nch));
% 
% d.vol_original=sparse(zeros(o.npnts,o.nch));
% d.vol_artifacts=sparse(zeros(o.npnts,o.nch));
% d.vol_cleaned=sparse(zeros(o.npnts,o.nch));
% 
% 
% % markers:
% % slice 
% m.ms=find(strcmp({EEG.event(:).type},'sliceTrigger'));
% if numel(m.ms)==0
%     m.ms=find(strcmp({EEG.event(:).type},'s'));
% end
% m.ms=int32(m.ms);
% m.ss=int32([EEG.event(m.ms).latency]);
% 
% 
% for i=2:numel(m.ss)
%     sl(i)=sl(1);
% end
% 
% 
% % volume 
% m.mv=find(strcmp({EEG.event(:).type},'65535'));
% if numel(m.mv)==0
%     m.mv=find(strcmp({EEG.event(:).type},'V'));
% end
% m.mv=int32(m.mv);
% m.sv=int32([EEG.event(m.mv).latency]);
% 
% 
% % don't know if this is required...
% % for memory purposes: seclength!
% o.seclength=floor(numel(m.ss)/o.sections);
% 
% % calculate # samples for slices.
% o.sduration=ceil(median(m.ss(2:end)-m.ss(1:end-1)));
% % calculate beginning for offset.
% % keyboard;
% o.soffset=round(-1*o.beginshift*o.sduration);
% 
% % apply a tiny offset; some of the artifact has already manifested when the
% % marker is present/inserted.
% m.sv = m.sv ;% + o.soffset;
% m.ss = m.ss ;% + o.soffset;
% 
% 
% 
% 
% 
% 
% 
