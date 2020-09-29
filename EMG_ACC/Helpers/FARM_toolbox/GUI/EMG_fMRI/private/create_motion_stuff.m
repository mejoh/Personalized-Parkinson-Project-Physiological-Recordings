function create_motion_stuff()

    % This script will calculate scan nulling regressors for excluding motion
    % artefacts from scan sequences. Based on Johan's fmri_scan_nulling script.

    % define the root of the data
    datapath='D:/data/Onderzoek/motion-files';
    % datapath = 'X:/Onderzoek/Lopend_onderzoek/fMRI/Tremor/pp';

    % browse all subfolders
    patdirs = dir(fullfile(datapath,'*'));

    % avd_thresh = velocity threshold. (nominal value reported by Lemieux is 0.2 [mm/scan (1 scan = 3 sec in Lemieux)].
    % However, we shall use 0.4 otherwise all of our scans (sometimes!) are
    % lost! And also we use a shorter scan of about 2.6 [s], so our velocity
    % threshold should be a little higher. This logic is actually flawed,
    % because a jerk is a jerk is a jerk. And jerks will probably give you 0.2
    % even with shorter scanning duration.
    avd_thresh = 0.4;   % the threshold for amount of motion/scan. arbitrary.
                        % avd = abs value of the derivative of d.

    null_length=2;  % Lemieux et al. used 5
                    % the derivative = y(n+1)/2 - y(n-1)/2.
                    % ie. 12.5 [s].

    TR = 2.9;       % TR

    fid = fopen(fullfile(datapath,'motion-stats.txt'),'wt');

    for iEntry=1:length(patdirs)
        if patdirs(iEntry).isdir
            patid = patdirs(iEntry).name;
            if patid(1)~='.'
                for iTremor=1:2
                    rdir = fullfile(datapath, patid, sprintf('tremor%d',iTremor), 'regressor');
                    rp_a4D_path = fullfile(rdir, 'rp_a4D.txt');
                    if exist(rp_a4D_path,'file')
                        rp_a4D = load(rp_a4D_path,'-ascii');

                        d=sqrt(rp_a4D(:,1).^2+rp_a4D(:,2).^2+rp_a4D(:,3).^2);
                        volumeCount=length(d);
                        avd=[0;abs(d(3:end)-d(2:end-1))/2+abs(d(2:end-1)-d(1:end-2))/2;0];
                        motion_nulls=conv(single(avd>avd_thresh),ones(null_length,1))>0;
                        motion_nulls=motion_nulls(1:volumeCount);
                        nullCount=sum(motion_nulls);

                        % making the null-matrix; mat.
                        tmp=find(motion_nulls);
                        mat=zeros(volumeCount,nullCount);
                        for i=1:numel(tmp);
                            mat(tmp(i),i)=1;
                        end

                        % load the horn nulling info if available
                        horn_nulling_filename = fullfile(rdir, 'nulling_horns.txt');
                        horn_nulls = [];
                        diff_nulls = [];
                        if exist(horn_nulling_filename,'file')
                            horn_nulls = load(horn_nulling_filename,'-ascii');
%							horn_nulls = abs(horn_nulls)>0.1;
                            horn_nulls = sum(horn_nulls,2); % combine all individual nulling columns back into one regressor
                            horn_nulls = sign(horn_nulls);
                            diff_nulls = max(zeros(size(motion_nulls)), (motion_nulls-horn_nulls)); % check where we have a motion artefact without a horn
                        end

                        % report it.
                        fh=figure;
                        plot(avd)
                        hold on;
                        [X Y] = MakeBox(0.75*motion_nulls);
                        plot(X,Y,'g')
                        str_legend = {'distance/scan', 'motion art.'};
                        if ~isempty(horn_nulls)
                            % same for the other box plot
                            [X Y] = MakeBox(diff_nulls);
                            plot(X,0.99.*Y,'r')
                            str_legend{end+1} = 'missed EMG art.';
                            
                            % hmm.... tricky: we have to make square waves with
                            % rectangular edges, so insert extra points at edge
                            % (but also could have used 'stairs' plot)
                            [X Y] = MakeBox(horn_nulls);
                            plot(X,0.5.*Y,'m')
                            str_legend{end+1} = 'EMG art.';
                        end
                        ylim([0 1.0])
                        xlim([0 numel(d)]);
                        line(get(gca,'xlim'),[1 1]*avd_thresh,'LineStyle','--','color','k');
                        str_legend{end+1} = sprintf('threshold %g',avd_thresh);
                        th=title(sprintf('%s\n\n%g scans > thresh (%g)  null length = %g (%.3g s): rejected %.3g%% (%g/%g) scans.', ...
                            rdir, ...
                            sum(avd>avd_thresh),avd_thresh, ...
                            null_length,TR*null_length,nullCount/volumeCount*100, ...
                            nullCount, ...
                            volumeCount));

                        set(th,'interpreter','none');
                        set(gcf,'color','w')
                        legend(str_legend,'location','NorthEast');
                        xlabel(sprintf('scans   1 scan = %g [sec]',TR));
                        ylabel(sprintf('velocity  [mm/scan], |d\''|_{avg} = %.3g, |d\''|_{max} = %.3g',mean(avd),max(avd)));


                        fh_motionparams=figure;
                        subplot(2,1,1);
                        plot(rp_a4D(:,1:3));
                        title([patid ' translation (mm)']);
                        xlim([0 numel(d)]);
                        ylim([-3.1 3.1]);
                        legend({'x','y','z'},'location','NorthEast');
                        subplot(2,1,2);plot(rp_a4D(:,4:6));
                        xlim([0 numel(d)]);
                        ylim([-0.055 0.055]);
                        title('rotation (deg)');
                        xlabel('scans');

                        saveas(fh, fullfile(rdir, 'nulling_motion.jpg'),'jpg');
                        saveas(fh, fullfile(rdir, 'nulling_motion.fig'),'fig');
                        saveas(fh_motionparams, fullfile(rdir, 'motion_parameters.jpg'),'jpg');

                        save(fullfile(rdir, 'nulling_motion.txt'),'mat','-ascii');

                        T = [avd,motion_nulls,horn_nulls,diff_nulls];
                        save(fullfile(rdir, 'nulling_compared.txt'),'T','-ascii');
                        
                        close(fh);
                        close(fh_motionparams);

                        % add some info to log file
                        if fid~=-1
                            fprintf(fid,'reading %s\n',rp_a4D_path);
                            fprintf(fid,'number of volumes       : %03d\n',volumeCount);
                            fprintf(fid,'number of nulled motion : %03d\n',nullCount);
                            fprintf(fid,'number of nulled horns  : %03d\n',sum(horn_nulls));
                            fprintf(fid,'number of missed motion : %03d\n',sum(diff_nulls));
                            fprintf(fid,'\n');
                        end
                    else
                        if fid~=-1
                            fprintf(fid,'file not present         : %s\n\n',rp_a4D_path);
                        end
                    end
                end
            end
        end
    end

    if fid~=-1
        fclose(fid);
    end
end

function [X Y] = MakeBox(V)
    % hmm.... tricky: we have to make square waves with
    % rectangular edges, so insert extra points at edge
    Y = V(1);
    X = 1;
    for ii=2:size(V)
        if V(ii)~=V(ii-1)
            Y(end+1) = V(ii-1); % copy previous one
            X(end+1) = ii;
        end
        Y(end+1) = V(ii);
        X(end+1) = ii;
    end
end
