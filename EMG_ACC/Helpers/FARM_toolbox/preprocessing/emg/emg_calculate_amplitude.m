function [a]=emg_calculate_amplitude(v,m)

    
    
    for i=1:numel(m.b)
       
        % keyboard;
        
        a(i)=max(v(m.b(i):m.e(i))); %-noise(m.b(i):m.e(i)));
        
        if a(i)<0
            a(i)=0;
            disp('latency < 0??');
        end

    end
    
