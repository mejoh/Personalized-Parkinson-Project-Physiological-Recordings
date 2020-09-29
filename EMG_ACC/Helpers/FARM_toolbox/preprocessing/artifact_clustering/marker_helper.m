% a helper function to help me with the 'sectioning'.
% this function yields 
% a) which samples to interpolate in v. (in 'normal' space).
% b) the 'adjusts' for the b and e values in sl. (in 'interpolated' space)
%
% it takes sl and an array of i.

function [samples adjust]=marker_helper(sli,sl,interpfactor)



        % take some data from this one.
        % first find the minimum sample and the maximum sample needed in
        % this calculation.
        % take 5 extra samples, to deal with the slice-select corrections.
        
        % so if min(sli)==1, then min(sl(1).others) would be 2, and sl(2).b
        % would be taken for the beginning of this exercise. this is wrong,
        % since you need sl(1).b as the beginning. hence the correction
        % below.
        
        
        % determine min sample(interpolated space) and max sample (also
        % interpolated space)

        % keyboard;
        % search both the current slice index, and the next slice index.
        % since there is a step of 2 between 'other' slice indices.
        minsi=min([sl(min(sl(min(sli)).others)).b sl(min(sl(min(sli)+1).others)).b]);
        if min(sli)==1
            minsi=sl(1).b;
        end
        
        maxsi=max([sl(max(sl(max(sli)).others)).e sl(max(sl(max(sli)-1).others)).e]);
        if max(sli)==numel(sl)
            maxsi=sl(numel(sl)).e;
        end
        
        
        
        % this is the 'beginning' adjust.
        % get so-many 'extra' samples.
        es = ceil(([sl(1).e]-[sl(1).b])/interpfactor*5/8);
        
        adjust=(ceil(minsi/interpfactor)-1-es)*interpfactor;
        
        samples=(ceil(minsi/interpfactor)-es):(ceil(maxsi/interpfactor)+1+es);
        
        % keyboard;
        
        
        
        % how many samples are there... BEFORE sl(min(sli)).b??
        % the answer: 5*interpfactor+1
        % and also difference between sl(min(sli)).b and
        % min(sl(min(sli)).others) and sl(min(sli)).b.
        
        
        
        
        % in addition to the samples you you need to perform the
        % correction, you'd also want to save the samples of only the
        % slice-artifacts that are processed, and they are fewer!!
        % so... sl(min(sli).b/interpfactor:sl(max(sli).e/interpfactor. I
        % already changed this in the emg_slicecorrection file.
        