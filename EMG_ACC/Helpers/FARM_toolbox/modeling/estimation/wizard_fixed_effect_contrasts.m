function [ retC ] = wizard_fixed_effect_contrasts(  )
% WIZARD_FIXED_EFFECT_CONTRASTS a tiny wizard that creates contrast vectors
% for 1-st level fixed effects analysis. Especially helpful when you have 
% (lots of) scan nulling regressors.

% % study, patients, taak, analysis, 
% % if nargin<5
% %     if exist('X:\Onderzoek\Lopend_onderzoek\fMRI\','dir')
% %         root = 'X:\Onderzoek\Lopend_onderzoek\fMRI\';
% %     else
% %         root = pwd;
% %     end
% % else
% %     root = wdir;
% % end
% % root = regexprep(root, '(^.*)([\\/]fMRI[\\/])(.*)', '$1$2', 'once', 'ignorecase');
% % if ~exist(root, 'dir')
% %     error(['Data directory does not exist: ' root]);
% % end
% % 
% % if nargin<1 || isempty(study)
% %     root = uigetdir(root,'Select Study');
% %     if root==0
% %         error('User abort...')
% %     end
% % else
% %     root = fullfile(root,study);
% % end
% % 
% % if nargin<2 || isempty(patients)
% %     [patients,path] = uigetfile('????','Include Patients','MultiSelect','on',root) ;
% %     if patients==0
% %         error('User abort...')
% %     end
% % end


[spmmatfile, sts] = spm_select(1,'^SPM\.mat$','Select SPM.mat');
swd = spm_str_manip(spmmatfile,'H');

%-Preliminaries...
%==========================================================================

%-Load SPM.mat
%--------------------------------------------------------------------------
if exist('SPM','var') ~= 1
  try
      load(fullfile(swd,'SPM.mat'));
  catch
      error(['Cannot read ' fullfile(swd,'SPM.mat')]);
  end
  SPM.swd = swd;
end

if ~isfield(SPM,'xX')
   error(['Design matrix not found in ' fullfile(swd,'SPM.mat')]);
end

answer = inputdlg('define contrasts (excl scan nulling)','contrast wizard');
answer = strtrim(answer{1});
if ~isempty(answer) && ~strcmp(answer(1),'[')
    answer = [ '[' answer ];
end
if ~isempty(answer) && ~strcmp(answer(end),']')
    answer = [ answer ']' ];
end
[S V] = evalc(answer);
if ~isnumeric(V)
    error(['Expected a vector definition in ' S]);
end
nContrasts = length(V);
% get all the subject/session numbers from the design table header: Sn(#) links_strekken...
T = regexp(SPM.xX.name,'^Sn\((\d+)\)','tokens','once'); % T will be a cell array of cell{1x1} objects
n = length(T);
C = zeros(1,n);
old_session_nr = 0;
for iRegressor=1:(n-nContrasts+1)
    session_nr = str2double(T{iRegressor});
    if old_session_nr<session_nr % NB: the last columns will restart numbering for the constants, so skip those...
        fprintf('starting a new session (%d) at column %d\n',session_nr,iRegressor);
        C(iRegressor:iRegressor+nContrasts-1) = V(:);
        old_session_nr = session_nr;
    end
end

if nargout>0
    retC = C;
else
    S = sprintf('%g ',C);
    clipboard('copy', S);
    fprintf('\nThe following contrast vector is copied to the clipboard:\n%s\n',S);
end

end

