function fmri_4Drotate(study,pp,taak,matfile,wdir)

%! behoud van voxelgrootte nu geincorporeerd.
%! deze functie past de .mat files aan door * een rotatie te doen over 2
%! assen van 90 graden

if nargin<5
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/fmri/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/' taak '/fmri/'];
end
disp(wdir);

load([wdir matfile]);

save([wdir matfile(1:end-4) '_old.mat'],'mat');


% rotate according to a nice spm orientation...
newmat=zeros(size(mat));


for i=1:size(mat,3)
   
    % hm; nu 'setten' we gewoon de orientatie op deze manier.
    % per scan opnieuw bekijken, eigelijk.
    % eerst over z met -pi, en daarna over y met -pi levert deze
    % rotatie-matrix op:
    % [0 0 1 0;1 0 0 0;0 1 0 0;0 0 0 1]
    
    oldm=mat(:,:,i);
    newm=[0 0 1 0;1 0 0 0;0 1 0 0;0 0 0 1]*oldm;
    newm(:,4)=[-66 105.5 -105.0 1]';
    newmat(:,:,i)=newm;
    
%     newmat(:,:,i)=[...
%     m=[         0         0    3.0000  -66.0000;...
%         -2.1979        0         0  105.5000;...
%              0    2.1979         0 -105.5000;...
%              0         0         0    1.0000;...
%          ];

end

mat=newmat;

% af en toe zijn de matrices gevuld met 0. verhelp dit.
% waarom dit is; ik denk dat ie ook in header informtie zoekt van de .nii
% ipv de .mat file. Ik denk dat als de .mat file > 0 is, dat ie dan zoekt
% in .mat en anders in .imghdr.

for i=size(mat,3):-1:1
    if mat(1:3,1:3,i)==zeros(3,3)
        mat(:,:,i)=mat(:,:,i+1);
    end
end
        



save([wdir matfile],'mat');

