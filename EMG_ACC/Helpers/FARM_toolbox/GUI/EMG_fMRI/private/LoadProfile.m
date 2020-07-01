function [ profile ] = LoadProfile(profilename, update_base, create_if_missing )
%LoadProfile_LastUsed loads the last used EMG preprocessing profile from current study dir
% 2009-09-30, created by Paul

    emg_fmri_globals; % make sure this is the first call in the fn

    if nargin<2
        update_base = true;
    end
    if nargin<3
        create_if_missing = true;
    end

    profile_dir = fullfile(EMG_fMRI_study_dir, 'profiles');
    if ~isdir(profile_dir)
        if create_if_missing
            mkdir(profile_dir);
        else
            error(['profile directory doesn''t exist: ' profile_dir]);
        end
    end
    
    if nargin<1
        if exist(fullfile(profile_dir,'last_used_profile.mat'),'file')
            profilename = 'last_used_profile';
        else
            profilename = 'Standard Profile';
        end
    end
    
    % check if profilename already contains a path
    [path, profilename, extension] = fileparts(profilename);
    if isempty(path)
        path = profile_dir;
    end
    if isempty(extension)
        extension = '.mat';
    end
    profilepath = fullfile(path, [profilename extension]);

    try
        load(profilepath);
        profile = EMG_fMRI_profile;
        disp(['loaded profile: ' EMG_fMRI_profile{1}]);
    catch
        profile = cell(7,1);
        profile{1} = profilename; % 'Standard Profile'
        profile{2} = 4; %channel number
        profile{3} = 25; %high pass filter
        profile{4} = [0 10 10 0.03]; % slice artifact filter
        profile{5} = [0 10 10 0.07]; % VOLUME artifact fiter
        profile{6} = [20 250]; % bandpassfilter
        if create_if_missing
            EMG_fMRI_profile = profile;
            save(profilepath, 'EMG_fMRI_profile')
            save(fullfile(profile_dir,'last_used_profile.mat'), 'EMG_fMRI_profile')
        end
        disp('created default profile!')
    end

    if update_base
        EMG_fMRI_profile = profile;
    end
end

