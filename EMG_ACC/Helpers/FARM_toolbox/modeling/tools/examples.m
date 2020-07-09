% a high sample working rate.



srate=128;


cd([wdir 'gonogo1/']);
load parameters
tr=parameters(1);
nvol=parameters(3);


load block.mat
load event.mat

load rp_a4D.txt

load emg_meanabs.txt

% to get our model
m=mat_build_matrix(onsets,durations,tr,nvol,srate);
m=mat_convolve_hrf(m,tr,srate,'hrf3');
model=mat_desample_matrix(m,nvol,srate);


% to get the raw basic block design
m=mat_build_matrix(onsets,durations,tr,nvol,srate);
blocks=mat_desample_matrix(m,nvol,srate);




