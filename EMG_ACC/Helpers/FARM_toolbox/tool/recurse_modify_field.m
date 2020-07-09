function out = recurse_modify_field(in,pattern,replace)
%function out = recurse_modify_field(in,pattern,replace)
%
% Recursively search structure, for pattern, and replace
%
% update 20/8
% 1) instead of text replace you now provide regular expressions for
% regexprep.
%
% 2) now it also works on structs like these:
% a.b(1).fname='bla'
% a.b(2).fname='bla2'
%
% 3) and the replacement now also works on text-matrices
%
% 4) werkt nu op meerdere elementen.


if ~ischar(pattern)&&~ischar(replace)
   error('Currently only string patterns supported; see regexprep') 
end

% wat je er in stopt kan alleen maar: 
% a) een struct
% b) een cell
% c) een nummer
% d) een string
% e) iets heel anders
% zijn.

% ga eerst kijken of er iets inzit: isempty(in)||isnumeric(in)
% dan of het een string is: ischar(in)

% en dan pas of er > 1 elementen inzitten. De komende aanroepen 'managen'
% wat er kan gebeuren... een struct of een cell, met 1 of meerdere
% elementen.




if isempty(in)||isnumeric(in) % don't do anything if it's empty or a number.
    out=in;
    
    
elseif ischar(in)
    for i=1:size(in,1)
        out(i,:)=regexprep(in(i,:),pattern,replace,'ignorecase');
        % disp(regexp(in(i,:),pattern,'match'));
        % disp(regexp(out(i,:),pattern,'match'));
    end
    
elseif numel(in)>1
    
    for i=1:numel(in)
        out(i) = recurse_modify_field(in(i),pattern,replace);
        % disp('doing it');
    end
    out=reshape(out,size(in));  % de 'missing' trick!
    
    
elseif isstruct(in)
    fields = fieldnames(in);
    for i = 1:numel(fields)
        field=fields{i};
        out.(field) = recurse_modify_field(in.(field),pattern,replace);
    end
    
elseif iscell(in)

    out{1} = recurse_modify_field(in{1},pattern,replace); 
        
else
    
    out=in; % voor nog andere objects (NIFTI-1 objects)
end

    
   



if ~exist('out')
   keyboard 
end

