function varagout=settings(varargin)
%SETTINGS: Windows registry access from MATLAB.
%(c) 2005 Mihai Moldovan (M.Moldovan@mfi.ku.dk)
%Only string (REG_SZ) values are implemented 
%-maximum size of a key name is 255 characters 
%-maximum size of a value name is 255 characters (Windows Me/98/95 compatible)
%-there is a theoretical 64K limit for the total size of all values of a key (exceptions are not handled)
% 2009-08-28: paul solved a double '\' escaping problem

  if nargout==0 & nargin==2
      
    if ~isempty(varargin{2})
        e=savesettings(varargin{1},varargin{2});
    else
        e=deletesettings (varargin{1});
    end   
      
    varagout={};
  elseif  nargout==1 & nargin==1
      varagout=loadsettings(varargin{1});
  else    
      varagout={};
      error ('settings(): Bad I/O arguments')
      return
  end
  
  %return
  %----------------------------------------
  
  function e=deletesettings(keyname)
  
  e=1;
  
  s0=loadsettings (keyname);
  if isempty(s0)
      %no such key
      return
  end    
  
  %create the command
  regfile=[tempdir 'temp.reg'];
  nl=char([13 10]); %CRLF
  regh=['REGEDIT4'  nl nl];
  regh=[regh '[-HKEY_LOCAL_MACHINE\SOFTWARE\' keyname ']'];
  
  savestring (regfile, regh);
  
  cmd=['REGEDIT /S ' regfile ];
  dos(cmd);
  e=0;
  
  try  
      %cleanup temp file
      if exist(regfile,'file')
          delete (regfile);
      end
  catch
  end    
  
  %return
  %----------------------------------------
  
  function e=savesettings (keyname,s)
  
  e=1; %error is on
  if ~ischar(keyname) | ~isstruct (s)
      error ('settings(): Expecting keyname, structure')
      return
  end 
  
  s0=loadsettings (keyname);
  f0={};
  
  if ~isempty(s0)
      f0=fieldnames(s0)';
  end
    
  f=fieldnames(s)';
  
  regfile=[tempdir 'temp.reg'];
  nl=char([13 10]); %CRLF
  regtext='';
  
  ff=unique([f0 f]);
  
  for i=1:length(ff)
    key = ff{i};
    if ~ismember (key, f)
        %it is an old key that must be deleted
        regtext=[regtext '"' key '"=-'  nl];    
    else
       
        value=s.(key);
        if ~ischar(value)
            %make it a string here!
            value=num2str(value);
        end
        
        value=escape(value); %escape symbols
       
        if ismember (key, f0)
                   
                if strcmp(value,s0.(key))==0
                    %change only if new
                    regtext=[regtext '"' key '"="' value '"'  nl];
                end     
        else
                %it is a new one
                regtext=[regtext '"' key '"="' value '"'  nl];
       end
        
   end
          
  end    
  
  if isempty(regtext)
      %nothing to change
      e=0;
      return
  end    
  
  %create the header
  regh=['REGEDIT4'  nl nl];
  regh=[regh '[HKEY_LOCAL_MACHINE\SOFTWARE\' keyname ']' nl];
  regh=[regh '@=""' nl]; %default mainkey value
  
  regtext=[regh regtext];
  savestring (regfile, regtext);
  
  cmd=['REGEDIT /S ' regfile ];
  dos(cmd);
  e=0;
  try  
      %cleanup temp file
      if exist(regfile,'file')
          delete (regfile);
      end
  catch
  end    
  
  %return
  %----------------------------------------
    
  function s=loadsettings (keyname)
  
  s=[];
  
  if ~ischar(keyname)
      error ('settings(): Expecting a keyname')
      return
  end
  
  regfile=[tempdir 'temp.reg'];
  
    
  cmd=['REGEDIT /E ' regfile ' "HKEY_LOCAL_MACHINE\SOFTWARE\' keyname '"'];
  dos(cmd);
  
  t=loadlines (regfile);
   
  try  
      %cleanup temp file
      if exist(regfile,'file')
          delete (regfile);
      end
  catch
  end    
  
  n=size(t,2);
  
  if n < 2
      
      return      
  end
  
  % truncate to "key"="value" pairs
  % exception for non-string keys is not handled  
  
  
  for i=3:n
      line=t{i};
      if strcmp(line(1),'@')==0
        %skip default value  
        k=find(line=='"');
        key=line(k(1)+1:k(2)-1);
        value=line(k(3)+1:k(end)-1);
        value=unescape(value);
        
        %make it a number if possible
        nvalue=str2num(value);
        if ~isempty(nvalue)
            s.(key)=nvalue;
        else
            s.(key)=value;
        end    
            
            
      end        
  end
  
  
  
  %return
  %----------------------------------------
  function vout=escape(vin)
  
  vout='';
   
  vout=strrep(vin, '\', '\\'); % paul fixed a double*double escape situation
  vout=strrep(vout, '"','\"');
  
  %return
  %----------------------------------------
  
  
  function vout=unescape(vin)
  
  vout='';
   
  i=1;
  while i <=length(vin)
      
      if vin(i)=='\'
        i=i+1;
      end  
      
      vout=[vout vin(i)];
      
      i=i+1;
  end    
  
  %return
  %----------------------------------------
  
  function savestring (file, t)
  
  try
    fid = fopen(file,'w+');
    fprintf(fid,'%s\n',t); % modified by paul to prevent use of double backslashes
  end

  %make sure the file is closed on exit
  try 
       fclose(fid);    
  end 
    
  %return
  %----------------------------------------
  
   
  function t=loadlines (filename)
  
  t={};
  
  try
  fid = fopen(filename, 'r');
  i=1;
    while feof(fid) == 0
        
        line = fgetl(fid);
        %it may be a UNICODE text file (2 bytes)
        %expecting latin alphabet
        %ignore first line
    
        k=find(line>=' ' & line <='~');
        line=line(k);
        if ~isempty(line)
            t{i}=line;
            i=i+1;
        end        
    end
       
  end  
    
  %make sure the file is closed on exit
  try
      fclose(fid); 
  end    
  %return
  %---------------------------------