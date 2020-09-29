function SC = pf_getSC(conf,str,varargin)

% PF_getSC(conf,str,varargin) returns a string containing search
% criteria that can be used for pf_findfile for inputs:
%    - conf: structure used for ParkFunC analysis scripts. Leave [] if not
%            used
%    - str:  string containing all your search criteria, seperated by '/'.
%    - varargin: containing indices of the criteria that need to be
%	   replaced preceded by corresponding search criterion (i.e.
%	   'CurSub',1)
%
% Specifically, it can replace dependent  variables that are used in loops, 
% so you get the right current subject string ('CurSub') or current session
% ('CurSess') and so forth. The search criterie (SC string) can then be 
% used for finding your files using PF_findfiles. You can use the following
% dependent variables:
%    - 'CurSub',i   =   Uses subject specific string from conf.sub.name with
%                       index i.
%    - 'CurSess',i  =   Uses session specific string from conf.sub.sess
%                       with index i (or conf.dir.func.sess)
%    - 'CurROI',i   =   Uses the current ROI string from conf.voi.roi.name
%                       with index i
%    - 'CurHand',i  =   Uses the current hand (0='L'; 1='R') defined
%                       in conf.sub.hand. S
%    - 'CurHandc',i =   Uses the current contralateral hand (0='R';1='L')
%                       defined in conf.sub.hand with index i
%
% Example: SC = pf_getSC(conf,'/EMG_/&/CurSub/&/.edf/','CurSub',3);
%          SC = 'EMG_&S03&.edf'
%
% See also pf_findfile.m

% © Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC

%% Warming Up

if ~isempty(varargin)
    if length(varargin) == 1            % If redirected from PF_find_fullfile
        varargin    =   varargin{:};
    end
    
    for a = 1:length(varargin)
    if mod(a,2) == 1
    switch varargin{a}
        case 'CurSub'
        CSi		=	varargin{a+1};
        case 'CurSess'
        CSEi	=	varargin{a+1};
        case 'CurROI'
        CRi     =   varargin{a+1}; 
        case 'CurHand'
        CRh     =   varargin{a+1}; 
        case 'CurHandc'
        CRhc    =   varargin{a+1}; 
        case 'CurRun'
        CRUNi   =   varargin{a+1};    
    end
    end
    end
end
%% Create Search Criteria (SC) Cell

sep		=	'/';					% File seperator
sf		=	strfind(str,sep);		% Indices of sep
nSf		=	length(sf);				% Initiate for loop	
SC		=	cell(nSf-1,1);			% Initiate SC struct

% -- loop throug search criteria -- %

for a = 1:nSf -1
	SCc     =	str( sf(a)+1 : sf(a+1) -1 );
    
    and     =   strfind(SCc,'^');
    
    if ~isempty(and)
        SCd = SCc(1:and(1)-1);
        and = SCc(and(1)+1:and(2)-1);
    else
        SCd = SCc;
        and = '';
    end
    
    switch SCd
        case 'CurSub'
            SCd	 =	conf.sub.name{CSi};
        case 'CurSess'
            try
                SCd  =	conf.sub.sess{CSEi};
            catch 
                SCd  =  conf.dir.func.sess{CSEi};
            end
        case 'CurROI'
            SCd  =   conf.voi.roi.name{CRi};
        case 'CurHand'
            code =   conf.sub.hand(CRh);
            if code == 0; SCd = 'L'; elseif code == 1; SCd = 'R'; end
        case 'CurHandc'
            code =   conf.sub.hand(CRhc);
            if code == 0; SCd = 'R'; elseif code == 1; SCd = 'L'; end
        case 'CurSide'
            SCd  =  conf.sub.curside;
        case 'CurRun'
            try
                SCd  =  conf.dir.func.run{CRUNi};
            catch
                SCd  =  conf.sub.run{CRUNi};
            end
    end
    
    SC{a} =	[SCd and];
end
	
SC	=	strcat(SC{:});	% Make a nice string again	





