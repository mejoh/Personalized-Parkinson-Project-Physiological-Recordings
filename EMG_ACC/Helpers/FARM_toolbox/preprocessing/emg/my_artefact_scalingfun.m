function diff = my_artefact_scalingfun(artefact,template,scale)






diff=sum((artefact-template*scale).^2);