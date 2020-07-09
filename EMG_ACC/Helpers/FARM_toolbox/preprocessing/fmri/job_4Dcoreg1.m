function jobout = job_4Dcoreg1(study,pp,taak,wdir)

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




e.ref={[wdir '../t1/t1.img']};
e.source={[wdir 'fmri/meana4D.img']};

e.other={};
for i=1:dyn
    e.other{i,1}=[wdir 'fmri/a4D.img, ' num2str(i)];
end

e.eoptions.cost_fun='ecc';
e.eoptions.sep=[4 2];
e.eoptions.tol=[20 20 20 1 1 1 10 10 10 1 1 1]/1000.0;
e.eoptions.fwhm=[7 7];

%e.roptions.interp=7;
%e.roptions.wrap=[0 0 0];
%e.roptions.mask=1;

jobout.spatial{1}.coreg{1}.estimate=e;
