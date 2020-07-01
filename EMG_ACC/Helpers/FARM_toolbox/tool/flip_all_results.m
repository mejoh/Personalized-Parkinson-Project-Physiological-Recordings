% flip all of the images in this directory.
% this function will accept also an uncompleted analysis directory, such
% as: JGAAmark1, instead of: JGAAmark1_L123.
%
% use with caution!
%
% only flip images if the task has been executed with the 'wrong' hand!
%
% function flip_all_results(study,pp,task,analysis)

function flip_all_results(study,pp,task,analysis)

% do it, so that this function will will 

search=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/results/' analysis];
rdirname=dir([search '*']); % get the dir...


rdir=[regexprep(search,'(.*)/(.*)$','$1') '/' rdirname.name '/']; % and append a slash.

disp(rdir);



hdrfiles=dir([rdir '*.hdr']);


% remove those files that've already been flipped from this list.
mark=[];
for i=1:numel(hdrfiles);
    if regexp(hdrfiles(i).name,'_unflipped')
        mark=[mark i];
    end
end
hdrfiles(mark)=[];


for i=1:numel(hdrfiles);
    
    name=hdrfiles(i).name(1:end-4);
    
    
    if exist([rdir name '_unflipped.hdr'],'file')
        disp(['you already have ' name '_unflipped.{img,hdr} files. Skipping this one.']);
    else
        

        disp(['flipping... ' name '.img']);

        nii=load_nii([rdir name]);

        % save it to name + flipped...
        save_nii(nii,[rdir name '_unflipped']);
        delete([rdir name '_unflipped.mat']);       % remove mat files.

        nii.img=flipdim(nii.img,1);
        save_nii(nii,[rdir name]);
        delete([rdir name '.mat']);                 % remove mat files.
        
    end
    
end

disp(['done flipping, rdir = ' rdir]);