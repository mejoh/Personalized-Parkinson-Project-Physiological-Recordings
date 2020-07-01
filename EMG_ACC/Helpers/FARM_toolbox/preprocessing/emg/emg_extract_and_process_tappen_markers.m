% function emg_extract_markers(filename, prune_vol, prune_conds, prune_ex)
% prune_vol = 0 or (double) t -> prune markers closer than t to a v-marker
% prune_conds = 0 (don't do anything), e (prune markers in an active
% condition + e seconds after that (for muscles that are supposed to do 
% something during a task), [b e] (prune markers around a marker
% that begins an active condition, to remove motion effects -> for muscles
% that are essentially 'quiet'.
% prune_ex = 0 (keep markers outside the measurement) or 1 (remove em)

function ev=emg_extract_and_process_tappen_markers(filename, prune_vol, prune_conds, prune_ex)

% filename='emg_volume_zonder_OBS_BVAmarkers.raw';
fid=fopen(filename);



line=fgetl(fid);
srate=str2double(regexpi(line,'\d{4}','match'));

% sla header-regels over...
while 1
    line=fgetl(fid);

    % skip, until the first one is equal to 'Stimulus and 'V'
    parts=regexp(line,'[^, ]*','match');
    if strcmp(parts{1},'Stimulus')&&strcmp(parts{2},'V')

        break;
    end

end
%%
ev=struct();
time_first_V=str2double(parts{3});
ev.V=time_first_V;
muscles={};

while ~feof(fid)
    
    line=fgetl(fid);

    % skip, until the first one is equal to 'Stimulus and 'V'
    parts=regexp(line,'[^, ]*','match');
    
    % marker info...
    m.type=parts{1};
    m.name=parts{2};
    m.lat=str2double(parts{3});
    m.dummy=parts{4};
    m.ch=parts{5};
    
    
    % store it all in a nice 'ev' structure.
    if strcmp(m.name,'s')
       
        if isfield(ev,m.ch)
            ev.(m.ch)=[ev.(m.ch) m.lat];
        else
            ev.(m.ch)=m.lat;
            muscles{end+1}=m.ch;
        end
        
    else
        
        if isfield(ev,m.name)
            % keyboard
            ev.(m.name)=[ev.(m.name) m.lat];
        else
            ev.(m.name)=m.lat;
        end
        
    end
    
    
    
end


% Nu heb je alles netjes, en ook alles zodat je ze kan modifien
% je gaat ervan uit dat er altijd V is, en altijd tappen, rust en strekken
% en verder staan je 'muscle' fieldnames opgeslagen in muscles, het
% cell-array.
%
%
% 
% 
% ev
% ev = 
%         rust: [1x14 double]
%         ADML: [1x790 double]
%         FDIL: [1x442 double]
%            V: [1x285 double]
%      FlexorL: [1x279 double]
%         ADMR: [1x498 double]
%       tappen: [171593 379188 586783 794379 1001974 1209569 1417164]
%     strekken: [275391 482986 690581 898176 1105771 1313366 1520961]


% en dan nu, V-pruning; gooi alle markers weg die verdacht vlakbij een
% Volume-marker staan!

%% marker pruning, take I

if prune_vol > 0

    for i=1:numel(muscles)


        %
        %
        % volume 'pruning'...
        %
        % go through each volume...
        marked=[];
        for j=1:numel(ev.V)

            % and determine which markers should be expunged.

            for k=1:numel(ev.(muscles{i}))

                % times...
                sampl_V=ev.V(j);
                sampl_M=ev.(muscles{i})(k);

                % 50 ms is an appropriate time difference, for the markers.
                if abs(sampl_V-sampl_M)<0.050*srate

                    % store index for deletion...
                    marked(end+1)=k;
                end

            end

        end
        disp(['removing ' num2str(numel(marked)) ' markers from ' muscles{i} ' due to being too close to a Volume marker']);
        ev.(muscles{i})(marked)=[];
        % and... delete it!

    end

end


%% marker pruning, Take II-A: 
% alleen deel verwijderen dichtbij (-0.5-2 seconden voor en na een 'actie'
% marker: bewegings-verwijdering.

if numel(prune_conds)>1

    begin_purge = prune_conds(1);
    end_purge = prune_conds(2);

    for i=1:numel(muscles)

        marked=[];
        for j=1:numel(ev.tappen)

            beginning=ev.tappen(j)-begin_purge*srate;
            ending=ev.tappen(j)+2*end_purge*srate;

            for k=1:numel(ev.(muscles{i}))

                % sample of the marker
                sampl_M=ev.(muscles{i})(k);

                % if it falls outside; mark the marker for deletion.
                if sampl_M>beginning&&sampl_M<ending
                    marked=[marked k];
                end
            end

        end

        for j=1:numel(ev.strekken)

            beginning=ev.strekken(j)-begin_purge*srate;
            ending=ev.strekken(j)+2*end_purge*srate;

            for k=1:numel(ev.(muscles{i}))

                % sample of the marker
                sampl_M=ev.(muscles{i})(k);

                % if it falls outside; mark the marker for deletion.
                if sampl_M>beginning&&sampl_M<ending
                    marked=[marked k];
                end
            end

        end


        % marked
        disp(['removing ' num2str(numel(marked)) ' markers from ' muscles{i} ' due to being too close to an active condition marker! (to avoid movements)']);
        ev.(muscles{i})(marked)=[];
    end

end


%% marker pruning, take II -- purge an entire active condition
% only use this for active muscles!!

if numel(prune_conds)==1&&sum(prune_conds)>0

    for i=1:numel(muscles)

        %%% condition 'pruning'...
        dur_tappen=round((ev.tappen(2)-ev.tappen(1))/4);
        dur_strekken=round((ev.strekken(2)-ev.strekken(1))/4);



        marked=[];
        for j=1:numel(ev.tappen)

            beginning=ev.tappen(j);
            ending=ev.tappen(j)+dur_tappen+2*srate;

            for k=1:numel(ev.(muscles{i}))

                % sample of the marker
                sampl_M=ev.(muscles{i})(k);

                % if it falls outside; mark the marker for deletion.
                if sampl_M>beginning&&sampl_M<ending
                    marked=[marked k];
                end
            end

        end

        for j=1:numel(ev.strekken)

            beginning=ev.strekken(j)-1*srate;
            ending=ev.strekken(j)+dur_strekken+2*srate;

            for k=1:numel(ev.(muscles{i}))

                % sample of the marker
                sampl_M=ev.(muscles{i})(k);

                % if it falls outside; mark the marker for deletion.
                if sampl_M>beginning&&sampl_M<ending
                    marked=[marked k];
                end
            end

        end


        % marked
        disp(['removing ' num2str(numel(marked)) ' markers from ' muscles{i} ' due to being in (or 2s after) an active condition!']);
        ev.(muscles{i})(marked)=[];
    end

end

%% marker pruning, take III

if prune_ex>0

    for i=1:numel(muscles)
        % boudary of the measurement pruning...
        marked=[];
        for k=1:numel(ev.(muscles{i}))

            sampl_M=ev.(muscles{i})(k);

            if sampl_M<ev.V(1)
                marked=[marked k];
            end
            if sampl_M>ev.V(end)
                marked=[marked k];
            end
        end

        disp(['removing ' num2str(numel(marked)) ' markers from ' muscles{i} ' due to falling outside measurement time.']);
        ev.(muscles{i})(marked)=[];

    end
end


%% na marker pruning; exporteer het model!!!!!


% het standaard model in orde maken...
% names in orde maken...
names={'tappen','strekken'};

% onsets in orde maken...
onsets{1}=(ev.tappen-time_first_V)/srate;
onsets{2}=(ev.strekken-time_first_V)/srate;
durations{1}=round((ev.tappen(2)-ev.tappen(1))/4)/srate*ones(size(onsets{1}));
durations{2}=round((ev.strekken(2)-ev.strekken(1))/4)/srate*ones(size(onsets{1}));

for i=1:numel(muscles)
    names=[names muscles(i)];
    onsets{end+1}=(ev.(muscles{i})-time_first_V)/srate;
    durations{end+1}=zeros(size(onsets{end}));
end

save([filename(1:end-4) '_model.mat'],'names','onsets','durations')