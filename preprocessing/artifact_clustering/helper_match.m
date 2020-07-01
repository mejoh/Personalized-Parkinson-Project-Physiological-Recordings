function groupi=helper_match(curdata,clustermat_unscaled,detail,N,N2)


                
                curdata=curdata(detail);
                clustermat_unscaled=clustermat_unscaled(detail,:);
                
                % keyboard;
                % scale the clustermat_unscaled.
%                 for k=1:size(clustermat_unscaled,2)
%                    
%                     candidate=clustermat_unscaled(:,k);
%                     
%                     scaling=curdata'*candidate/(candidate'*candidate);
%                     
%                     clustermat_unscaled(:,k)=candidate*scaling;
%                     
%                 end


                % calculate each other's correlation wrt the curdata.
                templ_corrs=ones(1,size(clustermat_unscaled,2));
                for k=1:size(clustermat_unscaled,2)
                   
                    candidate=clustermat_unscaled(:,k);
                    
                    templ_corrs(k)=prcorr2(candidate,curdata);
                    
                end
                mat=sortrows([(1:numel(templ_corrs))' (1-templ_corrs)'],2);
                mat=sortrows([[ones(1,N) 2*ones(1,size(clustermat_unscaled,2)-N)]' mat],3);
                
                % mat: 1st index, the group.
                % 2nd index, the number of the 'other',
                % 2rd index, the correlation (!!).
                
                % apply second rule of selection: consistency!
                tmpind=mat(find(mat(:,1)==1),2);

                consistancy=[tmpind sum(squareform(pdist(clustermat_unscaled(:,tmpind)')))'];
                consistancy=sortrows(consistancy,2);
            
                groupi=consistancy(1:N2,1);
                

               
