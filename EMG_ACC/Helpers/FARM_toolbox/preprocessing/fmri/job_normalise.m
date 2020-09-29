function jobout = job_normalise(study,pp,taak,wdir)

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
    e.subj.source={[wdir 'fmri/a4D.img,1']};
    disp('This subject does not have a T1 scan, so were using now the subjects meanua4D.img instead.');
    disp('Without unwarping, this is a4D.img,1. ');
end


e.subj.wtsrc= {};
e.subj.resample= {};

for i=1:dyn
    e.subj.resample{i,1}=[wdir 'fmri/a4D.img, ' num2str(i)];
end

% 2009-10-06: paul replaced absolute reference to template file on KNF disk with path to installed SPM directory
% hardcoded path was: [regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'ICT/Software/mltoolboxes/spm5/templates/
if exist([wdir '../t1/t1.img'],'file');
    template= 'T1.nii,1';
else
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
load([wdir 'fmri/a4D.mat']);

dims=[sqrt(sum(mat(:,1).*mat(:,1))) sqrt(sum(mat(:,2).*mat(:,2))) sqrt(sum(mat(:,3).*mat(:,3)))];
% This is what Johan proposed:
% 	Let's avoid SPM's weird round-off error.
% 	Wat er gebeurde met die fout was dat ik de voxel dimensions van hoe SPM(5) normalized images moest wegschrijven 
% 	uit de .mat file haal van de images die in de normalization worden gestopt. Daarvan de de Z-grootte 3 mm. 
% 	SPM5 rondde dat vervolgens soms af naar 3.0000009 mm en soms naar 2.99999997 mm.
% 	De bounding box, de ruimte die totaal wordt weggeschreven door de normalization, is 50 naar boven en 85 naar 
% 	beneden; dat is dus 135 mm in totaal in de z-righting. Nu voel je em al, want 135/3 = 45,
% 	135/2.999999 = 45, en 135/3.0000009 = 46. SPM rond altijd naar boven af! (Johan made a mistake here 45<->46)
%   When this is true, you might include the following:
dims=dims-0.000001;
disp('WARNING: reduced voxel size by 1e-6 millimeters.'); 
disp('This will do nothing and hopefully avoid dimension errors.'); 
disp('and result in all the images having the same voxel dimensions.'); 
disp('SPM does not round off correctly when voxels are (real) N mm big in'); 
disp('one dimension.');
disp(['voxel sizes normalised = ' num2str(dims)]);
%	Echter, dit is niet helemaal waar... In SPM5 worden voxelcoordinaten eerst afgerond. 
%   Vervolgens wordt er een range uitgerekend waar een cummulatieve fout in zit (bb(1,3):vox(3):bb(2,3))
%   die geen problemen veroorzaakt als je eerst afrond. In SPM8 is de afronding echter verwijderd, en wordt de bug zichtbaar.
%
%   Ccode fragment from lines 447 e.o. from spm_write_sn.m (commented out in SPM8 line 451)
%	% Adjust bounding box slightly - so it rounds to closest voxel.
%	% Comment out if not needed.  I chose not to change it because
%	% it would lead to being bombarded by questions about spatially
%	% normalised images not having the same dimensions.
%	bb(:,1) = round(bb(:,1)/vox(1))*vox(1);
%	bb(:,2) = round(bb(:,2)/vox(2))*vox(2);
%	bb(:,3) = round(bb(:,3)/vox(3))*vox(3);
%		bb =
%		   -78  -112   -50
%			78    76    85
%		bb =
%		  -77.9167 -112.2917  -51.0000
%		   77.9167   75.6250   84.0000
%	Floowed by:
% 	Convert range into range of voxels within template image
%	x   = (bb(1,1):vox(1):bb(2,1))/vxg(1) + ogn(1);
%	y   = (bb(1,2):vox(2):bb(2,2))/vxg(2) + ogn(2);
%	z   = (bb(1,3):vox(3):bb(2,3))/vxg(3) + ogn(3);  << should have 46 elements (incl 0)


e.roptions.vox= dims;
e.roptions.interp= 7;
e.roptions.wrap= [0 0 0];

jobout.spatial{1}.normalise{1}.estwrite=e;

