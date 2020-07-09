% mission statement:

% ik heb 20x 2 analysis gedaan; 1 block en 1 block met mov. parameters.
% ik wil de 2 resultaten naast elkaar leggen, met movement parameters erbij
% en dus ook met de ruwe data erbij om een idee te geven van de
% 'rubuustness' van de fmri data.
%
% omdat ik niet 200x wil copy-pasten, maak ik er een mooi scriptje van.

% deze functie is nu 'geobviate' door fmri_generate_report.


function report_blocks_with_emg(study,pp,task,analysis)

pp=num2str(pp);

base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/results/' analysis '/'];
regdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/regressor/'];

base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');

% the pdir, of... picture (!!) directory!! 


model=load([rdir 'model.mat']);
mname=regexprep(analysis,'([^_]*_)(.*)(_[\d]*)','$2');
% prefix=regexprep(analysis,'([^_]*_)(.*)(_[\d]*)','$1');
regname=ls([regdir 'pd_' mname '*']);
regdata=load(regexprep(regname,'(.*)(.mat)(.*)','$1$2'));
muscles={mname};


pdir=[base 'Onderzoek/fMRI/' study '/pics/myo3/' mname '/' pp '/'];
if ~exist(pdir,'dir');
    mkdir(pdir);
end


% save the number of events!
% keyboard

% save([pdir 'tot_events.txt'],'events','-ascii');
% save([pdir analysis '.txt'],'events','-ascii');



if~isdir(pdir)
    mkdir(pdir)
end

jobs={};
count=0; % image counter...






% con=load([rdir 'contrasts.mat']);
contrasts=[1 2 3 4];

for j=1:numel(contrasts)

    count=count+1;
    % mooie grafiekjes van de resultaten gegenereerd door SPM.. van
    % tappen.
    % keyboard;

    jobs{1}=job_results(study,pp,task,analysis,contrasts(j),'None',0.005,0);
    % workaround for windows vs linux machines...
    % keyboard;
    jobs=dir_fix(jobs);

    try
        spm_jobman('run',jobs);
    catch
        % keyboard;
        lasterr
    end

    saveas(gcf,[pdir 'out' num2str(j)],'jpg');

    close(gcf);
    
end


fid=fopen([pdir 'muscles_info.txt'],'w+');
fprintf(fid,[muscles{1} '\n']);

for i=1:numel(regdata.pmod)
    fprintf(fid,sprintf('%d\n',numel(regdata.pmod(i).param{1})));
end
fprintf(fid,regexprep(regname,'.*(.)(.mat*)','$1'));
fclose(fid);

        


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
saveas(gcf,[pdir 'out' num2str(5)],'jpg');
close(gcf);


% wat zouden we voorstellen als we niet ook nog een mooi plaatje maken van
% de data van de spier??
mname=regexprep(analysis,'(pd3_)(.*)(_[\d]*)','$2');
regname=ls([regdir 'pd_' mname '*']);
regdata=load(regexprep(regname,'(.*)(.mat)(.*)','$1$2'));
% keyboard;
fh=parmod_grapher(regdata.pmod,{'rust','tappen','strekken'});
saveas(fh,[pdir 'out' num2str(6)],'jpg');
set(fh,'visible','off');




% % en als laatste de ruwe data.
count=count+1;
jobs{1}=job_display(study,pp,task,'',1);
spm_jobman('run',jobs);
saveas(gcf,[pdir 'out' num2str(7)],'jpg');




