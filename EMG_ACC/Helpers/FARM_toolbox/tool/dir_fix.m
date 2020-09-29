% quick and dirty way of fixing the SPM.mat and job files. 
% warning: works only for SPM.mat and (batch) job-files.
% have fun.

function out=dir_fix(in)

    if ischar(in)
       
        a=load(in);
        variable=fieldnames(a);
        variable=variable{1};


        base=regexprep(pwd,'(.*)(Onderzoek.*)','$1');
        pattern='(^.*)(Onderzoek.*)';
        replace=[base '$2'];
        replace=regexprep(replace,'\\','\\\\');
        a=recurse_modify_field(a,pattern,replace);



        % 2nd fix: computer-dependent fix.

        if numel(regexp(computer,'PC'))>0

            a=recurse_modify_field(a,'/','\\');


        elseif numel(regexp(computer,'GLN'))>0


            a=recurse_modify_field(a,'\\','/');


        elseif numel(regexp(computer,'MAC'))>0

            a=recurse_modify_field(a,'\\','/');


        end

            eval([variable ' = a.' variable]);
            save(in,variable);
            out=[in ' file modified'];
    
    
    else
        
        % keyboard;
        
        
        base=regexprep(pwd,'(.*)(Onderzoek.*)','$1');
        pattern='(^.*)(Onderzoek.*)';
        replace=[base '$2'];
        replace=regexprep(replace,'\\','\\\\');
        out=recurse_modify_field(in,pattern,replace);



        % 2nd fix: computer-dependent fix.

        if numel(regexp(computer,'PC'))>0

            out=recurse_modify_field(out,'/','\\');


        elseif numel(regexp(computer,'GLN'))>0
 
            % disp('ar names and paths...');
            out=recurse_modify_field(out,'\\','/');


        elseif numel(regexp(computer,'MAC'))>0

            out=recurse_modify_field(out,'\\','/');


        end
        
    end
    

    

    
    
    