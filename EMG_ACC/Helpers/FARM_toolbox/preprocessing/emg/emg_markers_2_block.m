% manually marker each onset, as you think it's the best possible way for
% the block model.
% marker as extra the beginning, with usr_rest, and also as extra, the end,
% as 'end'.
% export all relevant markers only (!!) + the one marker at the end, namely
% 'end'.

function emg_markers_2_block(filename)



    % filename='emg_volume_zonder_OBS_BVAmarkers.raw';
    fid=fopen(filename);



    line=fgetl(fid);
    srate=str2double(regexpi(line,'\d{4}','match'));




    b=struct(); % to declare our onset-times.

    while ~feof(fid)

        line=fgetl(fid);

        parts=regexp(line,'[^, ]*','match');

        if strcmp(parts{1},'Stimulus')

            % marker info...
            m.type=parts{1};
            m.name=parts{2};
            m.lat=str2double(parts{3});
            m.dummy=parts{4};
            m.ch=parts{5};


            % store it all in a nice 'ev' structure.
            if strcmp(m.name,'s')

                if isfield(b,m.ch)
                    b.(m.ch)=[b.(m.ch) m.lat];
                else
                    b.(m.ch)=m.lat;
                    muscles{end+1}=m.ch;
                end

            else

                if isfield(b,m.name)
                    % keyboard
                    b.(m.name)=[b.(m.name) m.lat];
                else
                    b.(m.name)=m.lat;
                end

            end
        end

    end

% so you have b, now make ... e!
% goal is to have for each b, an e.
names=fieldnames(b);
    
    t1=[];
    for i=1:numel(names)
        t1=[t1 b.(names{i})];
    end

    t2=[];
    for i=1:numel(names)
        t2=[t2 i*ones(1,numel(b.(names{i})))];
    end
    
    t3=[];
    for i=1:numel(names)
        t3=[t3 1:numel(b.(names{i}))];
    end
    
    
    
    t4=[t1;t2;t3]';
    t4=sortrows(t4,1);
    
    
    e=b;
    
    for i=1:size(t4,1)-1
        
        e.(names{t4(i,2)})(t4(i,3))=t4(i+1,1)-1;
    end
    
    

    
    % piece where you make a block design.
    names=fieldnames(b);
    names=names(1:end-1)';
    
    onsets={};
    durations={};
    
    for i=1:numel(names)
        
        onsets{i}=b.(names{i})/srate;
        durations{i}=(e.(names{i})-b.(names{i}))/srate;
    end
        
        
    
    save usr_block.mat names onsets durations
    movefile usr_block.mat ../../regressor/.
    
    names(end)=[];
    onsets(end)=[];
    durations(end)=[];
    save usr_block_no_rest.mat names onsets durations
    movefile usr_block_no_rest.mat ../../regressor/.
    
    
    
    
    
    




