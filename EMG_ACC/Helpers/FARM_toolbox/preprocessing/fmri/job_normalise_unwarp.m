function jobout = job_normalise_unwarp(study,pp,taak,wdir)

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
    
    e.subj.source={[wdir '../t1/t1.img']};
    
else
    
    e.subj.source={[wdir 'fmri/meanua4D.img']};
    disp('This subject does not have a T1 scan, so were using now the subjects meanua4D.img instead.');
    disp('Without unwarping, this would be meana4D.img, instead, if it exists, or else a4D.img,1, as all other images are registered to the first one in the realignment process.');
end

e.subj.wtsrc= {};
e.subj.resample= {};


% but first... fix(!!) the ua4D.mat
% the mat entries should all be the same.
% if ~exist([wdir '/fmri/ua4D_old.mat'],'file');
load([wdir 'fmri/ua4D.mat']);
mat(:,:,1)=mat(:,:,3);
mat(:,:,2)=mat(:,:,3);
movefile([wdir 'fmri/ua4D.mat'],[wdir 'fmri/ua4D_old.mat']);
save([wdir 'fmri/ua4D.mat'],'mat');
% else
%     warning('Preprocessing already occurred previously, and an ua4D_old.mat file already exists.');
% end

% keyboard;


for i=1:dyn
    e.subj.resample{i,1}=[wdir 'fmri/ua4D.img, ' num2str(i)];
end

% 2009-10-06: paul replaced absolute reference to template file on KNF disk with path to installed SPM directory
% hardcoded path was: [regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'ICT/Software/mltoolboxes/spm5/templates/
if exist([wdir '../t1/t1.img'],'file');
    template= 'T1.nii,1';
else
    disp('as the subject hasnt got a t1 scan, were going to match the epi to the template epi for the warping procedure.');
    disp('selecting EPI.nii as the template to match to...');
    template= 'EPI.nii,1';
end
spm_root = spm('Dir');
e.eoptions.template = {fullfile(spm_root, 'templates', template)};

e.eoptions.weight= {};
e.eoptions.smosrc= 8;
e.eoptions.smoref= 0;
e.eoptions.regtype= 'mni';
e.eoptions.cutoff= 25;
e.eoptions.nits= 16;
e.eoptions.reg= 1;

e.roptions.preserve= 0;
e.roptions.bb=[...
    -78  -112  -50; ...
    78    76    85 ...
    ];

% keyboard;


mat=[];
load([wdir 'fmri/ua4D.mat']);

dims=[sqrt(sum(mat(:,1).*mat(:,1))) sqrt(sum(mat(:,2).*mat(:,2))) sqrt(sum(mat(:,3).*mat(:,3)))];
% let's avoid SPM's weird round-off error.
% Wat er gebeurde met die fout was dat ik de voxel dimensions van hoe SPM(5) normalized images moest wegschrijven 
% uit de .mat file haal van de images die in de normalization worden gestopt. Daarvan de de Z-grootte 3 mm. 
% SPM5 rondde dat vervolgens soms af naar 3.0000009 mm en soms naar 2.99999997 mm.
% De bounding box, de ruimte die totaal wordt weggeschreven door de normalization, is 50 naar boven en 85 naar 
% beneden; dat is dus 135 mm in totaal in de z-righting. Nu voel je em al, want 135/3 = 45,
% 135/2.999999 = 45, en 135/3.0000009 = 46. SPM rond altijd naar boven af!
dims=dims-0.000001;
disp('WARNING: reduce voxel size by 1e-6 millimeters.'); 
disp('This will do nothing and hopefully avoid dimension errors.'); 
disp('and result in all the images having the same voxel dimensions.'); 
disp('SPM does not round off correctly when voxels are (real) N mm big in'); 
disp('one dimension.');
disp(['voxel sizes normalised = ' num2str(dims)]);

e.roptions.vox= dims;
e.roptions.interp= 7;
e.roptions.wrap= [0 0 0];

jobout.spatial{1}.normalise{1}.estwrite=e;

