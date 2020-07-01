function channames =  pf_pmg_channame(curchan,allchan)
%
% Return the trivial channel name coded by curchan. For this you have to
% specify two names for every row in allchan, first column the coded
% channel and the second column the trivial name. 

% ©Michiel Dirkx, 2014
% $ParkFunC

%% Select channels

ncChan = length(curchan);

for a = 1:ncChan
	
	sc	=	strfind(allchan,curchan{a});
	sc  =	~cellfun(@isempty,sc);
	idx =	find(sc==1);
	
	if length(idx)>2
		fprintf('Found multiple channels for "%s"\n',curchan{a})
		disp(allchan(idx))
    elseif isempty(idx)
        fprintf('Could not find "%s"\n',curchan{a})
        for b = 1:length(allchan)
            disp([num2str(b) '. ' allchan{b,:}])
        end
        idx = input('Enter the index of the channel');
	end
			
	channames{a,1}	=	allchan{idx,2};
	
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


