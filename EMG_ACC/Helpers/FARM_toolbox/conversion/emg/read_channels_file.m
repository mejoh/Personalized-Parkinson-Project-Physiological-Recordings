% dig through a channels.txt file, and outputs a cell array of the muscle
% names.

function names=read_channels_file(file)
fid=fopen(file);

names={};
while ~feof(fid)
    
    line=fgetl(fid);
    
    a=regexp(line,'[^\s]*','match');
    
    if numel(a)>1
        names{end+1}=a{2};
    else
        names{end+1}='x'
    end
end

fclose(fid);
    
    
    