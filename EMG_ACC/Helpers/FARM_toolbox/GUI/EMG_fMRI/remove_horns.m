function varargout = remove_horns(varargin)
% REMOVE_HORNS M-file for Remove_horns.fig
%     
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Remove_horns

% Last Modified by GUIDE v2.5 24-Sep-2010 16:31:36
%                                                    
%=====================================================|\====
%+++++++++++++++++++++++++++++++++++++++++++++++++++++||\+++
% This script is made by: David, Nicole, Eric en Tom  ||\\  
%       modifications by: Paul                        || ||  
%+++++++++++++++++++++++++++++++++++++++++++++++++++++||+\\+
%=====================================================||==\\

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @remove_horns_OpeningFcn, ...
                   'gui_OutputFcn',  @remove_horns_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Remove_horns is made visible.
function remove_horns_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Remove_horns (see VARARGIN)

% Choose default command line output for Remove_horns
    handles.output = hObject;
    handles.protocol = varargin{1};
    
% Set titles of muscles
    handles.current_muscle = 0;
    
    if EEG.nbchan<=0                                                        
        set(handles.txt_titel,'String','NO EMG DATA AVAILABLE!');               
        %set(handles.txt_threshold,'Enable','off');
    else
        handles.current_muscle = 1;
        
        for iChannel=1:EEG.nbchan
            t = EEG.chanlocs(iChannel).labels;
            set(handles.(['radio_muscle' num2str(iChannel)]),'String',t);
        end
    end
    
% Update handles structure
    guidata(hObject, handles);
        
%Begin function
    EEG.remove_horns.threshold = 500;                                   %standard value
    set(handles.threshold_input,'String',EEG.remove_horns.threshold);
    % create a copy of the data to fiddle with
    EEG.remove_horns.data = EEG.data;                                    
    % keep a shadow array for marking samples as artefact (1 is automatic; 2 is manual)
    EEG.remove_horns.isNulled = zeros(size(EEG.remove_horns.data),'int8');
    %create averaged signal of sum of all muscles 
    EEG.remove_horns.EMG_gem_comb = create_emg_gem_comb();                
    % create the green lines (active areas according to block with safe margin)
    [EEG.remove_horns.active_blocks_indices EEG.remove_horns.nBlocks] = get_active_blocks_indices();  
    %create the red lines (active areas according to EMG)
    EEG.remove_horns.above_threshold_indices = get_nearest_above_threshold_indices();      
    
    EEG.remove_horns.artefacten_verwijderd = 0;             %boolean if artifacts are removed already or not.
    
    EEG.remove_horns.a = 4;                                 %variable of how many times the modus should be set to modus value
    
    plot_channel_average(handles);         %Beginning plot
    
     set(handles.verwijder_horns,'Visible','off');
     set(handles.btn_group_muscles,'Visible','off');
     set(handles.btn_see_muscles,'Visible','off');
     set(handles.lst_x_waarden, 'Visible', 'off');
     set(handles.btn_change,'Visible','off');
     set(handles.btn_change2,'Visible','off');
     set(handles.btn_save,'Visible','off');
     set(handles.set_x_waarden, 'Visible', 'off');
     set(handles.btnUndoHorn,'Visible','off');
     
% ===========================PLOTS=========================================
     
% --- Plot een grafiek met de gezette threshold in gemiddeld signaal
function plot_channel_average(handles)
    emg_fmri_globals;                           % make sure this is the first call in the fn
    
    plot(handles.plot1, EEG.remove_horns.EMG_gem_comb);
    axis([0 EEG.pnts/EEG.remove_horns.factor 0 5000])
    title(['Average (100*less points) sum of all rectified muscles       Protocol: ' handles.protocol]);
    xlabel('EMG samples/100 ~ sec');
    ylabel('Power in microVolt');
    hold(handles.plot1, 'on');
 
    plot(ones(1,EEG.remove_horns.npnts_gem)*EEG.remove_horns.threshold);
    gridxy(EEG.remove_horns.active_blocks_indices,'Color','g','Linestyle',':');
    gridxy(EEG.remove_horns.above_threshold_indices,'Color','r','Linestyle',':');
    % legend
    hold(handles.plot1, 'off');

% --- Plot een grafiek met de gezette threshold met signaal per spier
function plot_selected_channel_org(handles)
    emg_fmri_globals;                           % make sure this is the first call in the fn
    
    plot(handles.plot1, abs(EEG.remove_horns.data(handles.current_muscle,:)));
    axis([0 EEG.pnts 0 2000])
    title(['Active areas in ' EEG.chanlocs(handles.current_muscle).labels]); 
    xlabel('EMG samples');
    ylabel('Power in microVolt');
    hold(handles.plot1, 'on');
    gridxy(EEG.remove_horns.blokjes(handles.current_muscle,:),'Color','r','Linestyle',':');
    hold(handles.plot1, 'off');
    
    set(handles.lst_x_waarden,'string', EEG.remove_horns.blokjes(handles.current_muscle,:));
%   set(handles.lst_x_waarden,'value', 1:length(EEG.remove_horns.blokjes(handles.current_muscle,:)));
    
    % --- Plot een grafiek met de begin en eindwaarden van actieve stukjes; signaal per spier
function plot_selected_channel_mod(handles)
    emg_fmri_globals;                           % make sure this is the first call in the fn
    
    plot(handles.plot1, abs(EEG.data(handles.current_muscle,:)),'Color','r');
    axis([0 EEG.pnts 0 2000])
    title([EEG.chanlocs(handles.current_muscle).labels '           Erased movement artifacts in red       Protocol: ' handles.protocol]);
    xlabel('EMG samples');
    ylabel('Power in microVolt');
    hold(handles.plot1, 'on');
    plot(handles.plot1, abs(EEG.remove_horns.data(handles.current_muscle,:)));
    hold(handles.plot1, 'off');
   
    
% =========================FUNCTIES========================================
    
% --- Gemiddelden maken en sommeren
function EMG_gem_comb = create_emg_gem_comb()
    emg_fmri_globals; % make sure this is the first call in the fn
    factor = 100;
    EEG.remove_horns.factor=factor;
    npnts_gem = int32(round(EEG.pnts/factor));  %size matrix moet integer zijn, daarom zo expliciet opgeschreven
    EEG.remove_horns.npnts_gem=npnts_gem;
    EMG_gem = zeros(EEG.nbchan, npnts_gem);     %matrix met alle 8 spieren, 100 keer minder waarden -> beginwaarden 0
    EMG_gem_comb = zeros(1,npnts_gem);          %matrix met de som van de 8 spieren (van EMG_gem, dus 100 keer minder waarden) -> beginwaarden 0

    for k=1:EEG.nbchan
        for i=0:EEG.pnts/factor-1
            for j=1:factor
                EMG_gem(k,i+1) = EMG_gem(k,i+1)+abs(EEG.remove_horns.data(k,i*factor+j));        %Spier k, i-de element is abs som van 100 waarden in EEG.remove_horns.data
            end
            EMG_gem(k,i+1) = EMG_gem(k,i+1)/factor;    %Spier k, i-de element is nu gemiddelde van 100 waarden in EEG.remove_horns.data
        end 
        EMG_gem_comb = EMG_gem_comb + EMG_gem(k,:);    %EMG_gem_comb is som van alle spieren
    end
    
% --- Achterhaal on- en offset indices van de blokjes zoals bekend in BlockEMG, verruimd met 6 en 10 sec
function [ active_blocks_indices nBlocks ] = get_active_blocks_indices() 
    emg_fmri_globals; % make sure this is the first call in the fn
    npts_blokje = EEG.srate*29;                                         %in beide protocollen is het 29 secs per blokje
    npts_blokje_gem = round(npts_blokje/EEG.remove_horns.factor);       %in gemiddelde signaal

    nBlocks = floor(length(EEG.remove_horns.EMG_gem_comb)/npts_blokje_gem);
    active_blocks_indices = zeros(1,nBlocks+1); % add one for last block offset
    % 2010-07-19 (PG): changed the sample counts to include sampling rate settings
    n_right = 10000 * EEG.srate/1024; 
    n_left =   6000 * EEG.srate/1024; 
    for i=1:nBlocks
        if mod(i,2) == 0                                                %als even getal...
            active_blocks_indices(i) = i*npts_blokje_gem+n_right/EEG.remove_horns.factor;    %10000 waarden rechts ervan
        else                                                            %als oneven ...
            active_blocks_indices(i) = i*npts_blokje_gem-n_left/EEG.remove_horns.factor;      %6000 waarden links ervan
        end
    end
    nBlocks=nBlocks+1;
    active_blocks_indices(nBlocks) = length(EEG.remove_horns.EMG_gem_comb);  %de laatste waarde nog toevoegen    
%   EEG.remove_horns.nBlocks = nBlocks;
    
% --- eerste/laatste x-waarde met y-waarde boven threshold aanwijzen als begin en eindpunt actieve gebiedje
function I = get_nearest_above_threshold_indices()
    emg_fmri_globals; % make sure this is the first call in the fn
    I = EEG.remove_horns.active_blocks_indices;
    for iBlock=1:EEG.remove_horns.nBlocks
        if mod(iBlock,2) == 0                                           %als even getal...van rechts naar links lopen
            j=0;
            while EEG.remove_horns.EMG_gem_comb(I(iBlock)-j)<EEG.remove_horns.threshold
                j=j+1;
            end
            I(iBlock) = I(iBlock)-j;
        else                                                            %als oneven getal...van links naar rechts lopen
            j=0;
            while EEG.remove_horns.EMG_gem_comb(I(iBlock)+j)<EEG.remove_horns.threshold
                j=j+1;
            end
            I(iBlock) = I(iBlock)+j; 
        end
    end
    
    
% --- reken de max. modus van actieve en rust stukjes/blokjes/trials uit.
function modi = create_modi(handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    modi = zeros(EEG.nbchan, EEG.remove_horns.nBlocks);
    n_half = int32(3000 * EEG.srate/1024); % 2010-07-22 (PG): make interval independend of sampling rate (i.e. 3000 pt @ 1024Hz)
    for iChannel=1:EEG.nbchan                                        %per spier
        for iBlock=1:EEG.remove_horns.nBlocks       %voor alle blokjes 
            begin = int32(EEG.remove_horns.blokjes(iChannel,iBlock))+n_half;
            eind = int32(EEG.remove_horns.blokjes(iChannel,iBlock+1))-n_half;

            ac=abs(EEG.remove_horns.data(iChannel,begin:eind));     %ac zijn waarden van activiteitsgebiedje gerectificeerd   

            A = zeros(1,length(ac));                       %lege array met goede lengte
            H = imag(hilbert(ac));                         %imaginaire gedeelte van hilbert transformatie van actieve gebiedje

            % 2010-09-14 (PG) hmmm, this could be a lot more optimal in matlab lingo...
%             for k=1:length(ac)                             %voor alle waarden van het actieve gebiedje
%                 A(k) = sqrt(ac(k)^2 + H(k)^2);             %pythagoras van reëel en imaginaire gedeelte van hilbert is momentane aplitudes
%             end
            A = sqrt(ac.^2 + H.^2);

            histogram = hist(A,100);                       %momentane amplitudes in 100 bins verdeeld in histogram
            maximum = max(A);
            bin_grootte = maximum/100;

            modus = find(max(histogram) == histogram);     %modus is de x waarde waar het max van histogram zit (vaakst voorkomende momentane amplitude)

            modi(iChannel,iBlock) = modus(1)*bin_grootte;   %in geval van meerdere maxima, neemt hij eerste en slaat op in array
        end
    end
        
    
    
% --- Outputs from this function are returned to the command line.
function varargout = remove_horns_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % Get default command line output from handles structure
    varargout{1} = handles.output;    
 

%========================BUTTONS===========================================

 % --- Executes on button press in btn_set_threshold
 function btn_set_threshold_Callback(hObject, eventdata, handles)                         
    emg_fmri_globals; % make sure this is the first call in the fn

    EEG.remove_horns.threshold = str2double(get(handles.threshold_input,'String'));
    EEG.remove_horns.above_threshold_indices = get_nearest_above_threshold_indices();
    plot_channel_average(handles);
    set(handles.set_x_waarden, 'Visible', 'on');


% --- Executes on button press in btn_see_muscles.
function btn_see_muscles_Callback(hObject, eventdata, handles)                       
    emg_fmri_globals; % make sure this is the first call in the fn

    EEG.remove_horns.above_threshold_indices = EEG.remove_horns.above_threshold_indices*EEG.remove_horns.factor;
    EEG.remove_horns.blokjes = ones(EEG.nbchan,EEG.remove_horns.nBlocks+1);
    for i=1:EEG.nbchan
        EEG.remove_horns.blokjes(i,2:end) = EEG.remove_horns.above_threshold_indices;    %kollom 1 zijn alleen enen
    end

    handles.current_muscle = 1;
    plot_selected_channel_org(handles);
    set(handles.set_x_waarden,'Visible','off');
    set(handles.btn_set_threshold,'Visible','off');
    set(handles.btn_group_muscles, 'Visible', 'on');
    set(handles.btn_change2, 'Visible', 'on');
    set(handles.btn_change, 'Visible', 'off');
    set(handles.verwijder_horns, 'Visible', 'on');
    set(handles.threshold_input, 'Visible', 'off');
    set(handles.text3, 'Visible', 'off');
    set(handles.text6, 'Visible', 'off');
    set(handles.btn_see_muscles,'Visible','off');
  

% --- Executes when selected object is changed in button_group_muscles.
function btn_group_muscles_SelectionChangeFcn(hObject, eventdata, handles)
    emg_fmri_globals; 
    str = get(eventdata.NewValue,'Tag'); % Get Tag of selected object.
    handles.current_muscle  = str2double(str(end)); % last character should be muscle #
    % Update handles structure
    guidata(hObject, handles);
    
    if EEG.remove_horns.artefacten_verwijderd == 0
        plot_selected_channel_org(handles);
    else
        plot_selected_channel_mod(handles);
    end
    
% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
    close;

% --- Textbox met een waarde voor de threshold
function threshold_input_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of threshold_input as text
    %        str2double(get(hObject,'String')) returns contents of threshold_input as a double


% --- Executes during object creation, after setting all properties.
function threshold_input_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection btn_change in lst_x_waarden.
function lst_x_waarden_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns lst_x_waarden contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from lst_x_waarden


% --- Executes during object creation, after setting all properties.
function lst_x_waarden_CreateFcn(hObject, eventdata, handles)
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in verwijder_horns.
function verwijder_horns_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    %PLEASE WAIT WHILE CALCULATING nog inbouwen
    EEG.remove_horns.modi = create_modi(handles);
    n_half = int32(3000 * EEG.srate/1024); % 2010-07-22 (PG): make interval independend of sampling rate (i.e. 3000 pt @ 1024Hz)
   
    modusFactor = EEG.remove_horns.a; %variable of how many times the modus should be set to modus value
    
    % update EEG.remove_horns.isNulled matrix so it will have '1's for samples marked as artefact.
    for iChannel=1:EEG.nbchan                           %per spier
        for iBlock=1:EEG.remove_horns.nBlocks           %voor alle blokjes 
            begin = int32(EEG.remove_horns.blokjes(iChannel,iBlock));              % iBlock = nummer van actief blokje (max = 24 of 16)
            eind = int32(EEG.remove_horns.blokjes(iChannel,iBlock+1));
            if mod(iBlock,2) == 0                        %als actief stukje, dus niet rust
                for m=begin-n_half:begin+n_half          %for alle waarden rond begin van actief blokje
                    if abs(EEG.remove_horns.data(iChannel,m)) > modusFactor*EEG.remove_horns.modi(iChannel,iBlock)        %als groter dan a*modus
%                       EEG.remove_horns.data(iChannel,m) = EEG.remove_horns.modi(iChannel,iBlock);             %dan krijgt het waarde van modus
                        EEG.remove_horns.data(iChannel,m) = 0;
                        EEG.remove_horns.isNulled(iChannel,m) = 1;
                    end
                end
                if iBlock<EEG.remove_horns.nBlocks  %als niet laatste blokje, dan...
                    for n=eind-n_half:eind+n_half                                               %for alle waarden rond eind huidige blokje
                        if abs(EEG.remove_horns.data(iChannel,n)) > modusFactor*EEG.remove_horns.modi(iChannel,iBlock)    %als groter dan a*modus       
%                           EEG.remove_horns.data(iChannel,n)=EEG.remove_horns.modi(iChannel,iBlock);           %dan krijgt het waarde van modus
                            EEG.remove_horns.data(iChannel,n) = 0;
                            EEG.remove_horns.isNulled(iChannel,n) = 1;
                        end
                    end
                else                                   %als laatste blokje, dan...
                    laatste_stukje = EEG.pnts-eind;                                          %veiligheid, zodat we niet meer dan EEG.pnts bereiken
                    for n=eind-n_half:eind+laatste_stukje
                        if abs(EEG.remove_horns.data(iChannel,n)) > modusFactor*EEG.remove_horns.modi(iChannel,iBlock)
%                           EEG.remove_horns.data(iChannel,n)=EEG.remove_horns.modi(iChannel,iBlock);
                            EEG.remove_horns.data(iChannel,n) = 0;
                            EEG.remove_horns.isNulled(iChannel,n) = 1;
                        end
                    end
                end
%             else                            %voor alle rust stukjes
%                 for m=begin:begin+n_half                                                      %for alle waarden rond begin van actief blokje
%                     if abs(EEG.remove_horns.data(iChannel,m)) > modusFactor*EEG.remove_horns.modi(iChannel,iBlock)        %als groter dan 6*modus      
%                         EEG.remove_horns.data(iChannel,m) = EEG.remove_horns.modi(iChannel,iBlock);             %dan krijgt het waarde van modus
%                     end
%                 end
%                 for n=eind-n_half:eind
%                     if abs(EEG.remove_horns.data(iChannel,n)) > modusFactor*EEG.remove_horns.modi(iChannel,iBlock)
%                         EEG.remove_horns.data(iChannel,n)=EEG.remove_horns.modi(iChannel,iBlock);
%                     end
%                 end
            end
        end
    end
    % remove junk between horns
    remove_short_segments_between_horns();

    % prepare GUI for individual channel processing
    handles.current_muscle = 1;
    EEG.remove_horns.artefacten_verwijderd = 1;
    guidata(hObject, handles);
    plot_selected_channel_mod(handles);
    EEG.remove_horns.extra_peaks = [];
    % show/hide some controls
    set(handles.radio_muscle1,'Value',1.0);
    set(handles.verwijder_horns,'Visible','off');
    set(handles.lst_x_waarden, 'Visible', 'off');
    set(handles.btn_change2, 'Visible', 'off');
    set(handles.btn_save, 'Visible', 'on');
%     set(handles.lst_extra_values, 'Visible', 'on');
    set(handles.btn_add_peak, 'Visible', 'on');
%   set(handles.btn_delete, 'Visible', 'on');
    set(handles.btnUndoHorn,'Visible','on', 'Enable', 'on');
    

function remove_short_segments_between_horns(channel, nulling_code)
    % 2010-09-14 (PG): modus thresholding results in very short fragments to be zeroed out. To solve this
    %                  we simple zero-out pieces of data which fall between nearby artefacts.
    
    emg_fmri_globals; % make sure this is the first call in the fn
    
    if nargin<1 || isempty(channel)
        channel = 1:EEG.nbchan;
    end
    if nargin<2 || isempty(nulling_code)
        nulling_code = 3; % 3 == automatically removed samples between two artefacts
    end
    
    for iChannel=channel                           %per spier
        n_1000ms = int32(1000 * EEG.srate/1024); % remove pieces smaller than about 1000ms
        I = find(EEG.remove_horns.isNulled(iChannel,:)>0); % get indices of zeroed samples
        D = I(2:end) - I(1:end-1); % get index differences of zeroed samples
        R = find(D>1 & D<n_1000ms); % when diff >1 and smaller than 100ms, then we should also remove the points inbetween
        for k=1:length(R)
            r = R(k); % this is a valid index for I and D
            b = I(r)+1; % first point to clear
            e = I(r+1)-1; % last point to clear
            EEG.remove_horns.data(iChannel,b:e) = 0;
            EEG.remove_horns.isNulled(iChannel,b:e) = nulling_code; 
        end
    end
    
% --- Executes on button press in set_x_waarden.
function set_x_waarden_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn    
    set(handles.lst_x_waarden,'String', EEG.remove_horns.above_threshold_indices);
%   set(handles.lst_x_waarden,'value',1:length(EEG.remove_horns.above_threshold_indices));
    set(handles.lst_x_waarden, 'Visible', 'on');
    set(handles.btn_change,'Visible','on');
    set(handles.btn_see_muscles,'Visible','on');
    set(handles.set_x_waarden,'Visible','off');

% --- Executes on button press in btn_change.
function btn_change_Callback(hObject, eventdata, handles)
    emg_fmri_globals;
    
    ongewenste_x_waarde = get(handles.lst_x_waarden,'value');
    [u,v]=getpts;
    EEG.remove_horns.above_threshold_indices(ongewenste_x_waarde) = round(u(1)); 
    EEG.remove_horns.above_threshold_indices = sort(EEG.remove_horns.above_threshold_indices);
    set(handles.lst_x_waarden,'string', EEG.remove_horns.above_threshold_indices);
%   set(handles.lst_x_waarden,'value', 1:length(EEG.remove_horns.above_threshold_indices));
   
    plot_channel_average(handles);


% --- Executes on button press in btn_change2.
function btn_change2_Callback(hObject, eventdata, handles)
    emg_fmri_globals;
    
    ongewenste_x_waarde = get(handles.lst_x_waarden,'value');
    [u,v]=getpts;
    EEG.remove_horns.blokjes(handles.current_muscle,ongewenste_x_waarde) = round(u(1)); 
    
    %set(handles.lst_x_waarden,'string', EEG.remove_horns.blokjes(handles.current_muscle,:));
    %set(handles.lst_x_waarden,'value', 1:length(EEG.remove_horns.blokjes(handles.current_muscle,:)));
    EEG.remove_horns.blokjes = sort(EEG.remove_horns.blokjes,2);
    plot_selected_channel_org(handles);


% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
    emg_fmri_globals;

    % copy back the modified version
    EEG.data = EEG.remove_horns.data;
    clear EEG.remove_horns.data;

    ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
    
    % first save corrected EMG
    emgdir = fullfile(ppdir,handles.protocol,'emg');        
    filepath = fullfile(emgdir,'emg_corrected2.mat');
    [filename pathname ] = uiputfile('*.mat','Save corrected data as',filepath);
    if filename~=0
        filepath = fullfile(pathname, filename);
        message = ['saving ' filepath];
        disp(message);
        save(filepath, 'EEG')
    end
    
    % then save scan nulling regressor
    nulling_regressors = calculate_nulling();
    regdir = fullfile(ppdir,handles.protocol,'regressor');
    filepath = fullfile(regdir,'nulling_horns_%d_%s.txt');
    [filename pathname ] = uiputfile('*.txt','Save scan nulling regressors as',filepath);
    if filename~=0
        for iChan=1:length(nulling_regressors)
            f = fullfile(pathname, sprintf(filename,iChan,EEG.chanlocs(iChan).labels));
            disp(['saving ' f]);
            N = nulling_regressors(iChan);
            dlmwrite(f,N,' ');
        end
        % also create a SPM design-like file (parts of this nulling design should be included in the overall design later)
        D = calculate_nulling_design;
        save(fullfile(pathname,'nulling_design.mat'),'D');
    end
    
    close;   

   
% --- Return a cell array which contains (for each channel) a scan nulling matrix 
%     The matrices are indexed by (volume,channel) and of type 'int8'
function scan_nulling = calculate_nulling
    emg_fmri_globals;
    
    % prepare output array
    scan_nulling = cell(1,EEG.nbchan);
    
    % first collect volume based nulling info
    [ onsetSamples nSamplesPerEpoch ] = get_volume_onset_indices(EEG);
    nEpochs = length(onsetSamples);
    for iChan=1:EEG.nbchan
        T=zeros(1,nEpochs,'int8');
        for i=1:nEpochs
            b = onsetSamples(i);
            e = b + nSamplesPerEpoch - 1;
            % set nulling flag a.s.a. at least one sample was marked as artefact
            T(i) = sum(EEG.remove_horns.isNulled(iChan,b:e))>0;
        end    
        
        % making the null-matrix: a single regressor for each marked volume
        tmp=find(T);
        regressor=zeros(numel(T),sum(T),'int8');
        for i=1:numel(tmp);
            regressor(tmp(i),i)=1;
        end    
        scan_nulling{iChan} = regressor;
    end
    
% --- Return a cell array which contains (for each channel) a scan nulling design (onsets and durations)
%     The matrices are indexed by (volume,channel) and of type 'int8'
function design = calculate_nulling_design
    emg_fmri_globals;
    
    % prepare output array
    design = cell(1,EEG.nbchan);
    
    % first collect volume based nulling info
%    [ onsetSamples nSamplesPerEpoch ] = get_volume_onset_indices(EEG);
%    nEpochs = length(onsetSamples);
    for iChan=1:EEG.nbchan
        N = EEG.remove_horns.isNulled(iChan,:) ~= 0;
        N0 = [N 0];
        N1 = [0 N];
        D = N0 - N1; % this vector will now contain a 1 for each onset, and -1 for each offset
        onsets = double(find(D>0)) ./ EEG.srate;
        offsets = double(find(D<0)) ./ EEG.srate;
        durations = offsets - onsets; % TODO: strip very short fragments (probably earlier in the process)
        nOnsets = length(onsets);
        names = cell(1,nOnsets);
        for iName=1:nOnsets
            names{iName} = sprintf('N-%d-%d',iChan,iName);
        end
        design{iChan} = struct('names',{names},'onsets',{num2cell(onsets)},'durations',{num2cell(durations)});
    end
    

% --- Executes on button press in btn_add_peak.
function btn_add_peak_Callback(hObject, eventdata, handles)
    emg_fmri_globals;
    
    k = handles.current_muscle;
    
    [u,v]=getpts;
    nieuwe_pieken = round(u);
    
    n_half = int32(1000 * EEG.srate/1024); % 2010-07-22 (PG): make interval independend of sampling rate (i.e. 1000 pt @ 1024Hz)
    modusFactor = EEG.remove_horns.a; %variable of how many times the modus should be set to modus value
    
    nulling_code = 2; % == manual
    for i = 1:length(nieuwe_pieken)
        % zoek eerst uit in welk 'modus' blokje dit punt valt
        tijdelijk = sort([EEG.remove_horns.blokjes(k,:) nieuwe_pieken(i)]);
        modus_index = find(tijdelijk == nieuwe_pieken(i))-1;
        if modus_index > size(EEG.remove_horns.modi,2)
            modus_index = size(EEG.remove_horns.modi,2);
        end
        modus = EEG.remove_horns.modi(k,modus_index);
        for j = nieuwe_pieken(i)-n_half:nieuwe_pieken(i)+n_half
            if abs(EEG.remove_horns.data(k,j)) > modusFactor*modus
%              EEG.remove_horns.data(k,j)=modus;            
               EEG.remove_horns.data(k,j)=0;
               EEG.remove_horns.isNulled(k,j) = nulling_code; % 2==manual
            end
        end
    end
    % remove junk between horns
    remove_short_segments_between_horns(k,nulling_code); % 2==manual
    
    EEG.remove_horns.extra_peaks = sort([EEG.remove_horns.extra_peaks nieuwe_pieken']);
        
%   set(handles.lst_extra_values,'string', EEG.remove_horns.extra_peaks);
%   set(handles.lst_extra_values,'value', 1:length(EEG.remove_horns.extra_peaks));
%   set(handles.btn_delete, 'Enable', 'on');
   
    plot_selected_channel_mod(handles);


% --- the following delete 'extra peak' function is obsolete bacause the extra-list is useless and has no additional functionality...
% % % --- Executes on button press in btn_delete.
% % function btn_delete_Callback(hObject, eventdata, handles)
% %     emg_fmri_globals;
% %     
% %     iMuscle = handles.current_muscle;
% %     
% %     selected_peaks = get(handles.lst_extra_values,'Value');
% %     peak_indices =  EEG.remove_horns.extra_peaks; % get(handles.lst_extra_values,'String');
% %    
% %     n_half = int32(1000 * EEG.srate/1024); % 2010-07-22 (PG): make interval independend of sampling rate (i.e. 1000 pt @ 1024Hz)
% %     
% %     nulling_code = 2; % == manual
% %     for i = length(selected_peaks):-1:1
% %         list_index = selected_peaks(i);
% %         index = peak_indices(list_index);
% %         npnts = size(EEG.remove_horns.data,2);
% %         b = index-n_half; if b<1; b=1; end;
% %         e = index+n_half; if e>npnts; e=EEG.npnt; end;
% %         for j = b:e
% %             if EEG.remove_horns.isNulled(iMuscle,j)==nulling_code
% %                EEG.remove_horns.data(iMuscle,j)=EEG.data(iMuscle,j);
% %                EEG.remove_horns.isNulled(iMuscle,j) = 0;
% %             end
% %         end
% %         peak_indices(list_index) = [];
% %     end
% %     
% %     EEG.remove_horns.extra_peaks = peak_indices;
% %     set(handles.lst_extra_values,'Value', []);
% %     set(handles.lst_extra_values,'String', EEG.remove_horns.extra_peaks);
% %     if isempty(peak_indices)
% %         set(handles.btn_delete, 'Enable', 'off');
% %     end
% %     % Update handles structure
% %     guidata(hObject, handles);
% %     plot_selected_channel_mod(handles);


% --- Executes on button press in btnUndoHorn.
function btnUndoHorn_Callback(hObject, eventdata, handles)
    % 2010-09-24 (PG): added function to undo 'remove horns'
    emg_fmri_globals;
    
    iMuscle = handles.current_muscle;
    
    [u,v]=getpts;
    undo_at = round(u);
    
    nulling_code = 2; % == manual
    for i = 1:length(undo_at)
        % first go to start of this horn
        j = undo_at(i);
        while j>1
            if EEG.remove_horns.isNulled(iMuscle,j-1)
                j = j-1;
            else
                break;
            end
        end
        % then undo removal until end of this horn
        while j<size(EEG.remove_horns.isNulled,2)
            if EEG.remove_horns.isNulled(iMuscle,j)
                EEG.remove_horns.data(iMuscle,j)=EEG.data(iMuscle,j);
                EEG.remove_horns.isNulled(iMuscle,j) = 0;
                j = j+1;
            else
                break;
            end
        end
    end
        
    plot_selected_channel_mod(handles);
    
