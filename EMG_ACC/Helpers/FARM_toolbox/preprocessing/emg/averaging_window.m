function out=averaging_window(in,N)

    out=in*zeros(1,N);
    out=[out;zeros(N-1,N)];
    
    nummat=zeros(size(out));
    
    for i=1:N

        out((N-i+1):(end-i+1),i)=in;
        nummat((N-i+1):(end-i+1),i)=1;
        
    end
    
    out=sum(out,2)./sum(nummat,2);

    % keyboard;
    out=out((1+floor((N-1)/2)):(numel(out)-ceil((N-1)/2)));