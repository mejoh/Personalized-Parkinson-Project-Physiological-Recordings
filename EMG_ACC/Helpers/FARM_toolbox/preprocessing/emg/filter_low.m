function d=filter_low(d,o)


for i=1:o.nch
   
    d.anc(:,i)=helper_filter(d.anc(:,i),o.filter.anclpf,o.fs,'low');
    d.clean(:,i)=helper_filter(d.clean(:,i),o.filter.anclpf,o.fs,'low');
        
end