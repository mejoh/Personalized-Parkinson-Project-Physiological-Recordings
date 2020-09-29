V=spm_vol(spm_get(Inf,'*.img'));
 for i=1:length(V),
 VI = V(i);
 VO = VI;
 [pth,nm,xt,vr] = fileparts(deblank(VO.fname));
 VO.fname = fullfile(pth,['f' nm xt vr]);
 VO.descrip = [VO.descrip ' - flipped'];
 VO = spm_create_image(VO);
 for j=1:VI.dim(3),
 M = spm_matrix([0 0 j]);
 img = spm_slice_vol(VI,M,VI.dim(1:2),0);
 img = flipud(img);
 VO  = spm_write_plane(VO,img,j);
end;
end;

