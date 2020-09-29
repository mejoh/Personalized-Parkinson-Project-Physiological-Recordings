% dit dient om de EMG traces te filteren en klaar te maken voor
% model-toevoeging.

% clear all;
function EEGOUT=emg_remove_sliceartifact(EEG)
    load ../parameters

    lpf=[];
    if EEG.srate==1024
        L=20;
    elseif EEG.srate==2048
        L=10;
    end


    % L=10;
    Win=10;
    etype='s';
    strig=1;
    anc_chk=0;
    trig_correct=0;
    Volumes=[];
    Slices=[];
    pre_frac=0.07; 
    exc_chan=[];
    NPC='auto';

    EEGOUT=pop_fmrib_fastr(EEG,lpf,L,Win,etype,strig,anc_chk,trig_correct,Volumes,Slices,pre_frac,exc_chan,NPC);

    
    %% doe de truuk; fmrib.
    % 
    %   Inputs: (see details below and fmrib_fastr.m)
    %         EEG - EEG structure.
    %         lpf - Low pass filter cutoff (default: [ ]=70).
    %         L - Interpolation folds (default: [ ]=10).
    %         Win - Number of artifacts in avg. window (default: [ ]=30).
    %         etype - Name of FMRI slice (slice timing) event.  Unlike
    %             fmrib_fastr.m, this is the name of the event.  fmrib_fastr.m 
    %             takes a vector with slice locations.
    %         strig:          1 for slice triggers (default)
    %                         0 for volume/section triggers
    %         anc_chk         1 to perform ANC
    %                         0 No ANC
    %         trig_correct:   1 to correct for missing triggers;
    %                         0 to NOT correct.
    %                         (default: [ ]=0)
    %         Volumes:        FMRI Volumes.  Needed if trig_correct=1; 
    %                         otherwise use [ ];
    %         Slices:         FMRI Slices/Vol. usage like Volumes.
    %         pre_frac:       Relative location of slice triggers to actual start
    %                         of slice (slice artifact).  Value between 0 - 1.
    %                         0 = slice trigger (event) points to absolute start
    %                         of slice (artifact); 1 = points to absolute end.
    %                         (default: [ ]=0.03).
    %         exc_chan:       Channels to exclude from residual artifact
    %                         principle component fitting (OBS).  Use for EMG, 
    %                         EOG or other non-eeg channels.
    %         NPC:            Number of principal components to fit to residuals.
    %                         0 to skip OBS fitting and subtraction.
    %                         'auto' for automatic order selection
    %                         (default)