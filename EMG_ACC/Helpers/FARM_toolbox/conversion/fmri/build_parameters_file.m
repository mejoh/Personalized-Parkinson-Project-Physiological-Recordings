function [ parameters, message ] = build_parameters_file( parfile, parameterfile )
%BUILD_PARAMETERS_FILE creates a compact MR parameter file.
%   The new parameter file contains a subset of a native Philips par-file.
%   Loading of PAR-files is implemented by r2agui (http://r2agui.sourceforge.net/),
%   so make sure that the r2agui package is installed on your computer and 
%   added to the matlab path.
%   This function is a replacement for the build_parameters_file.pl Perl 
%   script, which depends on a perl interpreter and a Unix-like shell.
%
% 2009-10-01, Paul Groot

    msg = [];
    
    if nargout>=1
        parameters = [];
    end
    if nargout>=2
        message = [];
    end
    
    if exist('read_par','file')~=2
        msg = 'r2agui is not installed or not included in the your path. Install from: http://r2agui.sourceforge.net/';
    else
        try
            par = read_par(parfile);
        catch
            msg = [ 'Philips MR parameter file not found: ' parfile ];
            par = [];
        end
        if ~isempty(par)
            fid = fopen(parameterfile,'w');
            if fid==-1
                msg = [ 'Could not create parameter file: ' parameterfile ];
            else
                parameters = zeros(1,6);
                parameters(1) = par.RT;
                parameters(2) = par.slice;
                parameters(3) = par.dyn;
                parameters(4) = par.vox(1);
                parameters(5) = par.vox(2);
                parameters(6) = par.vox(3);
                fprintf(fid,'%g\n', parameters);
                fclose(fid);
            end
        end
    end

    if nargout>=2
        message = msg;
    end
    if ~isempty(msg)
        disp(msg)
    end

end

