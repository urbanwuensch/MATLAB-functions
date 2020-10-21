function [ model,seq] = ordercomponents( model,f )
% Order PARAFAC model components by their emission maximum
if nargin==1
    cnt=1;
    for n=1:100
        if ~iscell(model)
            if isfield(model,['Model',num2str(n)])
                f(cnt)=n;
            end
        else
            if isfield(model{1},['Model',num2str(n)])
                f(cnt)=n;
            end
        end
        cnt=cnt+1;
    end
    f(f==0)=[];
end
clearvars cnt

for n=1:numel(f)
    modelf=['Model' num2str(f(n))];
    
    if ~isfield(model,modelf)
        disp(model)
        disp(['Can not find ' modelf,' in dataset'])
        error('CompareComponents:fields',...
            'The dataset does not contain a model with the specified number of factors')
    end
    
    M = getfield(model,{1,1},modelf);

    [~,idx]=max(M{2});
    [~,seq]=sort(idx);
    
    disp([num2str(f),' Factors [ ',[num2str(1:f)],' ] reordered. ','Components reordered by dim 2 (Em.) maximum...'])
    disp(['Sequence of old C-index in new model arrangement: ',num2str(seq)])
    
    for i=1:numel(M)
        if ~isempty(M{i})
            Mn{i}=M{i}(:,seq);
        else
%             disp(['Dim',num2str(i),' empty'])
        end
    end
    
    try
        of=model.model;
        if size(M{2},2)==size(of{2},2)
            for i=2:numel(of)
                ofn{i}=of{i}(:,seq);
            end
        end
        model=setfield(model,'model',ofn);
        disp('OpenFluor ''model'' present and nComp equal to input ''f''')
        disp('OpenFluor ''model'' reordered.')
    catch
    end
    
    try 
        weights=getfield(model,['Weights',num2str(f(n))]);
        model=setfield(model,['Weights',num2str(f(n))],weights(:,seq));
        disp('Weights reordered')
    catch
%         disp('No Weights. No prolems.')
    end
    model=setfield(model,modelf,Mn);
    
end

