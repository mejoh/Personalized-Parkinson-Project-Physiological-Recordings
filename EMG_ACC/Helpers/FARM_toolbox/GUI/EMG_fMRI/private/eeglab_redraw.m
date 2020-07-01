function eeglab_redraw( )
%EEGLAB_REDRAW Update EEGLab GUI (if running)
    if eeglab_available
        eeglab('redraw');
    end
end

