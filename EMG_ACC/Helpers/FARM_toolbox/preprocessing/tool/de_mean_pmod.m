
% demeans the parametric modulations. seems to be necessary since it's in
% the SPM manual; but maybe SPM already de-means the modulations
% automatically, regardsless! it's more neat to do it this way.
function out=de_mean_pmod(pmod)

    out=pmod;

    for i=1:numel(pmod)
        
        for j=1:numel(pmod(i).param)
            
            
            if pmod(i).param{j}~=0
                out(i).param{j}=detrend(pmod(i).param{j},'constant');
            end

            
            
        end
    end
        