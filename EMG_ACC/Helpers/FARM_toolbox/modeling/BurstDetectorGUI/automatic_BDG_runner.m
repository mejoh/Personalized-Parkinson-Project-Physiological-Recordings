% script to auto-run the BDG.






try
    H=Burst_Detector_Gui();
    
    % first... open a file!
    hObject=findobj(H,'tag','pushbutton_calculateMode');
    handles=guidata(H);
    Burst_Detector_Gui('Open_Callback',hObject, 0, handles);
    
    
    % fill in the right stuff.
    set(findobj(H,'tag','edit_VOmit'),'string','[-0.050 0.050]');
    set(findobj(H,'tag','edit_condOmit'),'string','[0.5 -0.1 ; 0.1 -0.5 ; 0.1 -0.5]');
    set(findobj(H,'tag','edit_doMuscles'),'string','[1 2 3 4 5 6 7 8]');
    % youve got to set it ... TWICE!
    set(findobj(H,'tag','edit_detectSelection'),'string','[1 2 3 4 5 6 7 8]');
    
    
    set(findobj(H,'tag','edit_thresh'),'string','[4 2;3.5 2;3.5 2]');
    
    set(findobj(H,'tag','edit_cutoff'),'string','[0.045 Inf Inf;0.045 Inf Inf;0.045 Inf Inf]');
    set(findobj(H,'tag','edit_upcutoff'),'string','[Inf Inf Inf;Inf Inf Inf;Inf Inf Inf]');
    
    % pause, for 2 sec.
    pause(10);
    
    % push the button 'calculate mode'.
    hObject=findobj(H,'tag','pushbutton_calculateMode');
    handles=guidata(H);
    Burst_Detector_Gui('pushbutton_calculateMode_Callback',hObject, 0, handles);
    
    % push the button 'detect bursts'.
    hObject=findobj(H,'tag','pushbutton_runDetection');
    handles=guidata(H);
    Burst_Detector_Gui('pushbutton_runDetection_Callback',hObject, 0, handles);
    
    % and finally, push the button apply cutoff'
    hObject=findobj(H,'tag','pushbutton_calculateMode');
    handles=guidata(H);
    Burst_Detector_Gui('pushbutton_applyThresh_Callback',hObject, 0, handles);
    
    close(H);
    
catch
    disp('automatic BDG step, failed...');
end

    
    