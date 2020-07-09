function d=filter_high(d,o)


for i=1:o.nch
   
    d.clean(:,i)=helper_filter(d.clean(:,i),o.filter.hpf,o.fs,'high');
        
end
