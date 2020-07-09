function mat_make_snapshot(dDir,title,m)

    for i=1:size(m,2)
        
        v=m(:,i);
        
        v=v/sqrt(dot(v,v));
        
        m(:,i)=v;
        
    end
    
    fh=figure;
    set(fh,'visible','off');

    imagesc(m);
    colormap bone
    
    
    saveas(fh,[dDir title '.jpg'],'jpg');
    
    