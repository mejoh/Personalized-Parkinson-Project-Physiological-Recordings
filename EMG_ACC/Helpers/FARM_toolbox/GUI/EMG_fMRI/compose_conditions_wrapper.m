function compose_conditions_wrapper(  )
%COMPOSE_CONDITIONS_WRAPPER - starting point for creating an SPM compatible multiple conditions file.
%   This works by loading the block file containing all conditions, and then saving only the selected
%   conditions as new file

    emg_fmri_globals; % make sure this is the first call in the fn

    protocols = select_protocols;

    % then collect all relevant block*.mat files from all selected protocol directories
    filelist = {};
    for iSelection=1:numel(protocols)
        regressordir = fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, protocols{iSelection}, 'regressor');
        
        d = dir(fullfile(regressordir,'block*.mat'));
        str = {d.name};
        if iSelection==1
            filelist = str;
        else
            filelist = union(filelist,str); % use intersection if you only wan't files that exist in all selected protocols (instead of any)
        end

    end
    
    % and finally show the available files, and open the condition selection dialog
    if ~isempty(filelist)
        [selection_indices, answer] = listdlg('PromptString','Select condition files',...
                    'ListSize',[160,100],...
                    'SelectionMode','single',...
                    'ListString',filelist);

        if answer==0 || isempty(selection_indices)
            return
        end
        filename = str{selection_indices};
        
        compose_conditions(protocols,filename);%fullfile(pathname,filename))
    end

end

