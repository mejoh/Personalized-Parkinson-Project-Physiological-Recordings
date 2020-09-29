function jobout = job_slicetiming(study,pp,taak,option,wdir)

if nargin<5
    wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
else
    wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/' taak '/'];
end
disp(wdir);


load([wdir 'parameters']);

tr=parameters(1);
ts=parameters(2);
dyn=parameters(3);


st.scans{1}=cell(dyn,1);
for i=1:dyn
    
    st.scans{1}{i}=[wdir 'fmri/4D.img,' num2str(i)];
    
end

st.nslices=ts;
st.tr=tr;
st.ta=(ts-1)/ts*tr;
if strcmp(option,'interleaved')
    st.so=[1:2:ts 2:2:ts];
end
if strcmp(option,'sequence')
    st.so=(1:1:ts);
end

st.refslice=1;


jobout.temporal{1}.st=st;