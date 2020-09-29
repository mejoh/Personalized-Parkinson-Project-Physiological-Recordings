function strc = pf_selstruct(struc,varargin)
% strc= pf_selstruct(struc,varargin) returns a structure containing fields
% which have been selected from struc with input from varargin. For every
% subfield you want to select specify another varargin in ascending order.
% Every varargin must be a cell contain one or strings indicating the
% nested fields you want to select
%
% Example: struc =        
%    p28: [1x1 struct]
%    p29: [1x1 struct]
%    p30: [1x1 struct]
%         struc.p28 = 
%    OFF: [1x1 struct]
%    ON:  [1x1 struct]
%
%    p28.('OFF').data = 
%         [mxn double]   
%
%    strc = pf_selstruct(struc,{'p28' 'p29'},{'OFF'},{data})
%    strc = {cell 2x1}; % Where every cell contains a selected field 

% Michiel Dirkx, 2015
% $ParkFunC, 20150616

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

if nargin<1
    load('freqana_p28-30_mtmconvol_han10s_orig_postavg.mat')
    struc = data_freq;
end

if nargin<2
    varargin{1} = {'p28';'p30'};
    varargin{2} = {'OFF'};
    varargin{3} = {'Rest1'};
    varargin{4} = {'powspctrm'};
end

%--------------------------------------------------------------------------

%% Select
%--------------------------------------------------------------------------

nLevels = size(varargin,2);

for a = 1:nLevels
   
    CurLevels =  varargin{a};
    CurFields =  fieldnames(struc); 
    
    iFields   =  pf_strcmp(CurFields,CurLevels);
    remove    =  CurFields(~iFields);
    keyboard
    
    % --- remove selected fields --- %
    
    strc = rmfield(struc,remove);
   
end





    
    


    


