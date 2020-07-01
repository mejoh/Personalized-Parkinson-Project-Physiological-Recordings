function [dat,Hdr] = pf_pmg_cutedf(rootdir,fname,varargin)
%
% pf_pmg_cutedf will read EDF(+) files and cut them in NxFs EDF files, so
% your EDF files will only contain data of the same sampling frequency.
% This  might be useful for analyses, for instance when you're using
% FieldTrip.
%
% see also read_edf.m, save_edf.m

% ©Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Defaults
%--------------------------------------------------------------------------

fprintf('\n%s\n','% -------------- Cutting EDF+ Files -------------- %')

%--------------------------------------------------------------------------

%% Deal with varargin
%--------------------------------------------------------------------------

subdir     =   '';     % Default subdirectory
subsubdir  =   '';     % Default subsubdirectory
save       =   'no';   % Default save option

for a = 1:length(varargin)
if mod(a,2) == 1
switch varargin{a}
case 'sbdir'
    subdir     =   varargin{a+1};      % subdir if applicable
case 'sbsbdir'
    subsubdir  =   varargin{a+1};      % Subsub dir if applicable
case 'save'                         
    save = 1;                       % save files
end
end
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin < 1

clear all; close all; clc

% --- Directories --- %

rootdir   =   '/home/action/micdir/data/PMG';                                 % Root directory
subdir    =   {'p01';'p02';'p03';'p04';'p05';'p06';'p07';'p08';'p09';'p10';   % Sub directory ('' if NA)
			   'p11';'p12';'p13';'p14';'p15';'p16';'p17';'p18';'p19';'p20';
               'p21';'p22';'p23';'p24';'p25';'p26';'p27';'p28';'p29';'p30';
			   'p31';'p32';'p33';'p34';'p35';'p36';'p37';'p38';'p39';'p40';
			   'p41';};
subsubdir =   {'OFF';'ON'};                                                  % SubSub directory ('' if NA)

sel	      =   25:37;
subdir    =   subdir(sel);

% --- File info --- %

fname     =  '/PMG/&/CurMont/&/.edf/';   % File name (uses pf_findfile)
save      =  'yes';                      % Save files ('yes' or 'no'; sub directory (CutFs will be made))

end

%--------------------------------------------------------------------------

%% Initiate Parameters
%--------------------------------------------------------------------------

nSub    =   length(subdir);
nSubsub =   length(subsubdir);
cnt     =   1;

%--------------------------------------------------------------------------

%% Collect all files
%--------------------------------------------------------------------------

fprintf('1) Collecting all files \n')

for a = 1:nSub
    CurSub = pf_findfile(rootdir,subdir{a},'msgN',0,'fullfile');
    for b = 1:nSubsub
        CurSess		= subsubdir{b};
        CurDir		= pf_findfile(CurSub,CurSess,'fullfile','msgN',0);
        CurFile		= pf_findfile(CurDir,fname,'intersel');
        Files{cnt}	= fullfile(CurDir,CurFile);
        cnt			= cnt + 1;
        fprintf(' - Added: %s\n',CurFile)
    end
end

nFiles	=	length(Files);

%--------------------------------------------------------------------------

%% Cutting all files
%--------------------------------------------------------------------------

fprintf('\n 2) Cutting all files \n')

for a = 1:nFiles
    
    % --- Read File --- %
    
    clear data hdr
    
    CurFile    = Files{a};
    [path,name]= fileparts(CurFile);
    fprintf(' - Working on %s\n',name)
    
    [data,hdr] = read_edf(CurFile);
    
    fn         = fieldnames(hdr);
    nfn        = length(fn);
    
    % --- Detect Fs in file --- %
    
    uFs = unique(hdr.samplerate);
    nFs	= length(uFs);
    
    dat = cell(nFs,1);
    Hdr = cell(nFs,1);
    
    for b = 1:nFs
        
        % --- index Current SampleRate --- %
        
        CurFs	=	uFs(b);
        iFs     =   find(hdr.samplerate==CurFs);
        
        % --- Built new header structure --- %
        
        for c = 1:nfn
            CurFn = fn{c};
            if ( length(hdr.(CurFn)) == hdr.channels && ~ischar(hdr.(CurFn)) )
                Hdr{b}.(CurFn) = hdr.(CurFn)(iFs);
            elseif strcmp(CurFn,'channels')
                Hdr{b}.(CurFn) = length(iFs);
            else
                Hdr{b}.(CurFn) = hdr.(CurFn);
            end
        end
        
        % --- Built new data  structure --- %
        
        dat{b}    =     data(iFs);
        
        % === Save cutted EDF+ (Hdr+dat) === %
        
        fprintf(' -- Cut into: %s\n',[name '_Fs=' num2str(CurFs) '.edf'])
        
        if save == 1
            savedir = fullfile(path,'CutFs');
            if ~exist(savedir,'dir'); mkdir(savedir); end
            cd(savedir)
            copyfile(CurFile,savedir);
            save_edf([name '_Fs=' num2str(CurFs) '.edf'],dat{b},Hdr{b})
        end
        
    end
end

%==========================================================================

