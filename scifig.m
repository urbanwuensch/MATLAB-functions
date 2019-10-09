function [fhandle] = scifig(varargin)
% Format figures for scientific publications.
%
% USEAGE:
%           [fhandle] = scifig(Name,Value)
%
% Name,Value, e.g. scifig('width',8)
%            width:             Width of figure in cm (default: 8cm)
%            height:            Height of figure in cm (default: 7cm)
%            font:              Font to be used in figure (default: Myriad Pro)
%            fontsize:          Font size to be used in figure (default: 8)
%            axes:              if no axes exist, 'nocreate' will not
%                                   create one (default). 'create' will do so.
%
% (c) Urban Wuensch, 2019

%% Parse inputs
params = inputParser;
params.addParameter('width', 8, @isnumeric);
params.addParameter('height', 7, @isnumeric);
params.addParameter('font', 'Myriad Pro', @ischar);
params.addParameter('fontsize', 8, @isnumeric);
params.addParameter('axes', 'nocreate', @ischar);

params.parse(varargin{:});

width = params.Results.width;
height  = params.Results.height;
font  = params.Results.font;
fontsize = params.Results.fontsize;
axcreate = params.Results.axes;

fhandle=gcf;

%% Configure the figure
set(fhandle,'InvertHardcopy','off','Color',[1 1 1]);
set(fhandle, 'units', 'centimeters');
Cpos=get(fhandle,'pos');
set(fhandle,'pos', [Cpos(1) Cpos(2) width height]);
movegui(fhandle,'center');
drawnow

%% Configure the axes
ax = (findobj(fhandle, 'type', 'axes'));
if isempty(ax)
    switch axcreate
        case 'create'
            ax=axes;
        case 'nocreate'
%             disp('Empty figure. No axes created. ')
%             disp('Run this function again once axes have been created to format them properly.')
            return
    end
end
for n=numel(ax):-1:1
    set(ax(n),'TickDir','out');
    set(ax(n),'fontsize',fontsize,'FontName',font);
    set(ax(n),'LineWidth',0.5);
    pos=get(ax(n),'OuterPosition');
    pos(pos<0)=0;
    set(ax(n),'OuterPosition',pos);
end
 

try 
    WinOnTop;
catch
    %disp('Can''t force the current figure to the top. No worries.')
end
end

