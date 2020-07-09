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

function vec = emg_make_eligibility_vector(totpoints,b,e,shifts,Vmarker,expandVmarker,m)


    keyboard;
    b=rmfield(b,'end');
    e=rmfield(e,'end');
    
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
    
    active=1;
    if active
        vec=cell(1,numel(names));
        for i=1:numel(vec)
            % don't need doubles to store 0-1.
            vec{i}=logical(zeros(1,totpoints));
        end
    else
        vec=cell(1);
        vec{1}=logical(zeros(1,totpoints));
    end

    
    % firstly, set set stuff to '1', taking into account stuff like 0.1 and
    % 1.6 [s] difference from the markers.
    for i=1:numel(names)
            
        for j=1:numel(b.(names{i}))
            
            b_i=b.(names{i})(j);
            e_i=e.(names{i})(j);
            
            
            if numel(regexpi(names{i},'usr_r.st','match'))>0

                % with rest, delay with 0.1 sec and shorten with 0.2 sec
                if j==1
                    % do not delay first rest marker.
                    e_i=e_i-shifts(1);

                elseif j==numel(b.(names{i}))
                    % use different lengthening for final rest marker.
                    b_i=b_i+shifts(1);
                    if e_i > totpoints
                        e_i=totpoints;
                    end
                    
                else
                    b_i=b_i+shifts(1);
                    e_i=e_i-2*shifts(1);
                    
                end

            else
                % with all other active conditions, delay with 1.6 sec and
                % shorten with 3.2 sec
                b_i=b_i+shifts(2);
                e_i=e_i-shifts(2);
            end
            
            
            % adjust b_i and e_i with respect to condition and stuff.
            
            
            if active
                % do separately... auto-fill.
                vec{i}(end+1,b_i:e_i)=1;
            else
                % set it all to 1!
                vec{1}(end+1,b_i:e_i)=1;
            end
        end
        
        
        
    end
    
    % cleanup: use m.be and m.bb, and Vmarker and expandVmarker to clean it
    % all up.
    if numel(m)>0
        
  
        for i=1:numel(m.bb)
            
            for j=1:numel(vec)
                vec{j}(:,m.bb(i):m.be(i))=0;
            end
        end
        
        
    end
    
    
    if numel(Vmarker)>0&&expandVmarker>0
        
        
        for i=1:numel(Vmarker)
            
            
            b_i=Vmarker(i)-expandVmarker;
            e_i=Vmarker(i)+expandVmarker;
            
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
    
    
    % remove 0's at the beginning.
    
    for i=1:numel(vec)
        vec{i}(1,:)=[];
    end
    
    
    
       
    
    