function subidx = pf_subidx(selidx,subname)
% pf_subidx(selidx) converts the numbers in selidx to the subject strings
% (i.e. 2 5 3 will convert to p02, p05 and p03 or c02, c05 and c03) and will 
% then find these subject strings in subname and subsequently return the 
% indexes. Useful if you want to make a selection of subjects but not go 
% searching for their indices in conf.sub.name.

% Michiel Dirkx, 2015
% $ParkFunC, version 201501206

%% Initialize
%--------------------------------------------------------------------------

if strcmp(subname{1}(1),'p')
    subcode = 'p';
elseif strcmp(subname{1}(1),'c')
    subcode = 'c';
end

% --- Convert selidx to substring --- %

substr = cell(length(selidx),1);

for a = 1:length(selidx)
    substr{a} = [subcode num2str(selidx(a),'%02d')];
end

% --- Find the substring in subname --- %

cnt = 1;

for a = 1:length(substr)
   curidx = find(strcmp(subname,substr{a}));
   
   if isempty(curidx)
       disp(['Could not find ' substr{a}])
   else
       subidx(cnt) = curidx;
       cnt         = cnt+1;
   end
   
end













