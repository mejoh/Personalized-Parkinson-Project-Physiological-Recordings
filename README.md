# Personalized-Parkinson-Project-Physiological-Recordings
Scripts used for analyzing physiological recordings of the Personalized Parkinson Project

Dependencies: 
1) EEGLab 14.0.0b - see: ftp://sccn.ucsd.edu/pub/daily/
   - eeglab GUI > 'File' > 'Manage EEGLAB extensions > 'Data import extensions' > Install 'bva-io'
2) FARM           - included
3) ParkFunC_EMG   - included


# EmgAccChecker 
Gui loops through all power spectra images, allows to store information about the presence of tremor (yes/no/unclear) and if the right peak is selected (yes/no/unclear). 
Outpt = xlsx and mat table for tremor presence and if the right peak is selected (0 = no, 1 = yes, 2 = unclear) in a particular image. 
Dependencies: 
1) AccEmgChecker.fig
