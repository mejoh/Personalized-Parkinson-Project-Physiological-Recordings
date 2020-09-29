% mission statement:

% ik heb 20x 2 analysis gedaan; 1 block en 1 block met mov. parameters.
% ik wil de 2 resultaten naast elkaar leggen, met movement parameters erbij
% en dus ook met de ruwe data erbij om een idee te geven van de
% 'rubuustness' van de fmri data.
%
% omdat ik niet 200x wil copy-pasten, maak ik er een mooi scriptje van.

function report_blocks(pp)

pp=num2str(pp);


study='Loops';
task='motor_tappen';

analyses={'pd_distal','pd_proximal'};

base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');

% the pdir, of... picture (!!) directory!! 
pdir=[base 'Onderzoek/fMRI/' study '/pics/myo1/' pp '/'];
if~isdir(pdir)
    mkdir(pdir)
end

jobs={};
count=0; % image counter...
for i=1:numel(analyses)

    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/results/' analyses{i} '/'];
    model=load([rdir 'model.mat']);
    muscles=regexprep(model.names(3:end),'.* ','');
    
    
    % con=load([rdir 'contrasts.mat']);
    contrasts=[1 3 4 5];
    
    for j=1:numel(contrasts)
    
        count=count+1;
        % mooie grafiekjes van de resultaten gegenereerd door SPM.. van
        % tappen.
        % keyboard;

        jobs{1}=job_results(study,pp,task,analyses{i},contrasts(j),'None',0.005,0);
        % workaround for windows vs linux machines...
        % keyboard;
        jobs=dir_fix(jobs);
        
        try
            spm_jobman('run',jobs);
        catch
            keyboard;
        end
        saveas(gcf,[pdir 'out_' num2str(i) num2str(j)],'jpg');

        fid=fopen([pdir 'muscles.txt'],'w+');
        for k=1:numel(muscles)
            fprintf(fid,[muscles{k} '\n']);
        end
        
        fclose(fid);
    end
end



% nu mooi grafiekje van de movement parameters
% the regressor-directory!
count=count+1;
rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/regressor/'];
rp_a4D=[];
load([rdir 'rp_a4D.txt']);
figure;subplot(2,1,1);plot(rp_a4D(:,1:3));
legend({'x translation','y translation','z translation'},'location','best');
xlabel('scans');ylabel('mm');
title('movement parameter report');
subplot(2,1,2);plot(rp_a4D(:,4:6));
legend({'pitch','roll','yaw'},'location','best');
xlabel('scans');ylabel('degrees');
saveas(gcf,[pdir 'out' num2str(3)],'jpg');
close(gcf);




% % en als laatste de ruwe data.
count=count+1;
jobs{1}=job_display(study,pp,task,'',1);
spm_jobman('run',jobs);
saveas(gcf,[pdir 'out' num2str(4)],'jpg');




