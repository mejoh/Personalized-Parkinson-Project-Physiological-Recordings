function jobout = job_4Dcoreg1_firstImage(study,pp,taak,wdir)

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



if exist([wdir '../t1/t1.img'],'file');
    
    e.ref={[wdir '../t1/t1.img']};
    
else
    % 2009-10-06: paul replaced absolute reference to template file on KNF disk with path to installed SPM directory
    % hardcoded path was: regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') '/ICT/Software/mltoolboxes/spm5/templates/T1.nii'
    spm_root = spm('Dir');
    e.ref.template = {fullfile(spm_root, 'templates', 'T1.nii')};
    disp('This subject does not have a T1 scan, so we\''re using the template T1 scan instead.');
    disp('preferably the standard EPI should be used, but this should also give reasonable estimate for the orientation');
    
end
        

e.source={[wdir 'fmri/a4D.img, 1']};

e.other={};
for i=2:dyn
    e.other{i-1,1}=[wdir 'fmri/a4D.img, ' num2str(i)];
end

e.eoptions.cost_fun='ecc';
e.eoptions.sep=[4 2];
e.eoptions.tol=[20 20 20 1 1 1 10 10 10 1 1 1]/1000.0;
e.eoptions.fwhm=[7 7];

%e.roptions.interp=7;
%e.roptions.wrap=[0 0 0];
%e.roptions.mask=1;

jobout.spatial{1}.coreg{1}.estimate=e;
