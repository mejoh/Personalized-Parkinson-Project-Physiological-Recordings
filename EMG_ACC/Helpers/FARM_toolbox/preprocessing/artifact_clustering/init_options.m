function [o d ps]=init(EEG)

% define srate and number of channels.
o.nch=EEG.nbchan;
o.fs=EEG.srate;
o.npnts=size(EEG.data,2);


% determine 'optimal' correction parameters for both sampling rates.
if o.fs==2048;
    
    o.window        =50;
    o.interpfactor  =20;
    o.beginshift    =0.07;
    o.sections      =7;
    o.MRtimes       =[0.0122    0.0171    0.0244    0.0500];

    o.cl.minsize        =14;
    o.cl.corrspeedup    =8;
    o.cl.mojenavalues   =[1 5 35 4];

    o.pca.thrcomponent  =4;
    o.pca.thrcumsum     =85;
    o.pca.thrslope      =1.5;
    
elseif o.fs==1024;
    
    o.window        =60;
    o.interpfactor  =20;
    o.beginshift    =[];
    o.sections      =7;
    o.MRtimes       =[0.0122    0.0171    0.0244    0.0500];
    
    o.cl.minsize        =8;
    o.cl.corrspeedup    =8;
    o.cl.mojenavalues   =[1 5 35 4];

    o.pca.thrcomponent  =2;
    o.pca.thrcumsum     =90;
    o.pca.thrslope      =1;
    
end

o.filter.lpf        =20;
o.filter.declpf     =250;
o.filter.anchpf     =250;
o.filter.hpffac     =1.2;
o.filter.lpffac     =3;
o.filter.trans      =0.15;

o.vol.duration      =0.020;
o.vol.beginshift    =1.05;
o.vol.extra_factor  =2;



% initialize the sl struct. eventually store the 'phase shifts' for 1024 
% sampling rate... but not now.
sl=struct(...
    'b',int32(0),...
    'e',int32(0),...
    'others',int32(zeros(1,o.window)),...
    'adjusts',int16(zeros(1,o.window)),...
    'scalingdata',single(zeros(o.nch,o.window)),...
    'Tmat',single(zeros(o.window-1,3,o.nch)),...
    'clusterdata',int16(zeros(o.nch,o.window)),...
    'chosenTemplate',int16(zeros(1,o.nch)),...
    'template_scalings',single(zeros(1,o.nch)),...
    'template_adjusts',single(zeros(1,o.nch)),...
    'cluster_correlation',single(zeros(1,o.nch))...
    );
    
    
% d = cleaned data, artifact-data, data after anc.
d.clean=single(zeros(o.nch,o.npnts));
d.noise=single(zeros(o.nch,o.npnts));
d.anc=single(zeros(o.nch,o.npnts));


