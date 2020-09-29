function vec = pf_cellselect(C,row,column,varargin)
%
% - UNDER CONSTRUCTION - Now only works for selecting single elements.
% 
% returns a vector containing all the elements i of a cell containing
% multiple matrices.
%

% © Michiel Dirkx, 2014
% $ParkFunC
%
%--------------------------------------------------------------------------

%% Bug Report
%--------------------------------------------------------------------------

if length(row) > 1 || length(column) > 1
    warning('cellsel:index','You specified more than one elements of your row/column. This will probably not work as it has not been implemented yet.')
end

%--------------------------------------------------------------------------

%% Deal with varargin options
%--------------------------------------------------------------------------

for a = 1:length(varargin)
switch varargin{a}
case 'rowas'
    rowas   =   1;
case 'colas'
    colas   =   1;
end
end

%--------------------------------------------------------------------------

%% Initiate Loop Parameters
%--------------------------------------------------------------------------

nM  =   length(C);      
vec =   nan;
cnt =   1;

% -------------------------------------------------------------------------

%% Retrieve Vector
% -------------------------------------------------------------------------

% --- If row and column are specified as indices --- %

if ~exist('rowas','var') && ~exist('colas','var') 

    for a = 1:nM
        
        el                 =   C{a}(row,column);
        nEl                =   length(el);
        
        vec(cnt:cnt+nEl-1) =   C{a}(row,column);
        cnt                =   cnt + nEl;
        
    end

% --- If only row is specified as ascending index --- %    
    
elseif exist('rowas','var')
    
    for a = 1:nM
        
        % --- Get right Row/Column index --- %
        
        m                  =   C{a};
        nR                 =   size(m,1);
        if ~isinteger(int8(row/nR+1))
            R              =   floor(row/nR+1);
            
        else
            R              =   row/nR;
        end
        C                  =   row - ((R-1)*nR);
        
        % --- Same as above --- %
        
        el                 =   C{a}(R,C);
        nEl                =   length(el);
        
        vec(cnt:cnt+nEl-1) =   C{a}(R,C);
        cnt                =   cnt + nEl;
        
    end
    
% --- If only row is specified as ascending index --- %
    
elseif exist('colas','var')
    warning('cellsel:colas','Not implemented yet, use rowas or programme it yourself...')
    keyboard
end
    
    
    

%% -------------------------------------------------------------------------
