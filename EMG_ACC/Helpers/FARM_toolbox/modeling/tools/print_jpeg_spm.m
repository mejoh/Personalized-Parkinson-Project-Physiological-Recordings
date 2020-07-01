%
% function out=print_jpeg_spm()
%
% function out=print_jpeg_spm(name)
%
% this function prints the (current) SPM Graphics figure to a jpg file in
% your home directory and names it [name '.jpg']
% or calls it SPM_graphics_copy.jpg.
%
%

function print_jpeg_spm(varargin)

if numel(varargin)>0
    name=varargin{1};
else
    name='SPM_graphics_copy';
end

fh=copyobj(findobj(0,'tag','Graphics'),0);
set(fh,'tag','Graphics_Copy');

set(fh,'paperpositionmode','manual');    % i think this is the trick to obtain good images from the saveas functionality.
set(fh,'paperunits','points');
set(fh,'PaperOrientation','portrait');
set(fh,'PaperType','A4');
set(fh,'PaperPosition',[8 8 480 800]); % to get a nice picture, setting the ascpect ratio's right...
set(fh,'PaperSize',[595.276 841.89]);
saveas(fh,['~/Desktop/MD/Pics' name],'jpg');


% out=1;
 
