function result = SaveProfile( profilename )
%SaveProfile saves the profile cell array from the base workspace
%   The embedded profile name will be used if no profile name was specified

    emg_fmri_globals; % make sure this is the first call in the fn
    
    result = false;
    
    profiledir = fullfile(EMG_fMRI_study_dir,'profiles');
    
    % check if there is a directory profiles, if not make one
    if ~isdir(profiledir)
        mkdir(profiledir);
    end
    
    try
        % get profile from base workspace
        profile = EMG_fMRI_profile;
        % prompt for a filename if none was provided
        if nargin<1
            if iscell(profile{1})
                profilename = char(profile{1});
            else
                profilename = profile{1};
            end
            [filename pathname ] = uiputfile(fullfile(profiledir, [profilename '.mat']), 'Save Profile as');
            if filename==0
                return;
            end
        else
            % strip path and/or extension if included
            [pathname profilename ] = fileparts(profilename);
            filename = [profilename '.mat'];
            if isempty(pathname)
                pathname = profiledir;  % use the default profile directory
            end
        end
        if ~isempty(profilename)
            EMG_fMRI_profile{1} = profilename;
            save(fullfile(pathname,filename),'EMG_fMRI_profile');

            % save as last_used_profile
            save(fullfile(pathname,'last_used_profile.mat'), 'EMG_fMRI_profile');
            
            result = true;
        end
    catch
        msgbox('There are no parameters to save','Error');
    end

end

