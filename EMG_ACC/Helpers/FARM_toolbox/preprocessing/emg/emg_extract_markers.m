% function emg_extract_markers(filename)

filename='motor_tappen_BVAmarkers.raw';
fid=fopen(filename);

% we nemen aan dat er een 'muscles.mat' bestaat, met alle
% spier-definitiets. daarin staat dan ook de juiste volgorde van de
% spieren.
load ../muscles
names=muscles(1:8);
for i=1:8
    onsets{i}=[];
    durations{i}=[];
end

line=fgetl(fid);
srate=str2double(regexpi(line,'\d{4}','match'));

% sla header-regels over...
while 1
    line=fgetl(fid);

    % skip, until the first one is equal to 'Stimulus and 'V'
    parts=regexp(line,'[^, ]*','match');
    if strcmp(parts{1},'Stimulus')&&strcmp(parts{2},'V')break;end

end



time_first_V=str2double(parts{3});

while ~feof(fid)
    
    line=fgetl(fid);

    % skip, until the first one is equal to 'Stimulus and 'V'
    parts=regexp(line,'[^, ]*','match');
    
    % marker info...
    m.type=parts{1};
    m.name=parts{2};
    m.lat=str2double(parts{3});
    m.dummy=parts{4};
    m.name=parts{5};
    
    if strcmp(parts{1},'Stimulus')
        
        % disp(line);
        
    end
    
    if strcmp(parts{1},'Response') % the markers.
        disp(line);
        inum=find(strcmp(m.name,muscles));

        latency=(m.lat-time_first_V)/srate;

        
        onsets{inum}(end+1)=latency;
        durations{inum}(end+1)=1;
    end
    
    
    
    

    
end

    % je kan markers onderverdelen per spier, en ook nog per b/e.
    mark=[];
    for i=1:8
        if numel(onsets{i})==0
            mark(end+1)=i;
        end
    end
    names(mark)=[];
    onsets(mark)=[];
    durations(mark)=[];



% output is een mat-file, met names onsets en durations (zoals normaal
% SPM5 format). Nouja, normaal...

