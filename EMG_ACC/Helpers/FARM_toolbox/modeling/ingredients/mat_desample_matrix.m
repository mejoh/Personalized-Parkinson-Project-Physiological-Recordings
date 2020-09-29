function outmat=mat_desample_matrix(m,nvol,srate)


    % 'desampled' m...
    dm=zeros(nvol,size(m,2));


    for i=1:nvol
        for j=1:size(m,2)

            b=round((i-1)*srate)+1;
            e=round(i*srate);

            dm(i,j)=mean(m(b:e,j));

        end
    end


    outmat=dm;