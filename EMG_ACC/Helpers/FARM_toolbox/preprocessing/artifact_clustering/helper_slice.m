% helper_slice(EEG,slicenumber,channel,sl,pc)
% 
% ! this function assumes that you've already clustered the data. It's not
% suitable to use it to make a matrix of slice-artifacts around 1 slice.
% you should do that manually.

% this function's function is for generating a matrix for PCA.

function [template returnmat]=helper_slice(iv,adjust,j,i,sl,pc)


    % backwards compatibility to get a slice also directly, like a
    % diagnostic function...
    if isstruct(iv)
    
        [samples adjust]=marker_helper(j,sl,interpfactor);
        v=iv.data(i,samples);
        iv=interp(v,interpfactor);
        
        
    end
    
    
    parts=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
    % scalings=sl(j).scalingdata(i,parts);
    
    % for double-checking, construct also the 'curdata'.
    curdata=iv((sl(j).b-adjust):(sl(j).e-adjust))';
    
    % construct the template.
    mat=zeros(numel(curdata),numel(parts));
    for tc=1:numel(parts)
        try
        tmp_b=sl(sl(j).others(parts(tc))).b-adjust;
        tmp_e=sl(sl(j).others(parts(tc))).e-adjust;
        
        otherdata=iv(tmp_b:tmp_e)'; 
        mat(:,tc)=otherdata;
        catch;keyboard;lasterr;end

    end
    template=mean(mat,2);
    
    returnmat=zeros(numel(curdata),numel(sl(j).clusterdata(i,:)));
    returnmat(:,1:size(mat,2))=mat;
    
    parts2=find(sl(j).clusterdata(i,:)~=sl(j).chosenTemplate(i));
    for tc=1:numel(parts2)

        tmp_b=sl(sl(j).others(parts2(tc))).b-adjust;
        tmp_e=sl(sl(j).others(parts2(tc))).e-adjust;
        
        otherdata=iv(tmp_b:tmp_e)'; 
        
        returnmat(:,size(mat,2)+tc)=otherdata';
    end
    
    
    
    
    % keyboard;
    
    % returnmat=mat;
    % figure;plot(mat)
   
    % keyboard;
    
%     if numel(sl(j).template_adjusts)==0
%         sl(j).template_adjusts=zeros(1,8);
%     end

%     if numel(sl(j).template_scalings)==0
%         sl(j).template_scalings=zeros(1,8);
%     end
    
    
    % if an extra slice-shift has been calculated, apply it now.
%        extra_adjust=sl(j).template_adjusts(i);
%     if sum(sl(j).template_adjusts(i))~=0
%         
%         
% 
%         if extra_adjust>0
%             tmp=template(1+extra_adjust:end);
%             
%             % determine RC at the end of template.
%             rc=template(end)/2-template(end-2)/2;
%             
%             tmp((numel(tmp)+1):(numel(tmp)+extra_adjust))=template(end)+rc*(1:extra_adjust);
%             
%             template=tmp;
%         end
%         
%         if extra_adjust<0
%             
%             % keyboard;
%             tmp((1-extra_adjust):numel(template))=template(1:(end+extra_adjust));
%             
%             % determine RC at the beginning of template.
%             rc=template(1)/2-template(3)/2;
%             tmp(1:(-extra_adjust))=template(1)+rc*((-extra_adjust):-1:1);
%             
%             template=tmp';
%         
%         end
%  
%     end
    
%     
%     if sl(j).template_scalings(i)~=0;
%         
%         % keyboard;
%        
%         template=template*sl(j).template_scalings(i);
%         
%     end
    
    
  
    
    % template=template;
    
    

