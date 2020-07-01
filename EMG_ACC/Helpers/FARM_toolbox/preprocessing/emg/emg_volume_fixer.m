%
% function EEG=emg_volume_fixer(EEG,b,e)
%
% if there are no volume-markers, then insert em!
%
% b = the time (in seeconds!) of the 1st EPI
%
% e = the time of the last EPI as defined in your parameters file
% (generated at the time of converting the PARREC files to matlab.
%

function EEG=emg_volume_fixer(EEG,b,e)

load ../parameters
tr=parameters(1);
fs=EEG.srate;
nvol=parameters(3);

nvol_check=(e-b)/(tr)+1;

disp(['according to your parameters file, tr = ' num2str(tr) ', and nvol = ' num2str(nvol)]);
disp('nvol should be the correct value, and tr should be re-estimated from the raw data to get the best marker positions');
disp(['according to the timing information that you provided and nvol in the parameters file, there should be: ' num2str(nvol_check) ' volumes of EPI data in this scan.']);
disp(['according to your parameters files, there should be: ' num2str(nvol) '.']);
disp('if the difference is TOO high, like > 0.5 volumes, then you should re-check!!');
reply=input('do you wish to proceed? (y/n) ','s');

if strcmpi(reply,'y');
    
    disp('deleting your EEG events...');
    EEG.event=[];

    disp('i will assume that you placed your beginning marker at the REAL start scan, and not at the dummy scans.');
    disp('there can be 2 of 3 dummy scans.');
    
    disp('furthermore, i will assume that the last volume was not cancelled prematurely!');
    
    disp('optionally: how many trs do you wish to shift your entire marker set forwards? -- if you dont know, use 0');
    shift=input('[0-3] ','s');
    shift=str2double(shift);
    disp('how many volumes did you include? -- normally it would be 286, so enter that value here. Otherwise, use one less or more for better results.');
    nvol_usr=input(['volumes_taken: ' num2str(nvol) ' or less/more?: '],'s');

    nvol_usr=str2double(nvol_usr);
    tr_real=(e-b)/(nvol_usr-1);

    
    
    disp('inserting markers.');
    disp(['real TR = ' num2str(tr_real)]);
    
    % keyboard;
    vm=round((b+(shift+(0:nvol-1))*tr_real)*fs);
    
    for i=1:numel(vm)
        
        EEG.event(end+1).latency=vm(i);
        EEG.event(end).type='65535';
        EEG.event(end).duration=1;
        EEG.event(end).urevent=[];
        
    end
    
    disp('I inserted markers... RECHECK them using plot-> channel data.');
    
    
end
