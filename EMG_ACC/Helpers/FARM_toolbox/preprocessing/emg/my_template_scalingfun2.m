% function [newtemplate offsetvector scalingvector] = my_template_scalingfun2(template,n,X)
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
% scaling_off_first           = X(3); %1

% dc_rc_first                 = X(2); %0
% scaling_rc_first            = X(4); %0
% 
% dc_rc_second                = X(5); %0
% scaling_rc_second           = X(6); %0
% 
% dc_rc_third                 = X(7); %0
% scaling_rc_third            = X(8); %0
%
% with these parameters, an 'offset' and 'scaling' vector is
% constructed.
%
% the output is something like y=b+xa:
%
% newtemplate=offsetvector+template'.*scalingvector;



function [newtemplate offsetvector scalingvector] = my_template_scalingfun2(template,n,Y)


X=[Y(1:6) 0 Y(7)];

if numel(X)~=2*numel(n)+4
    
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

offsetvector = [    offsetvector ...
                        X(1)*ones(1,I(1,3)) + ...
                        X(3)*(1:I(1,3)) ...
                   ];
               
scalingvector = [   scalingvector ...
                        X(2)*ones(1,I(1,3)) + ...
                        X(4)*(1:I(1,3)) ...
                    ];

                % keyboard;

for i=1:size(I,1)-1
    
    offsetvector = [    offsetvector ...
                        offsetvector(end)*ones(1,I(i+1,3)) + ...
                        X(i*2-1+4)*(1:I(i+1,3)) ...
                   ];
               
    scalingvector = [   scalingvector ...
                        scalingvector(end)*ones(1,I(i+1,3)) + ...
                        X(i*2+4)*(1:I(i+1,3)) ...
                   ];
                        
end

% keyboard;
% boundary condition: make sure the offsetvector decreases to a value of 0!
% en dan nu de offset weer op 0 krijgen.
tmpbegin=offsetvector(I(end,1)-1);
tmprc=-tmpbegin/(I(end,3));
offsetvector(I(end,1):I(end,2))=tmpbegin+tmprc*(1:I(end,3));

% offsetvector
% scalingvector
% figure;plot(offsetvector);
% figure;plot(scalingvector);

newtemplate=offsetvector+template'.*scalingvector;
newtemplate=newtemplate';
offsetvector=offsetvector';
scalingvector=scalingvector';

