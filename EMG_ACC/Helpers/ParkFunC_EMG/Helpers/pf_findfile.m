function Files = pf_findfile(direct,name,varargin)

% pf_findfile(direct,name,varargin) searches for files or directories containing 
% the name or name patterns in the directory 'direct', and will return 
% everything that matches your name in a cell structure 'Files' (or string 
% if only 1 file was found). Every name pattern should begin and end with 
% '/'. 
% You can use the following codes in your name:
%       - '&': means logical AND. It will look for a file that contains
%       both the string patterns before and after the '&' sign.
%       - '*': is a wildcard. You can use this either at the beginning or
%       at the end of your name. The function will leave out the beginning
%       or the end in his search for the file(s).
%       - '|': when you put this before your search pattern, it will only 
%              include files that start with this pattern. In contrast, if
%              you put it at the end of your search pattern, it will only 
%              include files that end with this pattern.
%
% If you are using a script of the ParkFunC toolbox, the function is also 
% capable of dealing with loop dependent variables, such as the current 
% subject of the loop (e.g. 's01') or the current session (e.g. 'sess1'). 
% This is useful if you have multiple subjects/sessions which are encoded 
% in your file names. If specified, you will also need your conf structure 
% and loop indices. Specify these as varargin in the following way:
%       - 'conf',conf:  will add configuration structure needed for subject
%                       info.
%       - 'CurSub',i:   use the current subject string specified by index i 
%                       as a search criterion.
%       - 'CurSess',i:  use the current session string specified by index  
%                       i as a search criterion.
%       - 'CurROI',i:   Uses the current ROI string specified by index i as
%                       a search criterion
%       - 'CurHand',i   Uses the current hand (0='L'; 1='R') defined
%                       in conf.sub.hand. S
%       - 'CurHandc',i  Uses the current contralateral hand (0='R';1='L')
%                       defined in conf.sub.hand with index i
%
% Additionally you can specify the following varargin options:
%       -  'msgN':     Message if 'no files found'. 1 = yes, 2 = no. Def = 1
%       -  'msgM':     Message if 'multiple files found'. Idem as msgN
%       -  'fullfile': Returns the fullfile (instead of only filename)
%       -  'multisel': Lets you interactively select the files you want
%                      when multiple files are found
%       -  'errN':     Throws an error (instead of warning) when no files
%                      are found
%
% Example: 
% File = pf_findfile('C:\','/EMG_/&/CurSub/&/.edf/','conf',conf,'CurSub',3)
% File = 'EMG_s03.edf'
% 
% File = pf_findfile('/home/micdir/','*.edf')
% File = {'EMG_s01.edf';'EMG_s02.edf';'EMG_s03.edf'}
%
% See also pf_getSC.m

% Created by Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC

%% Defaults
%--------------------------------------------------------------------------

msgM     =   1;          % 1 = receive message if multiple files are found.      0 = receive no message
msgN     =   1;          % 1 = receive message if no files are found.            0 = receive no message
is       =   0;          % 1 = if multiple files are found, interactively select 0 = return all files 
errN     =   0;          % 1 = if no files were found throw an error             0 = only throw warning

%--------------------------------------------------------------------------

%% Deal with Varargin options
%--------------------------------------------------------------------------

for a = 1:length(varargin)
if mod(a,2)    
switch varargin{a}
case 'msgM'
    msgM    =   varargin{a+1};      % message about multiple files
case 'msgN'
    msgN    =   varargin{a+1};      % message about no files
case 'intersel'
    is      =   1;                  % interactive selection if multiple files found
case 'errN' 
    errN    =   varargin{a+1};      % message about no files
case 'conf'
    cfg     =   1;                  % If a conf file is specified
case 'fullfile' 
    ff      =   1;                  % Convert to fullfile 
case 'folders'
    fs      =   1;
end
end
end

%--------------------------------------------------------------------------

%% Get Right Search Criteria
%--------------------------------------------------------------------------

if exist('cfg','var') && ~isempty(strfind(name,'/'))
    for a = 1:length(varargin)
    if strcmp(varargin{a},'conf')
        conf    =   varargin{a+1};  
    end
    end
    name      =   pf_getSC(conf,name,varargin);
elseif strfind(name,'/')
    name      =   pf_getSC([],name);
end

%--------------------------------------------------------------------------

%% Find file(s) corresponding to your name
%--------------------------------------------------------------------------

% --- initialize parameters --- %

D      =   dir(direct);
Files  =   {D.name}';
nFiles =   length(Files);

% --- Check if Wildcard is present --- %

if isempty(strfind(name,'&')) &&  isempty(strfind(name,'*')) ~= 0     % If wildcard is not present
    WC = 0;
elseif ~isempty(strfind(name,'&'))                                    % If AND (&) is present and wildcard (*) not
    if ~isempty(strfind(name,'*'))                                    % * is not necessary when there is an &
        iStr    =   strfind(name,'*');
        name    =   [name(1:iStr-1) name(iStr+1:end)];
    end
    WC = 1;
    nWC                = length(strfind(name,'&'));      
    conf.file.names    = cell(nWC+1,1);
    T                  = strfind(name,'&');
    for j = 1:nWC+1                                   % Seperate files according to wildcards
        if j == 1
            conf.file.names{j}   =   name(1:T(j)-1);
        elseif j > 1 && j ~= nWC+1
            conf.file.names{j}   =   name(T(j-1)+1:T(j)-1);
        elseif j > 1 && j == nWC+1
            conf.file.names{j}   =   name(T(j-1)+1:end);
        end
    end
elseif ~isempty(strfind(name,'*'))
    WC  =   1;
    
    if strcmp(name(1),'*') == 1     % If the beginning is the wildcard
        conf.file.names{1}          =  name(2:end);
    elseif strcmp(name(end),'*') == 1
        conf.file.names{1}          =  name(1:end-1);
    else
        error('FindFile:Wildcard','The wildcard (*) was not placed at the beginning or the end.')
    end
    
end

% --- Find  files in directory --- %
cnt = 1;

for i = 1:nFiles
    
    CurFile     =   Files{i};
    
    if WC == 1      % If a wildcard is present
        
        nStr    =   length(conf.file.names);
        H       =   cell(1,nStr);
        
        for k = 1:nStr
            
            W   =   strfind(conf.file.names{k},'|');
            
            if ~isempty(W)      % If you used a '|' then it will only include results where the search criteria was found at the first index
                if W==1
                H{k} = strfind(CurFile,conf.file.names{k}(2:end));
                bI   = find(H{k}==1, 1);
                if isempty(bI); H{k} = []; end
                elseif W==find(conf.file.names{k}==conf.file.names{k}(end))
                    H{k} = strfind(CurFile,conf.file.names{k}(1:end-1));
                    ns   = length(conf.file.names{k}(1:end-1));
                    if ~isempty(H{k}) && strcmp(CurFile(end-ns+1:end),conf.file.names{k}(1:end-1))
                        bI   = find(H{k}==H{k}(end), 1);
                        if isempty(bI); H{k} = []; end
                    else
                        H{k}    =   [];
                    end
                end
            else
                H{k} = strfind(CurFile,conf.file.names{k});
            end
                
            if ~isempty(H{k}) 
                H{k} = H{k}(1);     % Ignores if the pattern was there more then once
            end
            
        end
        
        H   =   cell2mat(H);
        
        if ~isempty(H)  && length(H) == nStr && ~strcmp(CurFile(end),'~')
            Gotya{cnt}   =   CurFile;
            cnt          =   cnt + 1;
        end
            
    elseif WC == 0  % If no wildcard is present
        
        H = strcmp(CurFile,name);
        if H == 1
            Gotya{cnt} = CurFile;
            cnt        = cnt + 1;
        end
        
    end
end 

%--------------------------------------------------------------------------

%% Return Files
%--------------------------------------------------------------------------

if isempty(name)                % If no search criteria were entered         
    Files   =   '';
end

if ~exist('Gotya','var')    % If no files were found
    Files   = '';
    if msgN == 1 && errN ==0
        warning('Findfile:empty',['No files were found in ' direct ' for search criteria "' name '"'])
    elseif errN==1
        error('Findfile:empty',['No files were found in ' direct ' for search criteria "' name '"'])
    end
elseif exist('Gotya','var')     % If files were found
    Files   =   Gotya';
    if length(Files) > 1 && msgM == 1   % If multiple names were found
        disp(['Found ' num2str(length(Files)) ' files in ' direct ' for search criteria "' name '"'])
        if is == 1
            for a = 1:length(Files)
                disp([num2str(a) '. ' Files{a}])
            end
            in  =   input('Which one do you want to select?\n');
            Files   =   Files(in);
        end
    end
    if length(Files) == 1
        Files   =   char(Files);
    end
end

% --- Convert to Fullfile if desired --- %

if exist('ff','var') && ischar(Files)
    Files   =      fullfile(direct,Files);
elseif exist('ff','var') && iscell(Files)
    Files   =       cellfun(@(S) fullfile(direct,S),Files,'Uniform',0);
end

%--------------------------------------------------------------------------

%% Benchmark
%--------------------------------------------------------------------------

% T = toc;
% fprintf('\n%s\n',['Mission accomplished after ' num2str(T) ' seconds'])

