function fmri_t1rotate(study,pp,wdir)

% wdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/t1/'];
% disp(wdir);
% 
% copyfile([wdir 't1.img'],[wdir 't1_old.img']); % backup
% copyfile([wdir 't1.hdr'],[wdir 't1_old.hdr']);
% 
% 
% a=load_nii([wdir 't1.hdr']);
% 
% 
% disp(a.hdr.hist);
% 
% % draaien naar 'axiale' orientatie...
% newmat=[...
%     0  0  1  -80;...
%    -1  0  0  100;...
%     0  1  0 -160;...
%     0  0  0    1;...
% ];
% 
% 
% a.hdr.hist.srow_x = newmat(1,:);
% a.hdr.hist.srow_y = newmat(2,:);
% a.hdr.hist.srow_z = newmat(3,:);
% 
% save_nii(a,[wdir 't1']);
% delete t1.mat;

% apparently, the above doesn't seem to work, perhaps due to nifti bug? 
% so i'm gonna do this the brute force way. Simply 'copy' a t1.hdr over the
% existing t1.hdr.

if nargin<3
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/t1/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/t1/'];
end
% 2009-10-06; paul replaced absolute path with the dynamically retrieved path of this file
%sdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'ICT/Software/mltoolboxes/emgfmri/preprocessing/fmri/'];
sdir = [fileparts(mfilename('fullpath')), filesep]; % get my path and append a path seperator
disp(wdir);

if exist([wdir 't1.img'],'file')

    copyfile([wdir 't1.img'],[wdir 't1_old.img']);
    copyfile([wdir 't1.hdr'],[wdir 't1_old.hdr']);

    copyfile([sdir 't1.hdr'],[wdir 't1.hdr']);

    disp(['i copied a t1.hdr that has axial orientation over the old t1.hdr, which should have sagittal orientation. better double-check, pp = ' pp]);

else
    disp('no T1 found');
end
