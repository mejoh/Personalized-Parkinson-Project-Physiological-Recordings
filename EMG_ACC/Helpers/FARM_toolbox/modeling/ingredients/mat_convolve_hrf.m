% function outmat=mat_convolve_hrf(m,tr,srate,option)
%
% srate = samples / volume (NOT samples / s!) -- make sure it's alot
% option = 'hrf1','hrf2','hrf3'
% 
function outmat=mat_convolve_hrf(m,tr,srate,option)


    % get a nice hrf function.
    hrf=spm_hrf(tr/srate);

    % afleiden en schalen...
    dhrf=[0;hrf(2:end)-hrf(1:end-1)];
    dhrf=dhrf/max(abs(dhrf))*max(abs(hrf));

    % en nog n keer!
    ddhrf=[0;dhrf(2:end)-dhrf(1:end-1)];
    ddhrf=ddhrf/max(abs(ddhrf))*max(abs(dhrf));


    nm=[];

    for i=1:size(m,2)

        % do the convolve game.
        v=m(:,i);
        vsize=numel(v);

        v_hrf   = conv(v,hrf);
        v_dhrf  = conv(v,dhrf);
        v_ddhrf = conv(v,ddhrf);

        % convolving lengthens your vectors... so adjust.
        v_hrf   = v_hrf(1:vsize);
        v_dhrf  = v_dhrf(1:vsize);
        v_ddhrf = v_ddhrf(1:vsize);

        % output matrix construction.
        switch option

            case 'hrf1'
                nm=[nm v_hrf];
            case 'hrf2'
                nm=[nm v_hrf v_dhrf];
            case 'hrf3'
                nm=[nm v_hrf v_dhrf v_ddhrf];

        end

    end
    
    outmat=nm;


