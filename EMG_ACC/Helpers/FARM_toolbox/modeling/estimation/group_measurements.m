% this function groups measurements.
% it basically copies stuff from session1, session2, sessionN, to
% 'target'.
% and makes model1.mat,model2.mat, etc etc.
% and updates nvol(i)
% copies the tr.txt
% and makes regressor1.txt,regressor2.txt, etc..
% and makes datadir1.mat, datdir2.mat, etc.
% this is the function that ensures you can group measurements from 

function group_measurements(study,pp,sessions,target,analysis)

    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');

    tdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' target '/results/' analysis];
    
    mkdir(tdir);

    
    for i=1:numel(sessions)
        
        if isdir([base 'Onderzoek/fMRI/' study '/pp/' pp '/' sessions{i}]);
            sdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' sessions{i} '/results/' analysis];

            types={'model','datadir','regressors'};
            for filename=types
                % keyboard;
                f=dir([sdir '/' filename{1} '*']);
                for j=1:numel(f)
                    copyfile([sdir '/' f.name],[tdir '/' f.name(1:end-4) num2str(i) f.name(end-3:end)]);
                end
            end

            % append the # of volumes.
            load([sdir '/nvol.txt']);
            if i>1
                % keyboard;
                old=load([tdir '/nvol.txt']);
                nvol=[old nvol];
            end

            save([tdir '/nvol.txt'],'nvol','-ascii');
        end

    end
    
    % copy the tr.txt
    copyfile([sdir '/tr.txt'],[tdir '/tr.txt']);

    
    
    % and final touch... de contrasts.mat file.
    load([sdir '/contrasts.mat']);
    % de laatste... heeft precies dezelfde contrasts als de eerste.
    % i=imax op dit moment, dus onderstaande - while slordig - mag wel.
    % dit hoeft dus waarschijnlijk helemaal niet (!!!!)
%     for j=1:size(contrasts,1)
%         tmp=contrasts{j,2};
%         contrasts{j,2}=repmat(tmp,1,numel(sessions));
%     end
    save([tdir '/contrasts.mat'],'tcontrasts','fcontrasts');
    
    

    
    

    
    