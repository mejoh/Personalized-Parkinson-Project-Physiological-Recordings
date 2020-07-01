% this function re-scales the parts of the emg defined by the vec
% cell-matrix.
% using a top-secret mode detection algorithm

function [s vec] = emg_scale_emg(s,vec)



    for i=1:numel(vec)
        
        % do estimate median-per-condition.
        % first sum the appropriate v;
        
        % median of the abs value of all points within vec{i}.
        maxbin=5*median(abs(s(find(sum(vec{i})))));
        
        avmodev=[];
        for j=1:size(vec{i},1);
            
            
            v=vec{i}(j,:);
            
            % temporary 's'...
            ts=s(find(v));
            
            
            % determine the mode
            try
                [mode fh]=my_mode(ts,maxbin,1,1);
            catch
                keyboard;
                
            end
            if ~isdir('modecheck')
                mkdir('modecheck');
            end
            title=['modecheck/mode_' num2str(i) '_' num2str(j,'%.2d')];
            saveas(fh,title,'jpg');
            close(fh);
            
            
            avmodev(end+1)=mode;
            s(find(v))=ts/mode;
            % keyboard;
            disp(['dividing part ' num2str(i) '-' num2str(j) ' with modus ' num2str(mode)]);
            
        end
        
        % and then re-scale with the average modus of it all.
        avmode=mean(avmodev);
        disp(['average mode of part ' num2str(i) ' is ' num2str(avmode)]);
        
        
        disp(['multiplying part ' num2str(i) '-' num2str(j) ' with average modus ' num2str(avmode)]);
        
        
        
        for j=1:size(vec{i},1);
            
            v=vec{i}(j,:);
            
           	% dividing with the mode.
            ts=s(find(v));
            s(find(v))=ts*avmode;
            
            
            
        end
        
        
    end
    

    for i=1:numel(vec)
        vec{i}=sum(vec{i});
    end
    
            
            
            

