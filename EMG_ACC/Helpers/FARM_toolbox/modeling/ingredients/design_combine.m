function out=design_combine(in)


    % ga de condities langs!
    matrix=[];
    for i=1:numel(in.names);
        

        tmpmat=[in.onsets{i}' in.durations{i}'];
    

        % ga de parametrische modulaties langs.
        for j=1:numel(in.pmod(i).param)
            
            tmpmat=[tmpmat in.pmod(i).param{j}'];
            
        end

        matrix=[matrix;tmpmat];

        
    end
    
    
    
    % sorteren op tijd.
    matrix_s=sortrows(matrix,1);
    
    
    
    
    % en weer terug-assignen van de waardes!
    out.names='combined';

    out.onsets{1}=matrix_s(:,1)';
    out.durations{1}=matrix_s(:,2)';
    
    out.pmod(1).name=in.pmod(1).name;

    for i=1:(size(matrix_s,2)-2)
        out.pmod(1).param{i}=matrix(:,i+2)';
    end
    out.pmod(1).poly=in.pmod(1).poly;
    
    
