function jobout = job_4Dreslice(study,pp,taak,wdir)

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




w.ref={[wdir 'fmri/a4D.img, 1']};
w.source={};

for i=1:dyn
    w.source{i,1}=[wdir 'fmri/a4D.img, ' num2str(i)];
end

w.roptions.interp=7;
w.roptions.wrap=[0 0 0];
w.roptions.mask=1;

jobout.spatial{1}.coreg{1}.write=w;
