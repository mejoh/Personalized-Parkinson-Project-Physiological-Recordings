function batch_run_models(study,pp)

    

    % verwijder alles... dat gaat sneller ivm de vraag of je de al
    % bestaande SPM.mat wel wil overschrijven; dit bypassed deze
    % foutmelding.
    clean_task(study,pp,'gonogo','event');
    clean_task(study,pp,'motor_tappen','motor_tappen_block');
    clean_task(study,pp,'motor_tappen','motor_tappen_block_with_rest');

    % prep & group gonogo... event-related design. mag later ook block zijn of
    % iets exotischer.
    prep_task(study,pp,'gonogo1','gonogo_event');
    prep_task(study,pp,'gonogo2','gonogo_event');
    prep_task(study,pp,'gonogo3','gonogo_event');
    group_measurements(study,pp,{'gonogo1','gonogo2','gonogo3'},'gonogo','event');

    % prep de motor taak voor 2 analyses...
    prep_task(study,pp,'motor_tappen','motor_tappen_block');
    prep_task(study,pp,'motor_tappen','motor_tappen_block_with_rest');
    
    
    % en doe volledige modelling, incl. contrasts en een report.
    % keyboard;
    run_model(study,pp,'gonogo','event','swa');
    run_model(study,pp,'motor_tappen','block','swa');
    run_model(study,pp,'motor_tappen','block_with_rest','swa');
    

