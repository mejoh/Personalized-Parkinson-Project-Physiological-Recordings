function [ protocols ] = select_protocols( allow_multiple_select )
%SELECT_PROTOCOLS This function will show a simple protocol selection dialog
%   Set allow_multiple_select to true to allow selection of 1 or more protocols.
% 2010-01-07, by paul

    emg_fmri_globals; % make sure this is the first call in the fn

    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end
    
    if nargin<1
        allow_multiple_select = true;
    end
    if allow_multiple_select
        selection_mode = 'multiple';
    else
        selection_mode = 'single';
    end
    
    % first select the protocol(s) by showing a simple list dialog
    protocols = EMG_fMRI_proto_answer; % no need to copy this one to handles
    protocols(cellfun(@isempty,protocols)) = [];
    nProtocols = length(protocols);
    if nProtocols>0
		if allow_multiple_select
			selection_indices = (1:nProtocols); % select all initially
		end
        [selection_indices, answer] = listdlg('PromptString','Select protocol(s)',...
                    'ListSize',[160, 8+16*nProtocols],...
                    'SelectionMode',selection_mode,...
                    'InitialValue',selection_indices,...
                    'ListString',protocols);

        if answer==0 || isempty(selection_indices)
            protocols = {};
        else
            protocols = { EMG_fMRI_proto_answer{selection_indices} };
        end
    end
end

