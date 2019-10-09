function [Volume,relVolumeM,relVolumeX] = scores2volume(data,f)
% Convert PARAFAC model scores to fluorescence volume or integral
%   
% USEAGE:
%           [Volume,relVolumeM,relVolumeX] = scores2volume(data,f)
%
% INPUTS:
%      data: data structure containing model with f components.
%         f: number of components in model.
%
% OUTPUTS:
%      Volume:      fluorescence integral corresponding to the scores in data.Modelf
%      relVolumeM:  fluorescence integral relative to sum of component integrals
%      relVolumeX:  fluorescence integral relative to sum of raw fluorescence
%
% NOTES:
%      Units of output variables depends on unit of input. Can be e.g.
%      arbitrary units, Raman units, or quinine sulfate units.
%      
% Examples:
%  [v,rvm,rvx] = scores2volume(models,5)
%
% Notice:
% This mfile was written by Urban Wuensch. It is freely available and not
% part of any toolbox. That said, it works in conjunction with the drEEM
% Toolbox (see dreem.openfluor.org). Contact the author for further
% questions.
%
% scores2volume: Copyright (C) 2019 Urban Wuensch
% Chalmers University of Technology
% Architecture and Civil Engineering
% Water Environment Technology
% 41296 Gothenburg, Sweden
% wuensch@chalmers.se | urbw@aqua.dtu.dk
%
% $ Version 1 $ September 2019 $ First Version

%% Input argument check
nargcheck(2,2) % Must have two inputs
%% Quick vectorization function definition
vec=@(x) x(:); % Allows easy one-line total summing

%% Retreive model
try
    [A,B,C]=fac2let(data.(['Model' int2str(f)]));
catch
    error(['Could not access the ',num2str(f),'-component model. Does it exist? Please check manually.'])
end
%% Preallocate variables
Volume=nan(size(A,1),size(A,2));
relVolumeM=nan(size(A,1),size(A,2));
relVolumeX=nan(size(A,1),size(A,2));

%% Calculate Volume, volume relative to sum of components, and volume relative to sum of raw fl.
for i=1:size(A,1)
    Volume(i,:)=(A(i,:)).*(sum(B).*sum(C));
    relVolumeM(i,:)=Volume(i,:)./sum(Volume(i,:));
    relVolumeX(i,:)=Volume(i,:)./nansum(vec(data.X(i,:,:)));
end

