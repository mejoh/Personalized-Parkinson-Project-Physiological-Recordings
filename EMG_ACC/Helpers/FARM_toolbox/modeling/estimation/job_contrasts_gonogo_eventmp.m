function jobout=job_contrasts_gonogo_eventmp(study,pp)

    rdir=['x:/Onderzoek/fMRI/' study '/results/' pp '/gonogo/eventmp/'];

    
    % !! StopRespond is nu de 'impliciete baseline'. Deze moet je dus niet
    % in je model mikken (?). of juist wel???
    
    c.spmmat={[rdir 'SPM.mat']};
    
    c.consess{1}.tcon.name='StopInhibit';
    c.consess{1}.tcon.convec=[0 0 1];
    
    c.consess{2}.tcon.name='StopRespond';
    c.consess{2}.tcon.convec=[0 1 0];

    c.consess{3}.tcon.name='GoInhibit';
    c.consess{3}.tcon.convec=[1 0 0];

    c.consess{4}.tcon.name='Stop(Inhibit-Repond)';
    c.consess{4}.tcon.convec=[0 -1 1];

    c.consess{5}.tcon.name='Stop(Repond-Inhibit)';
    c.consess{5}.tcon.convec=[0 1 -1];

    c.consess{6}.tcon.name='(Stop-Go)Inhibit';
    c.consess{6}.tcon.convec=[-1 0 1];

    c.consess{7}.tcon.name='(Go-Stop)Inhibit';
    c.consess{7}.tcon.convec=[1 0 -1];


    
    % keyboard;
    % doe nu de magic.
    % hoeveel instances of gonogo are there in de resultsdir?
    dm=dir([rdir 'model*.txt']);
    sessions=numel(dm);
    
    for i=1:numel(c.consess) % i gaat over de # contrasts...

        % adding 6 zeros, for the motion parameters...
        v = [c.consess{i}.tcon.convec zeros(1,6)];
        
        % matrix magic...
        v=ones(sessions,1)*v;
        v=reshape(v',1,numel(v));
        
        
        c.consess{i}.tcon.convec=v;
    end
    
    jobout.stats{1}.con=c;
