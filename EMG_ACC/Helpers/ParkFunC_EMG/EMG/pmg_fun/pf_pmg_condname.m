function condname  =   pf_pmg_condname(condcode)
% Function to retrieve the name corresponding to the condition code. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if condcode==1
    condname = 'Rest1';
elseif condcode==2
    condname = 'RestCOG1';
elseif condcode==3
    condname = 'RestmoM1';
elseif condcode==4
    condname = 'RestmoL1';
elseif condcode==5
    condname = 'POST1';
elseif condcode==6
    condname = 'POSH1';
elseif condcode==7
    condname = 'POSW1';
elseif condcode==8
    condname = 'EntrM';
elseif condcode==9
    condname = 'EntrL';
elseif condcode==10
    condname = 'Rest2';
elseif condcode==11
    condname = 'RestCOG2';
elseif condcode==12
    condname = 'RestmoM2';
elseif condcode==13
    condname = 'RestmoL2';
elseif condcode==14
    condname = 'POST2';
elseif condcode==15
    condname = 'POSH2';
elseif condcode==16
    condname = 'POSW2';
elseif condcode==17
    condname = 'Rest3';
elseif condcode==18
    condname = 'RestCOG3';
elseif condcode==19
    condname = 'RestmoM3';
elseif condcode==20
    condname = 'RestmoL3';
elseif condcode==21
    condname = 'Weight';
elseif condcode==22
    condname = 'IntentL';
elseif condcode==23
    condname = 'IntentM';
elseif condcode==24
    condname = 'RestAVG';
elseif condcode==25
    condname = 'POSHAVG';
elseif condcode==26
    condname = 'COCOAVG';    
elseif condcode==27
    condname = 'POSTAVG';    
else
    condname = 'NOTFOUND';
    fprintf('%s\n',['Could not detect condition "' condstring '"'])
end


