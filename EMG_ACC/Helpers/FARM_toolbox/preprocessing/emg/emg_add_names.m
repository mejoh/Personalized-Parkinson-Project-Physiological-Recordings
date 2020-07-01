function EEGOUT = emg_add_names(EEG)

% baseDir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/ruw/' pp '/'];
% keyboard;

% lees dingen van de file en stop ze in n cell arr.
pp=regexp(pwd,'\d{4}','match');
pp=pp{1};
cfile=['../../../../ruw/' pp '/channels.txt'];
if exist(cfile,'file');
    fid=fopen(cfile);
    p={};
    while ~feof(fid)

        line=fgetl(fid);

        tmp=regexp(line,'[^\s]*','match'); % parts

        try
        p{end+1,1}=tmp{1};
        p{end,2}=tmp{2};

        catch
           % keyboard;
        end

        
    end
    fclose(fid);
else
    p={};
    for i=1:EEG.nbchan
        p{i,1}=' ';
        p{i,2}=num2str(i);
    end
end




% pas EEG 'chanlocs' aan
for i=1:8
    EEG.chanlocs(i).labels=p{i,2};
end
    
EEGOUT=EEG;
