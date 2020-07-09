function diff = my_template_fitfun(x,n,artefact,template,xInit)

x=x.*xInit;

model=my_template_scalingfun2(template,n,x);
data=artefact;


diff=sum((model-data).^2);

