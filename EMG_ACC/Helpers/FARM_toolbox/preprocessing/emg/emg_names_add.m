function out = emg_add_channelnames(in,study,pp)

baseDir=[regexp(pwd,'^.','match','once') ':/Onderzoek/fMRI/' study '/ruw/' pp '/'];


% lees dingen van de file en stop ze in n cell arr.
fid=fopen([baseDir 'channels.txt']);
p={};
while ~feof(fid)
    
    line=fgetl(fid);
    
    tmp=regexp(line,'[^\s]*','match'); % parts
    
    p{end+1,1}=tmp{1};
    p{end,2}=tmp{2};
    
end
fclose(fid);



% pas EEG 'chanlocs' aan
for i=1:8
    in.chanlocs(i).labels=p{i,2};
end
    
out=in;
