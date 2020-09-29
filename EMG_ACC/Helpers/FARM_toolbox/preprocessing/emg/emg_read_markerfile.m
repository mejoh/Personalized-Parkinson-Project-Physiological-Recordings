
% this function reads bb and be markers from a .raw file and stores it to 
function [b srate] = emg_read_markerfile(filename)



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