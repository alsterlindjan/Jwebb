function [error, out] = ...
    LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method)
% this function uses functions discflow.m and NSS.m
% depending on method, different weights are applied

 out=NaN(length(data),1);  error=NaN(length(data),1);
for ii=1:length(data)
  % 1)  date functions (Matlab financial toolbox)
  istart = cpndaysn(Set(ii), Mat(ii), istep, 11, 0)/yrs;
  iend = cpncount(Set(ii), Mat(ii), istep, 11, 0);
  
  % 2) discounted price (user written, incl NSS) 
  discPr=discflow(param,coup(ii),Face,istart,iend,istep);

 switch method
    case 'ytm'
    y = bndyield(discPr,coup(ii)/100,Set(ii),Mat(ii),istep,11)*100;
    out(ii)=y;  
    error(ii)=w(ii)*(out(ii)-data(ii));  

    case 'obsyield'
    d = daysact(Set(ii,:),Mat(ii,:));
    y = bndyield(discPr,coup(ii)/100,Set(ii),Mat(ii),istep,11)*100;
    if coup(ii)==0 && d < 365
       y = (100/discPr - 1) * (360/d)*100;
    end 
    out(ii)=y;  
    error(ii)=w(ii)*(out(ii)-data(ii));  

    case 'price'
    out(ii)=discPr;  
    error(ii)=w(ii)*(out(ii)-data(ii));  
   
    case 'dur'   
    out(ii)=discPr;
    error(ii)=sqrt(w(ii))*(out(ii)-data(ii));  

    case 'dv01'   
    out(ii)=discPr;
    error(ii) = sqrt(w(ii)) * (out(ii)-data(ii));
   
 end
end