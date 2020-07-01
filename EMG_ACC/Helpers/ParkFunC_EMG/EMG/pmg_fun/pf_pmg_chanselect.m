function idx = pf_pmg_chanselect(allchan,desirechan)
%
% Return the indices of the desired channels (desirechan) in all channels
% (allchan). Useful for selecting only the channels you want.
%

% ©Michiel Dirkx, 2014
% $ParkFunC

%% Select channels

nDC =   length(desirechan);
cnt =   1;

for a = 1:nDC
	
	sc     =	strfind(allchan,desirechan{a});
	sc     =	~cellfun(@isempty,sc);
    fnd    =    find(sc==1);
    
    if ~isempty(fnd) && length(fnd)==1
        idx(cnt) = fnd;
        cnt      = cnt+1;
    elseif ~isempty(fnd) && length(fnd)>1
        fprintf('%s\n',['Found multiple channels for search criteria "' desirechan{a} '"'])
        fprintf('The current file contains the following channels: \n')
        for b = 1:length(allchan)
            fprintf('%s\n',[num2str(b) '. ' allchan{b}])
        end
        in = input('\nPlease enter the index/indices of the channel(s) you want to include for this search criterium\n');
        idx(cnt:cnt+length(in)-1) = in;
        cnt = cnt+length(in);
    else
%         fprintf('Could not find channel "%s"',desirechan{a})
    end
        	
end


