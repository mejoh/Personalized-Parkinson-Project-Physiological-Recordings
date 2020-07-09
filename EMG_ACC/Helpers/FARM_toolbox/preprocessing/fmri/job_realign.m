function jobout = job_realign(study,pp,taak,wdir)

if nargin<4
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/' taak '/'];
end
disp(wdir);

load([wdir 'parameters']);

%tr=parameters(1);
%ts=parameters(2);
dyn=parameters(3);



e.data{1}=cell(dyn,1);
for i=1:dyn
    
    e.data{1}{i}=[wdir 'fmri/a4D.img,' num2str(i)];
    
end


e.eoptions.quality= 0.9000;
e.eoptions.sep= 4;
e.eoptions.fwhm= 5;
e.eoptions.rtm= 0;
e.eoptions.interp= 4;
e.eoptions.wrap= [0 0 0];
e.eoptions.weight= {};

e.roptions.which= [0 1];
e.roptions.interp= 2;
e.roptions.wrap= [0 0 0];
e.roptions.mask= 1;

jobout.spatial{1}.realign{1}.estwrite=e;
