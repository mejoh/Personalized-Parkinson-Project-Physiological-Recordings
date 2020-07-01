function remove_rest_in_block(blockfile, saveas)
    % THIS FUNCTION is obsolete since 2010-01-07 and is replace by 'Compose Conditions' in GUI.
    
    % Rust tijdens model verwijderen remove rest in 
    % Orthogonaliseren moet altijd gebeuren met het gewone blok.mat of block_emg.mat gebeuren. 
    % block_emg_without_rest kun je openen voor je model in SPM, onder multiple conditions.

    if nargin==0
        error('Missing 1 or two arguments in remove_rest_in_block');
    elseif nargin==1
        regressordir=blockfile; % if there is only one argument, then this shoud be the protocols specific regressor dir
        remove_rest_in_block(fullfile(regressordir,'block_emg.mat'), fullfile(regressordir,'block_emg_without_rest.mat')); 
        remove_rest_in_block(fullfile(regressordir,'block.mat'), fullfile(regressordir,'block_without_rest.mat')); 
    else
        try
            load(blockfile); % of block.mat
            durations2=cell(1,3);
            durations2{1}=durations{1};
            durations2{2}=durations{2};
            durations2{3}=durations{3};
            durations=durations2;

            onsets2=cell(1,3);
            onsets2{1}=onsets{1};
            onsets2{2}=onsets{2};
            onsets2{3}=onsets{3};
            onsets=onsets2;

            names2=cell(1,3);
            names2{1}=names{1};
            names2{2}=names{2};
            names2{3}=names{3};
            names=names2;

            save(saveas,'durations','onsets','names');
            disp(['saved ' saveas]);
        catch
            msgbox([blockfile ' could not be found'],'Error')
        end

    end
end