% adjusts for all rows of M, the phase at point p in the frequency spectrum
% so that it matches with the phase of v at point p.

function Mout=helper_phasematching(M,v,points)


    Mout=zeros(size(M));
    V=fft(v);

    for j=1:numel(points)
        
        p=points(j);
        for i=1:size(M,2)

            % keyboard;

            u=M(:,i);
            U=fft(u);

            U(p)=abs(U(p))*exp(1j*angle(V(p)));

            U(end-p+2)=abs(U(end-p+2))*exp(1j*angle(V(end-p+2)));

            Mout(:,i)=ifft(U);

        end
        
    end
    

