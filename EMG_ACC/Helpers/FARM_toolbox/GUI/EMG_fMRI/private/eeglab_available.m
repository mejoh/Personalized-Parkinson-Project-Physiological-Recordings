function [ result ] = eeglab_available( input_args )
%EEGLAB_AVAILABLE returns true if EEGLab is available
    result = exist('eeglab.m','file');

end

