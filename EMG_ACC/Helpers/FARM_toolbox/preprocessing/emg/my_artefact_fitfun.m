function diff = my_artefact_fitfun(artefact,template,n,X)


dc_off_first                = X(1); %0
dc_rc_first                 = X(2); %0
scaling_off_first           = X(3); %1
scaling_rc_first            = X(4); %0

dc_off_second               = X(5); %0
dc_rc_second                = X(6); %0
scaling_off_second          = X(7); %1
scaling_rc_second           = X(8); %0

N=numel(template);

offsetvector = [   dc_off_first*ones(1,n)+dc_rc_first*(1:n)...
                    dc_off_second*ones(1,N-n)+dc_rc_second*(1:(N-n))...
                ]';

scalingvector = [   scaling_off_first*ones(1,n)+scaling_rc_first*(1:n)...
                    scaling_off_second*ones(1,N-n)+scaling_rc_second*(1:(N-n))...
                ]';
            
newtemplate=offsetvector+template.*scalingvector;
            
diff = sum((artefact-newtemplate).^2);



