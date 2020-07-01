% script to auto-run the BDG.






try
    H=Burst_Detector_Gui();
    
    % first... open a file!
    hObject=findobj(H,'tag','pushbutton_calculateMode');
    handles=guidata(H);
    Burst_Detector_Gui('Open_Callback',hObject, 0, handles);
    
    
    % fill in the right stuff.
    set(findobj(H,'tag','edit_musclesExportQuery'),'string',num2str(do_muscles));
    set(findobj(H,'tag','edit_resultsDir'),'string',analysisName);
    
    % or... maybe change/select even more options!
    
    
    % pause, for 2 sec.
    pause(10);
    
    % select the Export_Lump option, by calling the appropriate callback
    % function.
    hObject=findobj(H,'tag','pushbutton_calculateMode');
    handles=guidata(H);
    Burst_Detector_Gui('ExportModelLump_Callback',hObject, 0, handles);
    
    
    
    close(H);
    
catch
    disp('automatic BDG step, failed...');
end

