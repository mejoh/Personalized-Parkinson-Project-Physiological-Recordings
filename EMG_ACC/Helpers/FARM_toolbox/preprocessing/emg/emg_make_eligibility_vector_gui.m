% vec = emg_make_eligibility_vector(b,e,m,totpoints,cond,Vmarker,expandVmarker,expand);
%
% customized "segmentation" function.
%
% b = begins (struct)
% e = ends (struct)
% m = [], or struct with bb and be (bad parts of signal)
% totpoints = total points in trace (int)
% cond = which cond you'd like to have this vector for (string)
% Vmarker  = all V markers (int)
% expandVmarker = how many points around Vmarkers are to be 0-ed (int)
% expand = how much to expand around markers that are 'active' (1-by-2 int)

function vec = emg_make_eligibility_vector_gui(params)


    % keyboard;
    pfields=fieldnames(params);
    for i=1:numel(pfields)
        eval([pfields{i} '=params.' pfields{i} ';']);
        disp(['var = ' pfields{i}]);
    end
    
    if isfield(b,'end');b=rmfield(b,'end');end
    if isfield(e,'end');e=rmfield(e,'end');end
    
    names=fieldnames(b);

    % this defines our output. for active muscles give separate output for
    % each condition.
    % we will divide vec into N parts, always, for even in the resting
    % condition, different parts of 'rest' have different amounts of
    % 'baseline' noise. 
    % So for wavelet analysis, scale the data in a subsequent step, using
    % the divisions that are used here.
    %    
    % and THEN, do wavelet analysis; where 'active' indicates whether
    % different 'vecs' are summed.
    

        

    
    vec=cell(1,numel(names));
    
    % keyboard;
    
    % apply segmentation, VOmit and condOmit.
    for i=1:numel(names)
        
        shifts=round(condOmit(i,1:2)*srate);

        vec{i}=logical(zeros(numel(b.(names{i})),totpoints));
        % keyboard;
        
        for j=1:numel(b.(names{i}))
            b_i=b.(names{i})(j);
            e_i=e.(names{i})(j);
            
            
            if j==1
                
                b_i = b_i + shifts(1);
                e_i = e_i + shifts(2);
                
                
            elseif j==numel(b.(names{i}))
                
                b_i = b_i + shifts(1);
                e_i = e_i + shifts(2);
                if b_i>totpoints
                    b_i=[];
                    e_i=[];
                end
                
            else
                
                b_i = b_i + shifts(1);
                e_i = e_i + shifts(2);
                
            end
            
            try
            vec{i}(j,b_i:e_i)=1;
            catch
                keyboard;
            end
            
        end
        
        if size(vec{i},2)>totpoints
            vec{i}=vec{i}(:,1:totpoints);
        end
        
    end



    
    % cleanup: use m.be and m.bb, and Vmarker and expandVmarker to clean it
    % all up.
    if numel(badparts)>0
        
  
        for i=1:numel(badparts.bb)
            
            for j=1:numel(vec)
                vec{j}(:,badparts.bb(i):badparts.be(i))=0;
            end
        end
        
    end
    
    
    if sum(abs(VOmit))>0
        
        for i=1:numel(Vmarker)
            
            
            b_i=Vmarker(i)+round(VOmit(1)*srate);
            e_i=Vmarker(i)+round(VOmit(2)*srate);
            
            if b_i<1
                b_i=1;
            end
            if e_i>totpoints
                e_i=totpoints;
            end
            
            % keyboard;
            for j=1:numel(vec)
                vec{j}(:,b_i:e_i)=0;
            end
        end
        
    end

    
    
    
       
    
    