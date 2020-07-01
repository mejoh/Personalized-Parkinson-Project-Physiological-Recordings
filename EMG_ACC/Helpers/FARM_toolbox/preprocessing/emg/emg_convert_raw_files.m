
function emg_convert_raw_files()


    load ../parameters
    tr=parameters(1);
    nvol=parameters(3);
    nslices=parameters(2);
    

    if numel(regexpi(pwd,'BVA_Export$'))>0
        cd ..
    end
    
    rawfiles=dir('BVA_Export\block_markers.raw');
    
    % keyboard;
    
    if isunix
        rawfiles=dir('BVA_Export/block_markers.raw');
    end
        


    
    for i=1:numel(rawfiles)
        
        filename=['BVA_Export/' rawfiles(i).name];
        if numel(regexpi(filename,'markers.raw$'))>0
            
            % do model-extraction
            disp('extracting model markers');
            [b e srate]=emg_extract_block_markers(filename);

            disp('building and saving custom design matrix');
            emg_markers_2_design(b,e,srate); 
            
            disp('building and saving design matrix, with onset/offset as delta');
            disp('as well as the onsets of stimulus-changes, incorporated');
            emg_markers_2_design_extended(b,e,srate,tr);

            disp('saving markers to b and e struct');
            save markers_block.mat b e srate
            
        end
        % keyboard;
        
        if numel(regexpi(filename,'bad_signal.raw$'))>0
            
            % do bad_signal extraction
            disp('checking bad signal markers');
            [m srate]=emg_read_markerfile(filename);
            save markers_bad_signal.mat m srate
            disp('saving bad signal markers to m struct');
            
            
        end
        
    end