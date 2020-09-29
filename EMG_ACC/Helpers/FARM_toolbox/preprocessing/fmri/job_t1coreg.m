function jobout = job_t1coreg(study,pp,wdir)

if nargin<3
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/t1/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/t1/'];
end
disp(wdir);


% 2009-10-06: paul replaced absolute reference to template file on KNF disk with path to installed SPM directory
% hardcoded path was: regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'ICT/Software/mltoolboxes/spm5/templates/T2.nii'
spm_root = spm('Dir');
e.ref = {fullfile(spm_root, 'templates', 'T2.nii')};


e.source={[wdir 't1.img']};
e.other={''};

% entropy corr coefficient... voor als je t1 veel 'groter' is als je
% standaard t1 scan. groter = ook kleine hersenen, en nek mee-gescand; die
% staan niet op de standaard t1.
e.eoptions.cost_fun='ecc';
e.eoptions.sep=[4 2];
e.eoptions.tol=[20 20 20 1 1 1 10 10 10 1 1 1]/1000.0;
e.eoptions.fwhm=[7 7];


jobout.spatial{1}.coreg{1}.estimate=e;

if ~exist([wdir 't1.img'],'file')
    
    jobout=[];
    
    disp('there\''s no t1 scan!');
end