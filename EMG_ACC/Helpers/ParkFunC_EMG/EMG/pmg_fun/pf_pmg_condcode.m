function [condcodes,cond]  =   pf_pmg_condcode(condstring)
% Function to retrieve the code corresponding to the condition. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if iscell(condstring)
    nString   =   length(condstring);
else
    nString   =   1;
end
condcodes =   nan(nString,1);

for a = 1:nString
    if ~isempty(strfind(condstring,'Rest1'))
        cond = 'rest';
        condcode = 1;
    elseif ~isempty(strfind(condstring,'Rest2'))
        cond = 'rest';
        condcode = 10;
    elseif ~isempty(strfind(condstring,'Rest3'))
        cond = 'rest';
        condcode = 17;
    elseif ~isempty(strfind(condstring,'Rest'))
        cond = 'rest';
        condcode = 24;
    elseif ~isempty(strfind(condstring,'Coco'))
        cond = 'Coco';
        condcode = 26;
    elseif ~isempty(strfind(condstring,'RestCOG1'))
        cond = 'coco';
        condcode = 2;
    elseif ~isempty(strfind(condstring,'RestCOG2'))
        cond = 'coco';
        condcode = 11;
    elseif ~isempty(strfind(condstring,'RestCOG3'))
        cond = 'coco';
        condcode = 18;
    elseif ~isempty(strfind(condstring,'RestmoM1'))
        cond = 'most';
        condcode = 3;
    elseif ~isempty(strfind(condstring,'RestmoM2'))
        cond = 'most';
        condcode = 12;
    elseif ~isempty(strfind(condstring,'RestmoM3'))
        cond = 'most';
        condcode = 19;
    elseif ~isempty(strfind(condstring,'EntrM'))
        cond = 'most';
        condcode = 8;
    elseif ~isempty(strfind(condstring,'RestmoL1'))
        cond = 'least';
        condcode = 4;
    elseif ~isempty(strfind(condstring,'RestmoL2'))
        cond = 'least';
        condcode = 13;
    elseif ~isempty(strfind(condstring,'RestmoL3'))
        cond = 'least';
        condcode = 20;
    elseif ~isempty(strfind(condstring,'EntrL'))
        cond = 'least';
        condcode = 9;
    elseif ~isempty(strfind(condstring,'POSH'))
        cond = 'posh';
        condcode = 25;
    elseif ~isempty(strfind(condstring,'POSH1'))
        cond = 'posh';
        condcode = 6;
    elseif ~isempty(strfind(condstring,'POSH2'))
        cond = 'posh';
        condcode = 15;
    elseif ~isempty(strfind(condstring,'POST'))
        cond = 'post';
        condcode = 27;
    elseif ~isempty(strfind(condstring,'POST1'))
        cond = 'post';
        condcode = 5;
    elseif ~isempty(strfind(condstring,'POST2'))
        cond = 'post';
        condcode = 14;
    elseif ~isempty(strfind(condstring,'Weight'))
        cond = 'weight';
        condcode = 21;
    else
        cond     = 'NOTFOUND';
        condcode = nan;
        fprintf('%s\n',['Could not detect condition "' condstring '"'])
    end
    condcodes(a) = condcode;
end
