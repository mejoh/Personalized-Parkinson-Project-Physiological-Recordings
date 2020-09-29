function jobout = job_realign_unwarp(study,pp,taak,sagax,wdir)

if nargin<5
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/' taak '/'];
end
disp(wdir);

load([wdir 'parameters']);

%tr=parameters(1);
%ts=parameters(2);
dyn=parameters(3);



ru.data.scans=cell(dyn,1);
for i=1:dyn
    
    ru.data.scans{i}=[wdir 'fmri/a4D.img,' num2str(i)];
    
end
ru.data.pmscans={};


ru.eoptions.quality= 0.9000;
ru.eoptions.sep= 4;
ru.eoptions.fwhm= 5;
ru.eoptions.rtm= 0;
ru.eoptions.einterp= 4;
ru.eoptions.ewrap= [0 1 0];
ru.eoptions.weight= {};

ru.uweoptions.basfcn=  [12 12];
ru.uweoptions.regorder=  1;
ru.uweoptions.lambda=  100000;
ru.uweoptions.jm=  0;

if strcmp(sagax,'sag')
    disp('going for saggital unwarping: out-of-plane rotations = yaw&roll');
    ru.uweoptions.fot=  [5 6];
end;if strcmp(sagax,'ax')
    ru.uweoptions.fot=  [4 5];
end;if strcmp(sagax,'cor')
    ru.uweoptions.fot=  [4 6];
end

ru.uweoptions.sot=  [];
ru.uweoptions.uwfwhm=  4;
ru.uweoptions.rem=  1;
ru.uweoptions.noi=  5;
ru.uweoptions.expround=  'Average';

ru.uwroptions.which= [2 1];
ru.uwroptions.rinterp= 4;
ru.uwroptions.wrap= [0 1 0];
ru.uwroptions.mask= 1;


jobout.spatial{1}.realignunwarp=ru;
