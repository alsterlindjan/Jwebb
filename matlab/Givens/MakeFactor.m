function [Fact,Loadings,yy_mean,yy_std] = MakeFactor(yy,numb,subsample)
%Constructing factors form yield data
%   Detailed explanation goes here

[nobs, mn]=size(yy);
%yy_sub=yy(1:subsample,:);
yy_sub=yy(1:nobs-subsample,:);

yy_mean = NaN(1,mn);
yy_std = NaN(1,mn);

% normalizing data
 for iter=1:mn;
   yy_mean(:,iter)=mean(yy_sub(:,iter));
   yy_std(:,iter)=std(yy_sub(:,iter));
   yy(:,iter)=...
       (yy(:,iter)-yy_mean(:,iter))./(yy_std(:,iter));
 end;

 % normalizing sub sample data
 for iter=1:mn;
   yy_sub(:,iter)=...
       (yy_sub(:,iter)-yy_mean(:,iter))./(yy_std(:,iter));
 end;

% Calc loadings on the sub sample
 Loadings = pcacov(cov(yy_sub)); 
 
% make factors for the whole sample and save 
 Fact = NaN(nobs,numb);
 for ii = 1:numb;
  Fact(:,ii) = yy*Loadings(:,ii);
 end;
 
end

