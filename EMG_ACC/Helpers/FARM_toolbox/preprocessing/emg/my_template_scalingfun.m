% function [newtemplate offsetvector scalingvector] = my_template_scalingfun(template,n,X)
%
% n = [a b], where a and b is the sample specifying the boudary
% between segments for the construction of the vectors (later on)
% X = for each segment 4 parameters (see below):
%
% custum 'shaping' function of the slice-artefact.
% this allows the artefact to be subdivided into n+1 segments
% for each segment, specify fitparameters for offset and scaling
% for example:
%
% What is does:                 X   ; Initial value for fminsearch
%
% dc_off_first                = X(1); %0
% dc_rc_first                 = X(2); %0
% scaling_off_first           = X(3); %1
% scaling_rc_first            = X(4); %0
% 
% dc_off_second               = X(5); %0
% dc_rc_second                = X(6); %0
% scaling_off_second          = X(7); %1
% scaling_rc_second           = X(8); %0
% 
% dc_off_third                = X(9); %0
% dc_rc_third                 = X(10); %0
% scaling_off_third           = X(11); %1
% scaling_rc_third            = X(12); %0
%
% with these parameters, an 'offset' and 'scaling' vector is
% constructed.
%
% the output is something like y=b+xa:
%
% newtemplate=offsetvector+template'.*scalingvector;



function [newtemplate offsetvector scalingvector] = my_template_scalingfun(template,n,X)


if numel(X)~=4*(numel(n)+1)
    
    error('You should be sure to have (n+1)*4 parameters in X!!');
    
end


N=numel(template);

I=[1 N numel(1:N)];

for i=1:numel(n)
    
    I(end,:)=[I(end,1) n(i) numel(I(end,1):n(i))];
    I(end+1,:)=[n(i)+1 N numel((n(i)+1):N)];
end


    % n=    [1:end_first_segment;
    %       [endend_second_segment];



% build offset and scaling vectors.
offsetvector=[];
scalingvector=[];

for i=1:size(I,1)
    
    offsetvector = [    offsetvector ...
                        X((i-1)*4+1)*ones(1,I(i,3)) + ...
                        X((i-1)*4+2)*(1:I(i,3)) ...
                   ];
    scalingvector = [   scalingvector ...
                        X((i-1)*4+3)*ones(1,I(i,3)) + ...
                        X((i-1)*4+4)*(1:I(i,3)) ...
                   ];
                        
end

% offsetvector
% scalingvector
% figure;plot(offsetvector);
% figure;plot(scalingvector);

newtemplate=offsetvector+template'.*scalingvector;
newtemplate=newtemplate';
offsetvector=offsetvector';
scalingvector=scalingvector';

                                                                                  
